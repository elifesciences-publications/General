
if exist('paths') & paths ~=0 & ~isempty(paths)
    paths = paths;
    cd(paths);
    cd ..
end

LoadMultipleFiles

newpreprocess

xwplotmd

ExtractAndNormalizeSignalPairStrength

close all