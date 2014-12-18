

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
alpha = 2; % The larger the value, the broader the gaussian kernel 

artlessSignal = signal;
noiseLevel = 1*std(artlessSignal,[],1);

for stim = 1:numel(stimInds)
    %%%%%%%%% First iteration %%%%%%%%%%
    artifact =[];
    fpt = round(max(stimInds(stim)-preStimPts,1));
    lpt = round(min(stimInds(stim) + postStimPts, length(signal)));
    noise = repmat(noiseLevel,numel(fpt:lpt),1);
   noise = noise.*randn(size(noise));
    artifact = signal(fpt:lpt,:);
%     figure, subplot(2,1,1), plot(artifact), hold on, xlim([-inf inf])
    lenArt = length(fpt:lpt);    
    kernel = gausswin(lenArt,alpha);      
%      kernel = (kernel-min(kernel))/(max(kernel)-min(kernel));    
%      plot(kernel*max(artifact),'c')
%     kernel =  repmat(kernel(:),1, size(signal,2));
%      artifact = (artifact.*kernel);
%     plot(artifact,'r:')
% %     artlessSignal(fpt:lpt,:) = signal(fpt:lpt,:)-artifact + slopedLine; % Same as setting artifact to zero
%       artlessSignal(fpt:lpt,:) = signal(fpt:lpt,:)-artifact; %+ noise;
%       plot(artlessSignal(fpt:lpt,:),'k')
      kernel2 = gausswin(3*lenArt,3*alpha); % Making kernel longer than signal to accommodate for circhift coming up
      [~, kerMaxInd] = max(kernel,[],1);  
     [~,sigMaxInd] = max(abs(artifact),[],1);
    kernel2 = circshift(kernel2(:),sigMaxInd-kerMaxInd); % Shifting to align peak of kernel with peak of artifact
    kernel2([1:lenArt 2*lenArt+1:end])=[]; % Taking the central segment of kernel2 that matches signal in length
    kernel2 = (kernel2-min(kernel2))/(max(kernel2)-min(kernel2)); 
%     plot(kernel2*max(artifact),'c')
    kernel2 =  repmat(kernel2(:),1,size(signal,2)); 
     noise = noise.*kernel2;
     artifact = (artifact.*kernel2);
%      plot(artifact,'r:')
      artlessSignal(fpt:lpt,:) = artlessSignal(fpt:lpt,:)-artifact; % + noise;
%      plot(artlessSignal(fpt:lpt,:),'k'), 
     
 %%%%%%%%%%%%%%%% 2nd iteration %%%%%%%%%%%%%%%%%%
      artifact = artlessSignal(fpt:lpt,:);
%       subplot(2,1,2), plot(artifact), hold on, xlim([-inf inf])
      kernel2 = gausswin(3*lenArt,3*alpha); % Making kernel longer than signal to accommodate for circhift coming up
      [~, kerMaxInd] = max(kernel,[],1);  
     [~,sigMaxInd] = max(abs(artifact),[],1);
    kernel2 = circshift(kernel2(:),sigMaxInd-kerMaxInd); % Shifting to align peak of kernel with peak of artifact
    kernel2([1:lenArt 2*lenArt+1:end])=[]; % Taking the central segment of kernel2 that matches signal in length
    kernel2 = (kernel2-min(kernel2))/(max(kernel2)-min(kernel2)); 
%     plot(kernel2*max(artifact),'c')
    kernel2 =  repmat(kernel2(:),1,size(signal,2)); 
     noise = noise.*kernel2;
     artifact = (artifact.*kernel2);
%      plot(artifact,'r:')
      artlessSignal(fpt:lpt,:) = artlessSignal(fpt:lpt,:)-artifact + noise;
%      plot(artlessSignal(fpt:lpt,:),'k'), 
       
end

