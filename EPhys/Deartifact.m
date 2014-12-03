

function artlessSignal = Deartifact(signal,samplingInt, stimInds,preStimPeriod, postStimPeriod, kerWid)

% Deartifact - Remove stimulus artifacts.
%   data_mod = autoartremove(data,samplingInt,stimIndices,preStimPeriod, postStimPeriod, kernelWidth); 
%   data - signal vector
%   timeAxis - time vector
%   preStimPeriod - time period before stimulus in which artifact is
%                   considered to have influence (due to filtering, etc)
%   postStimPeriod - time period after stimulus in which artifact is
%                     considered to have influence
 
if size(signal,1) < size(signal,2)
    signal = signal';
end

preStimPts = round(preStimPeriod/samplingInt);
postStimPts = round(postStimPeriod/samplingInt);

% % ker = hamming(max(round(kerWid/samplingInt),3));
% ker = ones(max(round(kerWid/samplingInt),3),1);
lenKer = round(kerWid/samplingInt);
ker = abs(linspace(-lenKer,lenKer,lenKer));
ker = max(ker)-ker;
ker = ker./sum(ker);
artlessSignal = signal;

for stim = 1:numel(stimInds)
    convSig = [];
    fpt = round(max(stimInds(stim)-preStimPts,1));
    lpt = round(min(stimInds(stim) + postStimPts, length(signal)));
    convSig = conv2(signal(fpt:lpt,:),ker(:),'same');
    artlessSignal(fpt:lpt,:) = signal(fpt:lpt,:)-convSig;
end

