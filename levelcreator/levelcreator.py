#!/usr/bin/python2

import sys
import numpy as np
import cv2
import json

def help():
    print( "Usage: " + sys.argv[0] + " input_image output_file" )

def flatten(ar):
    newar = []
    for row in ar:
        newar.append([row[0][0].item(), row[0][1].item()])
    return newar

def main():
    if len(sys.argv) < 3:
        help()
        return

    imagefile = sys.argv[1]
    filename = sys.argv[2]

    im = cv2.imread( imagefile )
    imgray = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)
    ret,thresh = cv2.threshold(imgray,0,126,1)
    contours, hierarchy = cv2.findContours(thresh,cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

    level = {}
    level["lines"] = []
    for contour in contours:
        poly = cv2.approxPolyDP(contour, 1, True)
        level["lines"].append(flatten(poly))

    with open(filename, 'w') as levelfile:
        json.dump(level, levelfile)


if __name__ == "__main__":
    main()
