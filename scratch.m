










%% Finding swimming onset and frequency for each trial
fprintf('\n Determining swimming onset and freq for each stim evoked episode \n')
fpt = find(segmentTime>=(5e-3),1,'first'); % Start looking at trial from this many ms after stim
lpt = find(segmentTime >=(1000e-3),1,'first'); % Look at all bursts upto this time pt after stim
burstOnsetTimeLim = 100e-3;% Assume burst with onset after this time is not stim-evoked

swimOnset = zeros(numel(stimInds),numel(ePhysChannelToAnalyze));
swimFreq = zeros(numel(stimInds),numel(ePhysChannelToAnalyze));
swimFreq_wave = zeros(numel(stimInds),1);
% tFreq_wave = swimFreq_wave;
for trial = 1:numel(stimInds)
    bI={};
    blah = trialSegBurstTrain{trial}(fpt:lpt,:);
    currentTVFreqTrace = trialSegTVFreq{trial}(fpt:lpt,:);
    nB = sum(blah,1);
    swimFreq_wave(trial) = max(currentTVFreqTrace);
    if (min(nB)/max(nB)>=0.5) & sum(nB)> 0;
        for cc = 1:size(blah,2)            
            bI{cc} = find(blah(:,cc));
            if numel(bI{cc}) < 2 % At least 2 bursts to call something a swim episode
                swimOnset(trial,cc) = 0;
                swimFreq(trial,cc) = 0;
            else
                swimOnset(trial,cc) = (bI{cc}(1)*samplingInt) + 5e-3;
                swimFreq(trial,cc) = 1/(min(diff(bI{cc}))*samplingInt); % Reciprocal of shortest inter-burst-interval
                
                if swimOnset(trial,cc) > burstOnsetTimeLim
                % Ignoring trials where 1st burst occurs later than 100 ms
                    swimOnset(trial,cc) = 0;
                    swimFreq(trial,cc)=0;
                end
                
                % Ignoring trials with freq less than 10Hz
                if swimFreq(trial,cc) < 10;
                    swimFreq(trial,cc) = 0;
                    swimOnset(trial,cc) = 0;
                end
            end
        end
    elseif sum(nB)==0
        swimOnset(trial,:) = 0;
        swimFreq(trial,:)=0;
    else
        betterChannel = find(nB == max(nB)); % Use signal with more bursts
%         blah = blah(:,betterChannel);
        bI{betterChannel} = find(blah(:,betterChannel));
        if numel(bI{:})<2 % At least 2 bursts to cell something a swim episode
            swimOnset(trial,betterChannel) = 0;
            swimFreq(trial,betterChannel) = 0;
        else
            swimOnset(trial,betterChannel) = (bI{:}(1)*samplingInt) + 5e-3;
            swimFreq(trial,betterChannel) = 1/(min(diff(bI{betterChannel}))*samplingInt);
            
            % Ignoring trials where 1st burst occurs later than 100 ms
            if swimOnset(trial,betterChannel) > burstOnsetTimeLim
                swimOnset(trial,betterChannel) = 0;
                swimFreq(trial,betterChannel)=0;
            end
            
            % Ignoring trials with freq less than 10Hz
            if swimFreq(trial,betterChannel) < 10;
                swimFreq(trial,betterChannel) = 0;
                swimOnset(trial,betterChannel) = 0;
            end
        end
    end
end



























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
%                    trainShift = (trialNum-1)*jj + jj;
%                    plot(segmentTime*1000, blah(jj,:)-trainShift,'b.')
%                    hold on
%                elseif (numel(ePhysChannelToAnalyze) > 1) & (jj == numel(ePhysChannelToAnalyze))
%                  plot(segmentTime*1000, blah(jj,:)-trainShift,'r.')
%                  hold on
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
%     
%     
%     
%     for sc = 1:numel(stimConditions_unique)
%         inds = find(stimConditions == stimConditions_unique(sc));
%         subaxis(numel(stimConditions_unique),1,sc,'MR',0.05, 'ML', 0.05,'MT', 0.05)
%         blah = trialSegBurstTrain(unilateralStimTrialNums{side});
%         counter = 0;
%         trialOffset = 0;
%         for ci = inds(:)'
%             counter = counter+1;
%             trialOffset = trialOffset+2; % Leave a gap of 1 row between trials
%             thisSig = blah{ci};
%             thisSig(thisSig==0)=nan;
%             for thisChan = 1:size(thisSig,2)
%                 trainShift = (counter-1)*numel(ePhysChannelToAnalyze)+ thisChan + (trialOffset-1);
%                 if thisChan <2
%                     plot(segmentTime*1000, thisSig(:,thisChan)+trainShift,'bo','markersize',2.8,'markerfacecolor','b');
%                     hold on
%                     %                      plot(segmentTime*1000, thisSig(:,thisChan)+trainShift,'bo','markersize',3,'markerfacecolor','b');
%                 else
%                     plot(segmentTime*1000, thisSig(:,thisChan)+trainShift,'ro','markersize',2.8,'markerfacecolor','r');
%                     hold on
%                 end
%                 if sc < numel(stimConditions_unique)
%                     set(gca,'xtick',[]);
%                 end
%                 set(gca,'yTick',[])
%                 xlim(xLim)
%                 ylim([0 trainShift+2])
%                 title(['Stim Amp: ' num2str(stimConditions_unique(sc))])
%                 box off
%                 set(gca,'tickdir','out')
%             end
%         end
%     end
%     ylabel('Trial Num')
%     xlabel('Time (ms)')
% end
