import os
import pickle
import random
import cv2
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
from imutils import paths
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelBinarizer
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.preprocessing.image import img_to_array

from src.utils.VGGNet import SmallerVGGNet

matplotlib.use("Agg")

dir_path = os.path.dirname(os.path.realpath(__file__))
ROOT_PATH = os.path.join(dir_path, '..', '..')
DATASET_PATH = os.path.join(ROOT_PATH, 'models')
TMP_PATH = os.path.join(ROOT_PATH, 'tmp')


def create_dataset():
    # initialize the number of epochs to train for, initial learning rate, batch size, and image dimensions
    EPOCHS = 250
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
        # coin_ref = imagePath.split(os.path.sep)[-1]
        # labels.append(f'{coin_type}_{coin_ref}')
        labels.append(coin_type)

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
    model.save(os.path.join(ROOT_PATH, "dataset_5k.h5"))

    print("[INFO] serializing label binarizer...")
    f = open(os.path.join(ROOT_PATH, "lab_5k.pickle"), "wb")
    f.write(pickle.dumps(lb))
    f.close()

    # plot the training loss and accuracy
    plt.style.use("ggplot")
    plt.figure()
    N = EPOCHS
    plt.plot(np.arange(0, N), H.history["loss"], label="train_loss")
    plt.plot(np.arange(0, N), H.history["val_loss"], label="val_loss")
    plt.plot(np.arange(0, N), H.history["accuracy"], label="train_acc")
    plt.plot(np.arange(0, N), H.history["val_accuracy"], label="val_acc")
    plt.title("Training Loss and Accuracy")
    plt.xlabel("Epoch #")
    plt.ylabel("Loss/Accuracy")
    plt.legend(loc="upper left")
    plt.savefig(TMP_PATH + '/train_new_by_64.png')
    return


values = {
    "01": 200,
    "02": 100,
    "03": 50,
    "04": 20,
    "05": 10,
    "06": 5
}


def classify(image, model, lb):
    output = image.copy()

    try:
        image = cv2.resize(image, (96, 96))
        image = image.astype("float") / 255.0
        image = img_to_array(image)
        image = np.expand_dims(image, axis=0)

        proba = model.predict(image)[0]
        idx = np.argmax(proba)
        label = lb.classes_[idx]

        coin_value = values[label]

        return coin_value, proba[idx] * 100, output

    except Exception as e:
        return None
