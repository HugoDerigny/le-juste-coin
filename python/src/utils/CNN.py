from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.preprocessing.image import img_to_array
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelBinarizer
from tensorflow.keras.optimizers import Adam
from src.utils.VGGNet import SmallerVGGNet
from imutils import paths
import numpy as np
import matplotlib
import imutils
import random
import pickle
import cv2
import os

matplotlib.use("Agg")

DATASET_PATH = os.path.join(os.getcwd(), 'models')


def create_dataset():
    # initialize the number of epochs to train for, initial learning rate, batch size, and image dimensions
    EPOCHS = 100
    INIT_LR = 0.001
    BS = 16
    IMAGE_DIMS = (96, 96, 3)

    data = []
    labels = []

    # grab the image paths and randomly shuffle them
    print("[INFO] loading images...")
    imagePaths = sorted(list(paths.list_images(DATASET_PATH)))
    random.seed(42)
    random.shuffle(imagePaths)

    # loop over the input images
    for imagePath in imagePaths:
        # pre-process images and update data and label lists
        image = cv2.imread(imagePath)
        image = cv2.resize(image, (IMAGE_DIMS[1], IMAGE_DIMS[0]))
        image = img_to_array(image)
        data.append(image)

        coin_type = imagePath.split(os.path.sep)[-2]
        coin_ref = imagePath.split(os.path.sep)[-1]
        print(f'{coin_type}_{coin_ref}')
        labels.append(f'{coin_type}_{coin_ref}')

    print(len(data))

    # scale the raw pixel intensities to the range [0, 1]
    data = np.array(data, dtype="float") / 255.0
    labels = np.array(labels)
    print("[INFO] data matrix: {:.2f}MB".format(data.nbytes / (1024 * 1000.0)))

    # binarize the labels
    lb = LabelBinarizer()
    labels = lb.fit_transform(labels)

    # 80% for training and 20% for testing
    (trainX, testX, trainY, testY) = train_test_split(data, labels, test_size=0.2, random_state=42)

    # construct the image generator for data augmentation
    datagen = ImageDataGenerator(rotation_range=25, width_shift_range=0.1, height_shift_range=0.1,
                                 shear_range=0.2, zoom_range=0.2, horizontal_flip=True, fill_mode="nearest")

    # initialize the model
    print("[INFO] compiling model...")
    model = SmallerVGGNet.build(width=IMAGE_DIMS[1], height=IMAGE_DIMS[0], depth=IMAGE_DIMS[2],
                                classes=len(lb.classes_))
    opt = Adam(learning_rate=INIT_LR, decay=INIT_LR / EPOCHS)
    model.compile(loss="categorical_crossentropy", optimizer=opt, metrics=["accuracy"])

    # train the network
    print("[INFO] training network...")
    H = model.fit(
        datagen.flow(trainX, trainY, batch_size=BS),
        validation_data=(testX, testY),
        steps_per_epoch=len(trainX) // BS,
        epochs=EPOCHS,
        verbose=1)

    # save the results to disk
    print("[INFO] serializing network...")
    model.save("dataset.h5")

    print("[INFO] serializing label binarizer...")
    f = open("lab.pickle", "wb")
    f.write(pickle.dumps(lb))
    f.close()


def classify(image, model, lb):
    output = image.copy()

    # pre-process the image for classification

    image = cv2.resize(image, (96, 96))
    image = image.astype("float") / 255.0
    image = img_to_array(image)
    image = np.expand_dims(image, axis=0)

    # classify the input image
    proba = model.predict(image)[0]
    idx = np.argmax(proba)
    label = lb.classes_[idx]

    # build the label and draw the label on the image
    label = "{}: {:.2f}%".format(label, proba[idx] * 100)
    # label = "{}".format(label)
    output = imutils.resize(output, width=400)
    cv2.putText(output, label, (10, 25), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)

    return output, label, proba[idx] * 100
