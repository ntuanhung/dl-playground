__author__ = 'oli'

import numpy as np

import math
import csv
import gzip
import cv2

show = True

# Creates "new" training data, by rotating the old pixels
def expandTraining(filename, filenameExp):
    x_tmp = []
    y_tmp = []
    y_table = np.zeros(10)
    with gzip.open(filename) as f:
        reader = csv.reader(f)
        for row in reader:
            vals = np.asarray(row[1:], np.int)
            y = int(row[0])
            y_tmp.append(y)
            y_table[y] += 1
            x_tmp.append(np.asarray(row[1:], np.int))
    print("Read Images ")
    if (show):
        cv2.namedWindow('Original Training Set', cv2.WINDOW_NORMAL)
        cv2.namedWindow('Distorted Training Set', cv2.WINDOW_NORMAL)
    c = 0
    rot = (-10,-8,-6,-4,-6,4,6,8,10)
    dists = (-4,-2,2,4)
    w = csv.writer(open(filenameExp + '.csv', 'w'))
    for row in x_tmp:
        print("Manipulating original image %d", c)
        vals = np.asarray(row)
        y = y_tmp[c]
        d = np.append(y, row)
        # w.writerow(d) we do not write the original training set, idea from Cice...
        c += 1
        NDumm = int(math.sqrt(len(vals)))
        img = np.reshape(vals, (NDumm, NDumm)) / 255.0
        if show: cv2.imshow('Original Training Set', img)
        reps = int(3 * y_table.sum() / y_table[y] )
        for i in xrange(reps):
            r = rot[np.random.randint(0, len(rot))]
            mat = cv2.getRotationMatrix2D((NDumm/2, NDumm/2), r, 1)
            dist = 0
            if (np.random.uniform() < 0.5):
                dist = dists[np.random.randint(0, len(dists))]
                mat[0,2] = mat[0,2] + dist
            if (np.random.uniform() < 0.5):
                dist = dists[np.random.randint(0, len(dists))]
                mat[1,2] = mat[1,2] + dist
            if (dist == 0):
                dist = dists[np.random.randint(0, len(dists))]
            #primat[1,2] = mat[1,2] + dist                    nt(dist)
            img_rotated = cv2.warpAffine(img, mat, (NDumm, NDumm))
            d = np.append(y,  np.asarray(img_rotated.reshape(-1) * 255, dtype=np.int))
            w.writerow(d)
            if show:
                cv2.imshow('Distorted Training Set', img_rotated)
                cv2.waitKey(1)

if __name__ == '__main__':
    filenameTraining = "../../data/batch1_46_gamma_dog.csv.gz"
    filenameTraining_expanded = "../../data/batch1_46_gamma_dog_extended"
    expandTraining(filenameTraining, filenameTraining_expanded)
    print("Packing")
    import subprocess
    print(subprocess.check_output(['gzip', filenameTraining_expanded + ".csv"]))