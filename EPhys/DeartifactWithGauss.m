

function artlessSignal = DeartifactWithGauss(signal,samplingInt, stimInds,preStimPeriod, postStimPeriod)

% DeartifactWithGauss - Remove stimulus artifacts. In contrast to
%                      Deartifact, subtracts Gaussian-modulated artifact for selected time
%                       period and also adds some Hamming modulated noise
%   data_mod = DeartifactWithGauss(data,samplingInt,stimIndices,preStimPeriod, postStimPeriod); 
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
% lenKer = round(kerWid/samplingInt);
% ker = abs(linspace(-lenKer,lenKer,lenKer));
% ker = max(ker)-ker;
% ker = ker./sum(ker);
artlessSignal = signal;
noiseLevel = 1*std(artlessSignal,[],1);
for stim = 1:numel(stimInds)
    artifact =[];
    fpt = round(max(stimInds(stim)-preStimPts,1));
    lpt = round(min(stimInds(stim) + postStimPts, length(signal)));
%     m = (signal(lpt,:)-signal(fpt,:))/(lpt-fpt);
%     m = repmat(m,numel(fpt:lpt),1);
%     b = signal(fpt,:);
%     b = repmat(b,numel(fpt:lpt),1);
%     b = zeros(size(b));
%     x = fpt:lpt;
%     x = repmat(x(:),1,size(signal,2));
%     slopedLine = m.*x + b;
   noise = repmat(noiseLevel,numel(fpt:lpt),1);
   noise = noise.*randn(size(noise));
    artifact = signal(fpt:lpt,:);
    kernel = gausswin(length(fpt:lpt));
    kernel = repmat(kernel(:),size(signal,2));
    artifact = artifact.*kernel;
    noise = noise.*kernel;
%     artlessSignal(fpt:lpt,:) = signal(fpt:lpt,:)-artifact + slopedLine; % Same as setting artifact to zero
      artlessSignal(fpt:lpt,:) = signal(fpt:lpt,:)-artifact + noise;
end

