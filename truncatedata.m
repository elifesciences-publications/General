% TRUNCATEDATA
% [data_trunc,timeAxis_trunc] = truncatedata(data,timeAxis,[firstTimePt lastTimePt])
% Truncates the variable "data" from the specified first time point to the last time
% point
function [truncData truncTime]=truncatedata(data,timeAxis,timePts)

%% Some variables
samplingInt = mean(diff(timeAxis));
timeAxis=timeAxis(:);
if size(data,1)<size(data,2)
    data=data';
end
firstTimePt=timePts(1); 
lastTimePt = timePts(2);
fpt = min(find(timeAxis>=firstTimePt));
lpt = min(find(timeAxis>=lastTimePt));

%% Truncating data
truncData = data(fpt:lpt,:,:);
truncTime = timeAxis(fpt:lpt);
truncTime=truncTime(:);