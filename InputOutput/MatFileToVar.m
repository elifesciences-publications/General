function var = MatFileToVar(matFileObj)
tic
var = struct;
fldNames = fieldnames(matFileObj);
for fldNum = 1:length(fldNames)
    fldName = fldNames{fldNum};
    var.(fldName) = matFileObj.(fldName);
end
toc

% mData.data = pyData.data;
% mData.trialSegData = pyData.trialSegData;
% mData.stack = pyData.stack;
% mData.tData = pyData.tData;
% mData.cells = pyData.cells;
% mData.activityMap = pyData.activityMap;

