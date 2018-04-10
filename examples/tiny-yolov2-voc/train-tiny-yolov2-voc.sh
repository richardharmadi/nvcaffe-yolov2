#!/usr/bin/env sh

CAFFE_HOME=../..

SOLVER=./tiny-yolov2-voc-solver.prototxt
$CAFFE_HOME/build/tools/caffe train \
    --solver=$SOLVER \
    --gpu 0 | tee train_tiny-yolov2-voc_anchor.log 

