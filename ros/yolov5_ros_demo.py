#!/usr/bin/env python3
import rospy
import cv2
from sensor_msgs.msg import Image
import numpy as np
import os
import torch

def callback_image(msg):
    global frame
    frame = np.frombuffer(
                msg.data, dtype=np.uint8
            ).reshape(msg.height, msg.width, -1)[:, :, ::-1]

def callback_depth(msg):
    global depth
    depth = np.frombuffer(
                msg.data, dtype=np.uint16
            ).reshape(msg.height, msg.width)

if __name__ == "__main__":
    rospy.init_node("my_pkg_demo")
    rospy.loginfo("my_pkg_demo start!")

    rospy.Subscriber("/camera/rgb/image_raw", Image, callback_image)
    rospy.Subscriber("/camera/depth/image_raw", Image, callback_depth)

    os.environ["TORCH_HOME"] = "~"
    net = torch.hub.load("ultralytics/yolov5", "yolov5l", device="cpu")

    frame = None
    depth = None
    while not rospy.is_shutdown():
        rospy.Rate(20).sleep()
        if frame is None: continue
        if depth is None: continue

        img = frame.copy()
        res = net(img)
        for x1, y1, x2, y2, pred, index in res.xyxy[0]:
            if pred < 0.7: continue
            x1, y1, x2, y2, index = map(int, (x1, y1, x2, y2, index))
            name = net.names[index]
            cv2.rectangle(img, (x1, y1), (x2, y2), (0, 255, 0), 2)
            cv2.putText(
                img, name, (x1, y1 + 20),
                cv2.FONT_HERSHEY_SIMPLEX, 0.8, 
                (0, 255, 0), 1, cv2.LINE_AA
            )

        cv2.imshow("frame", img)
        cv2.imshow("depth", depth)
        key_code = cv2.waitKey(1)
        if key_code in [27, ord('q')]:
            break

    rospy.loginfo("my_pkg_demo end.")
