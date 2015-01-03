%% Plotting responses at different times to check for stationarity
tfl = 1;
if any(stimIsolGain == 0)
    figName = ['Response Stationarity for ' num2str(sa(end-tfl)) 'V stim'];
    figure('Name',figName)
    blah = trialMat{end-tfl};
    sigma = std(cell2mat(blah));
    blah_sm = trialMat_smooth{end-tfl};
    sigma_sm = std(cell2mat(blah_sm));
    for trial = 1:length(blah)
        subaxis(length(blah),1,trial,'MR',0.05, 'ML', 0.05,'MT', 0.05)
        for chan  = 1:numel(ePhysChannelToAnalyze)
            if chan > 1
                col = 'r';
            else
                col = 'b';
            end
            plot(segmentTime*1000, blah{trial}(:,chan)./sigma(chan) - (chan-1)*10, 'k')
            hold on
            plot(segmentTime*1000, blah_sm{trial}(:,chan)./sigma_sm(chan) - (chan-1)*10, col,'linewidth',2)
        end
        xlim(xLim), ylim([-20 40]), box off
        set(gca,'tickdir','out')
        if trial ~= length(blah)
            set(gca,'xtick',[], 'ytick',[])
        else
            xlabel('Time (ms)')
        end
    end
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

