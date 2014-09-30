% out =reduceData(data,samplingInt,newSamplingFreq);
function out =reduceData(data,samplingInt,newSamplingFreq);
newSamplingInt=1/newSamplingFreq;
r=floor(newSamplingInt/samplingInt);
for k= 1:size(data,2)
    out(:,k)=decimate(data(:,k),r);
end

