import numpy as np
import cv2
import tensorflow as tf
from tensorflow.keras.datasets import mnist

# Tạo mô hình CNN đơn giản nhưng hiệu quả
def build_improved_model():
    model = tf.keras.Sequential([
        tf.keras.layers.Conv2D(32, (3,3), activation='relu', input_shape=(28,28,1)),
        tf.keras.layers.MaxPooling2D((2,2)),
        tf.keras.layers.Conv2D(64, (3,3), activation='relu'),
        tf.keras.layers.MaxPooling2D((2,2)),
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.Dense(10, activation='softmax')
    ])
    model.compile(optimizer='adam',
                 loss='sparse_categorical_crossentropy',
                 metrics=['accuracy'])
    return model

# Load hoặc train model
def get_trained_model():
    try:
        model = tf.keras.models.load_model('improved_mnist_cnn.h5')
    except:
        model = build_improved_model()
        (x_train, y_train), _ = mnist.load_data()
        
        # Tiền xử lý CHUẨN MNIST
        x_train = x_train.reshape(-1, 28, 28, 1).astype('float32')
        x_train = x_train / 255.0  # Chuẩn hóa
        
        model.fit(x_train, y_train, epochs=5, batch_size=64, validation_split=0.1)
        model.save('improved_mnist_cnn.h5')
    return model

# Xử lý ảnh vẽ CHUẨN XÁC
def process_drawing(drawing):
    # 1. Làm mờ để giảm nhiễu
    blurred = cv2.GaussianBlur(drawing, (5,5), 0)
    
    # 2. Căn giữa chữ số giống MNIST
    _, thresh = cv2.threshold(blurred, 127, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    if contours:
        # Tìm bounding box của chữ số
        x,y,w,h = cv2.boundingRect(max(contours, key=cv2.contourArea))
        digit = thresh[y:y+h, x:x+w]
        
        # Thêm padding và resize về 20x20 giữ nguyên tỷ lệ
        if h > w:
            resized = cv2.resize(digit, (int(20*w/h), 20), interpolation=cv2.INTER_AREA)
        else:
            resized = cv2.resize(digit, (20, int(20*h/w)), interpolation=cv2.INTER_AREA)
        
        # Đặt vào giữa ảnh 28x28
        h, w = resized.shape
        x_start = (28 - w) // 2
        y_start = (28 - h) // 2
        
        processed = np.zeros((28,28), dtype=np.float32)
        processed[y_start:y_start+h, x_start:x_start+w] = resized
    else:
        processed = np.zeros((28,28), dtype=np.float32)
    
    # Chuẩn hóa giống MNIST
    processed = processed.reshape(1,28,28,1) / 255.0
    return processed

class DigitDrawer:
    def __init__(self):
        self.model = get_trained_model()
        self.reset_canvas()
        
    def reset_canvas(self):
        self.canvas = np.zeros((280,280), dtype=np.uint8)
        self.display = np.zeros((280,280,3), dtype=np.uint8)
        
    def predict(self):
        processed = process_drawing(self.canvas)
        pred = self.model.predict(processed, verbose=0)
        return np.argmax(pred), np.max(pred)

def main():
    drawer = DigitDrawer()
    cv2.namedWindow('MNIST Drawer')
    
    def mouse_event(event, x, y, flags, param):
        if event == cv2.EVENT_LBUTTONDOWN:
            drawer.drawing = True
            cv2.circle(drawer.canvas, (x,y), 10, 255, -1)
        elif event == cv2.EVENT_MOUSEMOVE and drawer.drawing:
            cv2.line(drawer.canvas, (drawer.last_x, drawer.last_y), (x,y), 255, 20)
        elif event == cv2.EVENT_LBUTTONUP:
            drawer.drawing = False
            digit, conf = drawer.predict()
            print(f"Prediction: {digit} (Confidence: {conf:.2%})")
        
        drawer.last_x, drawer.last_y = x, y
        drawer.display = cv2.cvtColor(drawer.canvas, cv2.COLOR_GRAY2BGR)
        cv2.imshow('MNIST Drawer', drawer.display)
    
    cv2.setMouseCallback('MNIST Drawer', mouse_event)
    
    while True:
        key = cv2.waitKey(1) & 0xFF
        if key == ord('c'):
            drawer.reset_canvas()
        elif key == ord('q'):
            break
    
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()