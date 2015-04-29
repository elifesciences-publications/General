function normalizedData = NormalizeByColMean(data, colNumber)
% NormalizeByColMean Normalizes data matrix by mean of specified col
% normalizedData = NormalizeByColMean(data,colNumber);

meanData = mean(data,1);
divider = meanData(colNumber);

normalizedData = data/divider; 