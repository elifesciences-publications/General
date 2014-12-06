

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
alpha = 1; % The larger the value, the broader the gaussian kernel 

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
    [~,sigMaxInd] = max(abs(signal(fpt:lpt,:)),[],1); 
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
    lenArt = length(fpt:lpt);    
    kernel = gausswin(lenArt,alpha);
    kernel2 = gausswin(3*lenArt,3*alpha); % Making kernel longer than signal to accommodate for circhift coming up
    [~, kerMaxInd] = max(kernel,[],1);     
    kernel2 = circshift(kernel2(:),sigMaxInd-kerMaxInd); % Shifting to align peak of kernel with peak of artifact
    kernel2([1:lenArt 2*lenArt+1:end])=[]; % Taking the central segment of kernel2 that matches signal in length
     kernel2 = kernel2/max(kernel2);
%     kernel = repmat(kernel(:),size(signal,2));
    
    kernel2 =  repmat(kernel2(:),size(signal,2));
    ma = max(artifact);
     artifact = (artifact.*kernel2);
    noise = noise.*kernel;
%     artlessSignal(fpt:lpt,:) = signal(fpt:lpt,:)-artifact + slopedLine; % Same as setting artifact to zero
      artlessSignal(fpt:lpt,:) = signal(fpt:lpt,:)-artifact + noise;
end

