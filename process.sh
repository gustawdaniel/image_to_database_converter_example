#!/usr/bin/env bash

RAW=raw;
BUILD=build;

mkdir -p $BUILD;
rm -rf $BUILD/*

for cat in $RAW/*
do
    baseCat=$(basename $cat .png);
    for file in $cat/*.png
    do
        baseFile=$(basename $file .png);
        mkdir -p $BUILD/$baseCat;
        tesseract $file $BUILD/$baseCat/$baseFile;
    done
done