

function artlessSignal = DeartifactWithGaussInterp(signal,samplingInt, stimInds,preStimPeriod, postStimPeriod,alpha)

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
% alpha = 2; % The larger the value, the broader the gaussian kernel 

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
    kernel2 = kernel2-min(kernel2);
    kernel2 = kernel2*max(kernel2);
    
    
    dt_max = 300; % Max interval with which to sample.
    dtVec = (dt_max-1)*(1-kernel2);
     dtVec = round(dtVec+1);
     
     
     art_interp = zeros(size(artifact));
     jj = 1;     
while jj < length(dtVec)
    halfSegInd = max(round(dtVec(jj)/2),1);   
    excess_right = jj + halfSegInd - length(artifact);
    if excess_right > 0
        firstInd = jj - halfSegInd - excess_right;
    else
        firstInd = jj-halfSegInd;        
    end
    if firstInd <= 0
        firstInd = jj;
    end
     excess_left =  halfSegInd -jj;
    if excess_left > 0
        lastInd =  jj  + halfSegInd + excess_left;
    else
        lastInd = jj + halfSegInd; % Do not exceed length of artifact
    end
    if lastInd > length(artifact)
        lastInd = length(artifact);
    end
    middleInd = round(median([firstInd lastInd]));
    time_sub = [firstInd middleInd lastInd];
%      disp(time_sub)
%     disp(['Range = ' num2str(time_sub(end)-time_sub(1))])
    art_sub = artifact(time_sub);
    time = firstInd:lastInd;
    art_interp(firstInd:lastInd) = interp1(time_sub, art_sub, time);
    jj = jj+ ceil(0.8*halfSegInd);    
end

 artlessSignal(fpt:lpt,:) = artifact-art_interp(:) + noise; 
     
   
     
%      bb = unique(round(cumsum(dtVec)));
%      
%     kernel2 = (kernel2 + (1/dt_max));
%     kernel2 = kernel2/(max(kernel2)-min(kernel2));
%     dtVec = round(1./kernel2);
%     bb = cumsum(dtVec(1:end-1));
%     bb = (bb-min(bb))/(max(bb)-min(bb));
%     bb = unique(round(bb * (length(kernel2)-1)+1));
% %      bb = round(bb * (length(kernel2)-1)+1);
    
%     art_sub = zeros(size(artifact));
%     art_sub(1) = artifact(1);
%     art_sub(end) = artifact(end);
%     for ind = 2:length(bb)-1
% %         art_sub(bb(ind-1):bb(ind+1)) = mean(artifact(bb(ind-1):bb(ind+1)));
%     t = bb(ind-1):bb(ind+1);
%     t_sub = [bb(ind-1) bb(ind) bb(ind+1)];
%     blah = [artifact(bb(ind-1)) artifact(bb(ind)) artifact(bb(ind+1))];
%         art_sub(bb(ind-1):bb(ind+1)) = interp1(t_sub, blah, t);
% %         art_sub(bb(ind-1):bb(ind+1)) = median(artifact(bb(ind-1):bb(ind+1)));
%     end
%     t = 1:length(artifact);
%     art_sub = artifact(bb);
%     t_sub = t(bb);
%     art_interp = interp1(t_sub,art_sub,t);
%    artlessSignal(fpt:lpt,:) = artifact-art_sub(:); % + noise;      
    
    
    
    
    
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
%       artlessSignal(fpt:lpt,:) = artlessSignal(fpt:lpt,:)-art_sub(:); % + noise;
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

