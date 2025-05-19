from tensorflow.keras.models import load_model

model = load_model('model/efficientnetv2b0_imagenet.h5')
model.summary()