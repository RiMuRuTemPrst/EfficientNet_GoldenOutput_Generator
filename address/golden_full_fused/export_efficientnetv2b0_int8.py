import tensorflow as tf
import tensorflow_datasets as tfds
import numpy as np

# ----- 1️⃣ Load mô hình EfficientNetV2B0 gốc -----
model = tf.keras.applications.EfficientNetV2B0(weights="imagenet", include_top=True)

# ----- 2️⃣ Chuẩn bị dữ liệu mẫu để calibrate quantization -----
def representative_data_gen():
    for data in tfds.as_numpy(tfds.load('imagenet_v2', split='test', batch_size=1, shuffle_files=True).take(100)):
        img = data['image']
        img = tf.image.resize(img, (224, 224))
        img = tf.cast(img, tf.float32) / 255.0
        yield [img]

# ----- 3️⃣ Converter sang TFLite với int8 quantization -----
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset = representative_data_gen
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.int8
converter.inference_output_type = tf.int8

tflite_quant_model = converter.convert()

# ----- 4️⃣ Lưu ra file -----
with open("efficientnetv2b0_int8.tflite", "wb") as f:
    f.write(tflite_quant_model)

print("✅ Saved quantized model: efficientnetv2b0_int8.tflite")
