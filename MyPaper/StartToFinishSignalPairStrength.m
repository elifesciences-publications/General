% clear all; close all;

fileNames = {    'T09430025'
    'T09430026'};

baseDir = 'C:\Users\Avi\Documents\All Things Research\Research Data\Data';


LoadMultipleFiles

newpreprocess

xwplotmd

ExtractAndNormalizeSignalPairStrength

% close all
display(normalizedSignalPairXWPower);
num2clip(normalizedSignalPairXWPower);