#!/usr/bin/env bash

RAW=raw;
BUILD=build;

mkdir -p $BUILD;
rm -rf $BUILD/*

for file in $RAW/*png
do
    out=$(basename $file .png);
    tesseract $file $BUILD/$out;
done