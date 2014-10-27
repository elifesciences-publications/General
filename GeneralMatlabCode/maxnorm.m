% MAXNORM - Normalizes data to max values
% normData = maxnorm(data);
function normData=maxnorm(data);
maxData=max(data);
maxMat=diag(1./maxData);
normData=data*maxMat;