import numpy as np
import cv2
import tensorflow as tf
from tensorflow.keras import layers, models
from tensorflow.keras.models import load_model
from tensorflow.keras import backend as K

# Hàm quantization (giống như trong model)
def quantize_layer(x, n_bits=3, max_value=8):
    x = K.clip(x, 0, max_value)
    x = x / max_value * (2**n_bits - 1)
    x = K.round(x)
    x = x / (2**n_bits - 1) * max_value
    return x

# Tải mô hình đã train (thay đường dẫn bằng file weight của bạn)
def load_trained_model(model_path='Sw\mnist_fused_model.weights.h5'):
    # Tạo model với kiến trúc giống như khi train
    def build_quantized_model_mnist():
        inputs = layers.Input(shape=(32, 32, 1))

        # Quantize input
        x = tf.keras.layers.Lambda(lambda x: quantize_layer(x, 3, 8), name="input_quantize")(inputs)

        # Block 1
        x = layers.Conv2D(64, kernel_size=3, strides=2, padding='same', use_bias=True, name="conv_1")(x)
        x = layers.ReLU(name="relu_1")(x)
        x = tf.keras.layers.Lambda(lambda x: quantize_layer(x, 3, 8), name="lamda_1")(x)

        # Block 2
        x = layers.Conv2D(64, kernel_size=1, strides=1, padding='valid', use_bias=True, name="conv_2")(x)
        x = layers.ReLU(name="relu_2")(x)
        x = tf.keras.layers.Lambda(lambda x: quantize_layer(x, 3, 8), name="lamda_2")(x)

        # Block 3
        x = layers.Conv2D(128, kernel_size=1, strides=1, padding='valid', use_bias=True, name="conv_3")(x)
        x = layers.ReLU(name="relu_3")(x)
        x = tf.keras.layers.Lambda(lambda x: quantize_layer(x, 3, 8), name="lamda_3")(x)

        # Block 4
        x = layers.Conv2D(128, kernel_size=3, strides=2, padding='valid', use_bias=True, name="conv_4")(x)
        x = layers.ReLU(name="relu_4")(x)
        x = tf.keras.layers.Lambda(lambda x: quantize_layer(x, 3, 8), name="lamda_4")(x)

        x = layers.GlobalAveragePooling2D()(x)
        x = layers.Dropout(0.3)(x)
        outputs = layers.Dense(10, activation='softmax')(x)

        return models.Model(inputs=inputs, outputs=outputs, name="mnist_cnn_quantized")
    
    # Tải weights đã train
    model = build_quantized_model_mnist()
    model.load_weights(model_path)
    return model

# Biến toàn cục cho vẽ
drawing = False
ix, iy = -1, -1
img = np.zeros((280, 280, 1), dtype=np.uint8)

# Hàm xử lý sự kiện chuột
def draw_event(event, x, y, flags, param):
    global ix, iy, drawing, img
    
    if event == cv2.EVENT_LBUTTONDOWN:
        drawing = True
        ix, iy = x, y
        
    elif event == cv2.EVENT_MOUSEMOVE:
        if drawing:
            cv2.line(img, (ix, iy), (x, y), (255, 255, 255), 15)
            ix, iy = x, y
            
    elif event == cv2.EVENT_LBUTTONUP:
        drawing = False
        cv2.line(img, (ix, iy), (x, y), (255, 255, 255), 15)
        predict_digit()
        
    return

# Hàm dự đoán chữ số
def predict_digit():
    global img, model
    
    # Tiền xử lý ảnh giống như MNIST
    resized = cv2.resize(img, (32, 32), interpolation=cv2.INTER_AREA)
    normalized = resized / 255.0
    input_img = np.expand_dims(normalized, axis=0)
    input_img = np.expand_dims(input_img, axis=-1)
    
    # Dự đoán
    predictions = model.predict(input_img)
    predicted_digit = np.argmax(predictions)
    confidence = np.max(predictions)
    
    # Hiển thị kết quả
    print(f"Predicted digit: {predicted_digit} with confidence: {confidence:.2f}")
    cv2.putText(img, f"Prediction: {predicted_digit} ({confidence:.2f})", 
                (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
    
    return predicted_digit

# Hàm reset bảng vẽ
def reset_canvas():
    global img
    img = np.zeros((280, 280, 1), dtype=np.uint8)

# Hàm chính
def main():
    global model, img
    
    # Tải mô hình
    model = load_trained_model()
    
    # Tạo cửa sổ và thiết lập callback
    cv2.namedWindow('MNIST Digit Drawer')
    cv2.setMouseCallback('MNIST Digit Drawer', draw_event)
    
    print("Instructions:")
    print("1. Draw a digit with your mouse")
    print("2. Release the mouse button to see prediction")
    print("3. Press 'c' to clear the canvas")
    print("4. Press 'q' to quit")
    
    while True:
        cv2.imshow('MNIST Digit Drawer', img)
        key = cv2.waitKey(1) & 0xFF
        
        if key == ord('c'):
            reset_canvas()
        elif key == ord('q'):
            break
    
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()