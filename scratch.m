
art_sub = zeros(size(artifact));
for jj = 1:length(dtVec)
    halfSegInd = round(dtVec(jj)/2);
    lpt = min(jj + halfSegInd, length(artifact)); % Do not exceed length of artifact
    excess = jj + halfSegInd - length(artifact);
    if excess > 0
        fpt = max((jj - excess - halfSegInd),1);
    else
        fpt = max(jj-halfSegInd,1);
    end
    mpt = median([fpt lpt]);
    time_sub = [fpt mpt lpt];
    art_sub = artifact(time_sub);
    time = fpt:lpt;
    cc(fpt:lpt) = interp1(time_sub, art_sub, time);
end

















% 
%     
%     %%%%% Burst Trains - Alternative procedure...
%     figure('Name',['Stim ' num2str(side) ' only - Burst trains'])
%      interTrialGap = 1; % # of blank rows to insert between trials (Cannot be a fraction!)
%     dim = find((size(burstTrainMat)~=1));
%     for sc =1:size(burstTrainMat,dim)
%         subaxis(size(burstTrainMat,dim),1,sc)
%         theseTrials = burstTrainMat{sc};
%         tempMat = zeros(numel(ePhysChannelToAnalyze)*length(theseTrials) + (interTrialGap*length(theseTrials))-1,length(theseTrials{1}));
%        counter = 0;
%         for trialNum = 1:numel(ePhysChannelToAnalyze)+interTrialGap:size(tempMat,1)
%             counter = counter+1;
%             tempMat(trialNum:(trialNum-1)+numel(ePhysChannelToAnalyze)+interTrialGap,:) = [theseTrials{counter}'; zeros(1,length(theseTrials{1}))];                                 
%             % Raster plotting bursts
%             blah =  tempMat(trialNum:(trialNum-1)+numel(ePhysChannelToAnalyze)+interTrialGap,:);
%             blah(blah==0)=nan;
%             for jj = 1:size(blah,1)
%                if (numel(ePhysChannelToAnalyze) ==1) && (jj <= numel(ePhysChannelToAnalyze))
% %                    trainShift = (trialNum-1)*jj + jj;
% %                    plot(segmentTime*1000, blah(jj,:)-trainShift,'b.')
% %                    hold on
%                elseif (numel(ePhysChannelToAnalyze) > 1) & (jj == numel(ePhysChannelToAnalyze))
% %                  plot(segmentTime*1000, blah(jj,:)-trainShift,'r.')
% %                  hold on
%               end
%             end 
%            box off, xlim([-50 750]), ylim([-inf inf])
%             if sc == size(burstTrainMat,dim)              
%                  set(gca,'tickdir','out','ytick',[])
%                  xlabel('Time (ms)')
%                  ylabel('Trial Num')
%             else
%                  set(gca,'tickdir','out','ytick',[],'xtick',[])
%             end
%         end
%              
%     end
% %     
%     

