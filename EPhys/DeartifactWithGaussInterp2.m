

function artlessSignal = DeartifactWithGaussInterp2(signal,samplingInt,stimInds,preStimPeriod, postStimPeriod,alpha)
% DeartifactWithGaussInterp2 - Remove stimulus artifacts by Gaussian sampling interpolation near the artifact.
%                       period and also adds some Hamming modulated noise
%   data_mod = DeartifactWithGaussInterp2(data,samplingInt,stimIndices,preStimPeriod, postStimPeriod);
%   data        - timeseries with artifacts
%   samplingInt - samplingInterval
%   stimInds    - stimulus indices
%   preStimPeriod - time period before stimulus in which artifact is
%                   considered to have influence (due to filtering, etc)
%   postStimPeriod - time period after stimulus in which artifact is
%                     considered to have influence

if size(signal,1) < size(signal,2)
    signal = signal';
end

preStimPts = round(preStimPeriod/samplingInt);
postStimPts = round(postStimPeriod/samplingInt);
% alpha = 2; % The smaller the value, the broader the gaussian kernel

artlessSignal = signal;
noiseLevel = 0.1*std(artlessSignal,[],1);

for stim = 1:numel(stimInds)
    %## 1st round: artifact estimation using local means of variable size windows
    disp(['Stim # ' num2str(stim)])
    artifact =[];
    fpt = round(max(stimInds(stim)-preStimPts,1));
    lpt = round(min(stimInds(stim) + postStimPts, length(signal)));
    noise = repmat(noiseLevel,numel(fpt:lpt),1);
    noise = noise.*randn(size(noise));
    artifact = signal(fpt:lpt,:);
    lenArt = length(fpt:lpt);
    kernel = gausswin(lenArt,alpha);
    kernel2 = circshift(kernel,round(lenArt/2)+preStimPts);
    badInd = find((kernel2(2:end) > min(kernel2)) & (kernel2(1:end-1) == min(kernel2)));
%   The above line ensures that the kernel only tapers off towards the
%   right despite the circshift.
    kernel2(badInd:end) = min(kernel2);
    kernel2 = (kernel2-min(kernel2))/max(kernel2);
    
%     kernel2 = gausswin(3*lenArt,3*alpha); % Making kernel longer than signal to accommodate for circhift coming up
%     [~, kerMaxInd] = max(kernel,[],1);
%     [~,sigMaxInd] = max(abs(artifact),[],1);
%     
%     kernel2 = circshift(kernel2(:),sigMaxInd-kerMaxInd); % Shifting to align peak of kernel with peak of artifact
%     kernel2([1:lenArt 2*lenArt+1:end])=[]; % Taking the central segment of kernel2 that matches signal in length
%     kernel2 = kernel2-min(kernel2);
%     kernel2 = kernel2*max(kernel2);
%     
    
    dt_max = 60; % Max interval with which to sample.
    dtVec = (dt_max-1)*(1-kernel2);
    dtVec = round(dtVec+1);
    
    blah = struct;
    blah.mu = zeros(size(artifact));
    blah.med = zeros(size(artifact));
    for jj = 1:length(artifact)-dtVec(end)-1
        halfLen = max(round(dtVec(jj)/2),1);
        cArt = circshift(artifact,halfLen);
        blah.mu(jj) = mean(cArt(jj:jj+dtVec(jj)));
        blah.med(jj) = median(cArt(jj:jj+dtVec(jj)));
    end
    res.med = artifact - blah.med;    
    
    %## 2nd round: artifact reduction with half-width kernel
    kernel = gausswin(lenArt,2*alpha);
    kernel2 = circshift(kernel,round(lenArt/2)+preStimPts);
    badInd = find((kernel2(2:end) > min(kernel2)) & (kernel2(1:end-1) == min(kernel2)));
    kernel2(badInd:end) = min(kernel2);
    kernel2 = (kernel2-min(kernel2))/max(kernel2);
    
    noise = noise.*kernel2;
    artlessSignal(fpt:lpt,:) = (res.med.*(1-kernel2)) + noise;  
    
end

