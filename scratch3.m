function eventRate = EventsToRate(eventInds,sigLen,samplingInt)
% EventsToRate - Returns an event rate vector using event indices
%
% eventRate = EventsToRate(eventIndices, signalLength, samplingInt);
% Inputs:
% eventIndices - indices of all events within a signal
% signalLength - length of the signal from which the events were pulled;
%                this is so that the event rate matches the signal in
%                length
% samplingInt  - signal samplingInterval;

if nargin < 3
    errordlg('At least 3 inputs required!');
end

eventRate = zeros(size(1:sigLen));
for jj = 1:numel(eventInds)-1
    eventRate(eventInds(jj):eventInds(jj+1),side) = 1./((eventInds(jj+1)-eventInds(jj))*samplingInt);
end

