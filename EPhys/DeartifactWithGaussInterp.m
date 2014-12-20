

function artlessSignal = DeartifactWithGaussInterp(signal,samplingInt, stimInds,preStimPeriod, postStimPeriod)

% DeartifactWithGaussInterp - Remove stimulus artifacts by Gaussian sampling interpolation near the artifact. 
%                       period and also adds some Hamming modulated noise
%   data_mod = DeartifactWithGaussInterp(data,samplingInt,stimIndices,preStimPeriod, postStimPeriod); 
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
noiseLevel = 0.05*std(artlessSignal,[],1);

for stim = 1:numel(stimInds)
    %%%%%%%%% First iteration %%%%%%%%%%
    artifact =[];
    fpt = round(max(stimInds(stim)-preStimPts,1));
    lpt = round(min(stimInds(stim) + postStimPts, length(signal)));
    noise = repmat(noiseLevel,numel(fpt:lpt),1);
   noise = noise.*randn(size(noise));
    artifact = signal(fpt:lpt,:);
    lenArt = length(fpt:lpt);    
    kernel = gausswin(lenArt,alpha);      
     kernel2 = gausswin(3*lenArt,3*alpha); % Making kernel longer than signal to accommodate for circhift coming up
      [~, kerMaxInd] = max(kernel,[],1);  
     [~,sigMaxInd] = max(abs(artifact),[],1);    
       
    kernel2 = circshift(kernel2(:),sigMaxInd-kerMaxInd); % Shifting to align peak of kernel with peak of artifact
    kernel2([1:lenArt 2*lenArt+1:end])=[]; % Taking the central segment of kernel2 that matches signal in length
    kernel2 = (kernel2-min(kernel2))/(max(kernel2)-min(kernel2)); 
    
    dt_max = 100; % Max interval with which to sample.
    kernel2 = (kernel2 + (1/dt_max));
    kernel2 = kernel2/(max(kernel2)-min(kernel2));
    dtVec = round(1./kernel2);
    bb = cumsum(dtVec(1:end-1));
    bb = (bb-min(bb))/(max(bb)-min(bb));
    bb = unique(round(bb * (length(kernel2)-1)+1));
    
    
    t = 1:length(artifact);
    art_sub = artifact(bb);
    t_sub = t(bb);
    art_interp = interp1(t_sub,art_sub,t);
       
    
    
    
    
    
    %%%% Alternative method : translation of Gaussian kernel
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
    
%     kernel2 =  repmat(kernel2(:),1,size(signal,2)); 
%      noise = noise.*kernel2;
%      artifact = (artifact.*kernel2);
%      plot(artifact,'r:')
      artlessSignal(fpt:lpt,:) = artlessSignal(fpt:lpt,:)-art_interp(:); % + noise;
%      plot(artlessSignal(fpt:lpt,:),'k'), 
     
%  %%%%%%%%%%%%%%%% 2nd iteration %%%%%%%%%%%%%%%%%%
%       artifact = artlessSignal(fpt:lpt,:);
% %       subplot(2,1,2), plot(artifact), hold on, xlim([-inf inf])
%       kernel2 = gausswin(3*lenArt,3*alpha); % Making kernel longer than signal to accommodate for circhift coming up
%       [~, kerMaxInd] = max(kernel,[],1);  
%      [~,sigMaxInd] = max(abs(artifact),[],1);
%     kernel2 = circshift(kernel2(:),sigMaxInd-kerMaxInd); % Shifting to align peak of kernel with peak of artifact
%     kernel2([1:lenArt 2*lenArt+1:end])=[]; % Taking the central segment of kernel2 that matches signal in length
%     kernel2 = (kernel2-min(kernel2))/(max(kernel2)-min(kernel2)); 
% %     plot(kernel2*max(artifact),'c')
%     kernel2 =  repmat(kernel2(:),1,size(signal,2)); 
%      noise = noise.*kernel2;
%      artifact = (artifact.*kernel2);
% %      plot(artifact,'r:')
%       artlessSignal(fpt:lpt,:) = artlessSignal(fpt:lpt,:)-artifact + noise;
% %      plot(artlessSignal(fpt:lpt,:),'k'), 
       
end

