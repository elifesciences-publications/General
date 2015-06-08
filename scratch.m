
%% Finding stacks coincident with shocks
disp('Finding stacks coincident with shocks')
stack.inds.start = FindStimPulses(data.camTrigger,10,3.7,(exposureTime*stack.dim(3)*samplingRate),'exact');
if isempty(stack.inds.start)
    error('Camera trigger signal not detected!')
    return;
end
stack.times = data.t(stack.inds.start);
stack.N = numel(stack.times);
stack.interval = median(diff(stack.times(:)));
% stimChan = stimChannel(stimIsolGain~=0);

stack.inds.shock = zeros(size(stim.inds));
for cs = 1:numel(stim.inds)
    [~,stack.inds.shock(cs)] =  min(abs(stack.inds.start-stim.inds(cs)));
end
stack.inds.shock = unique(stack.inds.shock); % This is because cam trigger can terminate before ephys signals.







% %% Plot all trials in max stim int conditions
% maxIntTrials = find(tData.stimAmp == max(tData.stimAmp));
% for trial = 1:numel(maxIntTrials)
%     figure('Name',['Highest stim int, trial #' num2str(trial)]) 
%     plot(trialSegData(1).time,trialSegData(maxIntTrials(trial)).raw)
%     xlim([-5 12]), ylim([-1 1])
%     set(gca,'tickdir','out', 'ytick',[])
%     title([['Highest stim int, trial # ' num2str(trial)]],'fontsize',14)
%     xlabel('Time (sec)')
%     box off
% end


 %% Comparing results from both KMeans methods
% 
% tempMat1 = [];
% cIndMat1 = [];
% tempMat2 =[];
% cIndMat2 = [];
% for clstr = 1:10
%     cellsInCluster1 = find(kData1.idx==clstr);
% %     tempMat1 = [tempMat1; data.cellRespMat.trialAvg(cellsInCluster1,:,1,4)];
%     tempMat1 = [tempMat1; mean(data.cellRespMat.trialAvg(cellsInCluster1,:,1,4),1)];
%     cIndMat1 = [cIndMat1; kData1.idx(cellsInCluster1)];
%     cellsInCluster2 = find(kData2.idx == clstr);
%     tempMat2 = [tempMat2; data.cellRespMat.trialAvg(cellsInCluster2,:,1,4)];
%     cIndMat2 = [cIndMat2; kData2.idx(cellsInCluster2)];
% end
% % figure('Name','Method1')
% % imagesc(1:size(tempMat1,1),cIndMat1,tempMat1)
% % cLim = get(gca,'clim')
% % set(gca,'clim',[cLim(1)*0.2 cLim(2)*0.2])
% 
% figure('Name','Method2')
% imagesc(1:size(tempMat2,1),cIndMat2,tempMat2)
% cLim = get(gca,'clim')
% set(gca,'clim',[cLim(1)*0.2 cLim(2)*0.2])