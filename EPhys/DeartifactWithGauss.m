

function artlessSignal = DeartifactWithGauss(signal,samplingInt, stimInds,preStimPeriod, postStimPeriod, alpha)

% DeartifactWithGauss - Remove stimulus artifacts. In contrast to
%                      Deartifact, subtracts Gaussian-modulated artifact for selected time
%                       period and also adds some Hamming modulated noise
%   data_mod = DeartifactWithGauss(data,samplingInt,stimIndices,preStimPeriod, postStimPeriod, alpha); 
%   data - signal vector
%   timeAxis - time vector
%   preStimPeriod - time period before stimulus in which artifact is
%                   considered to have influence (due to filtering, etc)
%   postStimPeriod - time period after stimulus in which artifact is
%                     considered to have influence
%   alpha - Gaussian shape parameter, larger values produce narrower
%            gaussian
 
if size(signal,1) < size(signal,2)
    signal = signal';
end

preStimPts = round(preStimPeriod/samplingInt);
postStimPts = round(postStimPeriod/samplingInt);

artlessSignal = signal;
noiseLevel = 0.05*std(artlessSignal,[],1);

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
     
%     sigMaxInd = kerMaxInd;
    
    kernel2 = circshift(kernel2(:),sigMaxInd-kerMaxInd); % Shifting to align peak of kernel with peak of artifact
    kernel2([1:lenArt 2*lenArt+1:end])=[]; % Taking the central segment of kernel2 that matches signal in length
    kernel2 = (kernel2-min(kernel2))/(max(kernel2)-min(kernel2)); 
    
    %%%% Testing gaussian translation
    % This is another way of doing it without circshift
%         t = linspace(-(lenArt-1)/lenArt, (lenArt-1)/lenArt, lenArt);
%         [~,midPt] = min(abs(t-0));
%          tau = t(midPt-(sigMaxInd-kerMaxInd));
%         kernel3 = exp(-0.5*(alpha*(t+tau)).^2);
% 
%         kernel3 = (kernel3-min(kernel3))/(max(kernel3)-min(kernel3));
%         figure
%         plot(kernel2)
%         hold on
%         plot(kernel3,'r:')
    %%%% End of test
    
%     plot(kernel2*max(artifact),'c')
    kernel2 =  repmat(kernel2(:),1,size(signal,2)); 
     noise = noise.*kernel2;
     artifact = (artifact.*kernel2);
%      plot(artifact,'r:')
      artlessSignal(fpt:lpt,:) = artlessSignal(fpt:lpt,:)-artifact; % + noise;
%      plot(artlessSignal(fpt:lpt,:),'k'), 
     
 %%%%%%%%%%%%%%%% 2nd iteration %%%%%%%%%%%%%%%%%%

    
%       artifact = artlessSignal(fpt:lpt,:);
%       artifact = chebfilt(artifact,samplingInt,100,'high');
% 
%      
%      kernel2 = gausswin(3*lenArt,4.5*alpha); % In second iteration, reducing the width of the Gaussian
%       [~, kerMaxInd] = max(kernel,[],1);  
%      [~,sigMaxInd] = max(abs(artifact),[],1);
%     kernel2 = circshift(kernel2(:),sigMaxInd-kerMaxInd); % Shifting to align peak of kernel with peak of artifact
%     kernel2([1:lenArt 2*lenArt+1:end])=[]; % Taking the central segment of kernel2 that matches signal in length
%     kernel2 = (kernel2-min(kernel2))/(max(kernel2)-min(kernel2)); 
% % %     plot(kernel2*max(artifact),'c')
%     kernel2 =  repmat(kernel2(:),1,size(signal,2)); 
%      noise = noise.*kernel2;
%      artifact = (artifact.*kernel2);
% % %      plot(artifact,'r:')
%       artlessSignal(fpt:lpt,:) = artlessSignal(fpt:lpt,:)-artifact + noise;
% %      plot(artlessSignal(fpt:lpt,:),'k'), 
%        
end

