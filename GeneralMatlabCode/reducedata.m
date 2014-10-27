% REDUCEDATA   Reduce sampling frequency of data by decimation.
%   data_mod = reducedata(data,timeAxis,newSamplingFreq) returns data resampled
%   at a new sampling frequency specified as input to the function.
%
%   [data_mod,time_mod] = reducedata(data,timeAxis,newSamplingFreq) also
%   returns resampled time vector to match the resampled data.
%
%   Author: AP
%   Modified 18-Mar-2014
function [varargout] =reducedata(data,timeAxis,newSamplingFreq);
samplingInt = timeAxis(2)-timeAxis(1);
if size(data,1)< size(data,2)
    data=data';
end
newSamplingInt=1/newSamplingFreq;
r=ceil(newSamplingInt/samplingInt);

for k= 1:size(data,2)
   for kk = 1:size(data,3)
    out(:,k,kk)=decimate(data(:,k,kk),r);  
   end
end
varargout{1} = out;
varargout{2} = linspace(0,timeAxis(end),length(out));
