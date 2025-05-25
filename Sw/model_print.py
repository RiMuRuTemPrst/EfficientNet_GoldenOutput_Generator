import numpy as np
import cv2
import tensorflow as tf
from tensorflow.keras import layers, models
from tensorflow.keras.layers import Lambda

# Hàm quantize giả lập (giữ nguyên)
def dfp_quantize(x: np.ndarray, int_bits: int = 3, total_bits: int = 8) -> np.ndarray:
    frac_bits = total_bits - int_bits
    scale = 1 << frac_bits
    x_int = np.round(x * scale).astype(np.int32)
    max_val = (1 << (total_bits - 1)) - 1
    min_val = - (1 << (total_bits - 1))
    x_int = np.clip(x_int, min_val, max_val)
    x_int = x_int.astype(np.int8)
    q_float = x_int.astype(np.float32) / scale
    return q_float

def quantize_layer(x, int_bits=3, total_bits=8):
    def quantize_fn(x_np):
        return dfp_quantize(x_np, int_bits, total_bits)
    x_quant = tf.numpy_function(quantize_fn, [x], tf.float32)
    x_quant.set_shape(x.shape)
    return x_quant

def build_quantized_model_mnist():
    inputs = layers.Input(shape=(32, 32, 1))
    x = Lambda(lambda x: quantize_layer(x, 3, 8), name="input_quantize")(inputs)
    x = layers.Conv2D(64, 3, strides=2, padding='same', use_bias=True, name="conv_1")(x)
    x = layers.ReLU(name="relu_1")(x)
    x = Lambda(lambda x: quantize_layer(x, 3, 8), name="lambda_1")(x)
    x = layers.Conv2D(64, 1, strides=1, padding='valid', use_bias=True, name="conv_2")(x)
    x = layers.ReLU(name="relu_2")(x)
    x = Lambda(lambda x: quantize_layer(x, 3, 8), name="lambda_2")(x)
    x = layers.Conv2D(128, 1, strides=1, padding='valid', use_bias=True, name="conv_3")(x)
    x = layers.ReLU(name="relu_3")(x)
    x = Lambda(lambda x: quantize_layer(x, 3, 8), name="lambda_3")(x)
    x = layers.Conv2D(128, 3, strides=2, padding='valid', use_bias=True, name="conv_4")(x)
    x = layers.ReLU(name="relu_4")(x)
    x = Lambda(lambda x: quantize_layer(x, 3, 8), name="lambda_4")(x)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dropout(0.3)(x)
    outputs = layers.Dense(10, activation='softmax')(x)
    model = models.Model(inputs=inputs, outputs=outputs, name="mnist_cnn_quantized")
    return model

# Hàm xử lý ảnh vẽ sang kích thước 32x32 và chuẩn hóa (giữ nguyên)
def process_drawing(drawing):
    blurred = cv2.GaussianBlur(drawing, (5,5), 0)
    _, thresh = cv2.threshold(blurred, 127, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    if contours:
        x, y, w, h = cv2.boundingRect(max(contours, key=cv2.contourArea))
        digit = thresh[y:y+h, x:x+w]
        if h > w:
            resized = cv2.resize(digit, (int(20*w/h), 20), interpolation=cv2.INTER_AREA)
        else:
            resized = cv2.resize(digit, (20, int(20*h/w)), interpolation=cv2.INTER_AREA)

        h_resized, w_resized = resized.shape
        x_start = (28 - w_resized) // 2
        y_start = (28 - h_resized) // 2
        processed = np.zeros((28,28), dtype=np.uint8)
        processed[y_start:y_start+h_resized, x_start:x_start+w_resized] = resized
    else:
        processed = np.zeros((28,28), dtype=np.uint8)

    processed = cv2.resize(processed, (32,32))
    processed = processed.astype(np.float32) / 255.0
    processed = processed.reshape(1, 32, 32, 1)
    return processed

class DigitDrawer:
    def __init__(self, layer_name):
        self.model = build_quantized_model_mnist()
        try:
            self.model.load_weights('Sw\\mnist_quantized_weights.weights.h5')
        except FileNotFoundError:
            print("Error: Weight file 'mnist_quantized_weights.weights.h5' not found.")
            exit(1)
        self.layer_name = layer_name
        self.reset_canvas()
        self.drawing = False
        self.last_x, self.last_y = None, None

        # Tạo model để lấy output của layer được chỉ định
        try:
            output = self.model.get_layer(layer_name).output
            self.intermediate_model = tf.keras.Model(inputs=self.model.input, outputs=output)
        except ValueError:
            print(f"Error: Layer '{layer_name}' not found in model.")
            print("Available layers:", [layer.name for layer in self.model.layers])
            exit(1)

    def reset_canvas(self):
        self.canvas = np.zeros((280, 280), dtype=np.uint8)

    def predict(self):
        img_processed = process_drawing(self.canvas)
        pred = self.model.predict(img_processed, verbose=0)
        pred_label = np.argmax(pred)
        confidence = np.max(pred)
        return pred_label, confidence

    def get_layer_output(self):
        img_processed = process_drawing(self.canvas)
        output = self.intermediate_model.predict(img_processed, verbose=0)  # shape (1, H, W, C) or (1, N)
        output = output[0]  # bỏ batch dimension
        if len(output.shape) == 3:  # Nếu là tensor 3D (H, W, C)
            output = np.transpose(output, (2, 1, 0))  # (C, W, H)
        return output

def main():
    # Chỉ định layer muốn lấy output (có thể thay đổi)
    layer_name = input("Enter the layer name to extract output (e.g., 'conv_2', 'relu_3'): ")
    drawer = DigitDrawer(layer_name)
    cv2.namedWindow('MNIST Drawer')

    def mouse_event(event, x, y, flags, param):
        if event == cv2.EVENT_LBUTTONDOWN:
            drawer.drawing = True
            drawer.last_x, drawer.last_y = x, y
            cv2.circle(drawer.canvas, (x, y), 10, 255, -1)
        elif event == cv2.EVENT_MOUSEMOVE and drawer.drawing:
            cv2.line(drawer.canvas, (drawer.last_x, drawer.last_y), (x, y), 255, 20)
            drawer.last_x, drawer.last_y = x, y
        elif event == cv2.EVENT_LBUTTONUP:
            drawer.drawing = False
            output = drawer.get_layer_output()
            filename = f'layer_output_{layer_name}.txt'
            if len(output.shape) == 3:  # Tensor 3D (C, W, H)
                C, W, H = output.shape
                with open(filename, 'w') as f:
                    for w in range(W):
                        for h in range(H):
                            for c in range(C):
                                f.write(f"{output[c, w, h]:.6f}\n")
            else:  # Tensor 1D (e.g., output của Dense layer)
                with open(filename, 'w') as f:
                    for val in output:
                        f.write(f"{val:.6f}\n")
            print(f"Saved output of layer '{layer_name}' to {filename}")

    cv2.setMouseCallback('MNIST Drawer', mouse_event)

    while True:
        display_img = cv2.cvtColor(drawer.canvas, cv2.COLOR_GRAY2BGR)
        cv2.imshow('MNIST Drawer', display_img)
        key = cv2.waitKey(1) & 0xFF
        if key == ord('c'):
            drawer.reset_canvas()
        elif key == ord('p'):
            label, confidence = drawer.predict()
            print(f"Predicted digit: {label}, Confidence: {confidence:.4f}")
        elif key == ord('q'):
            break

    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()