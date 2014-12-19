%% Plotting VR responses for all intensity unilateral stimulation trials
fprintf('\n Plotting unilateral stimulation trials \n')
sc = stimChannel;
sc(stimIsolGain==0)=[];

for side = sc(:)'
    
    %%%%%%% Raw traces
    figure('Name',['Stim ' num2str(side) ' only'])
    stimConditions = [unilateralStimAmps{side}];
    stimConditions_unique = unique(stimConditions);
    blah ={};
    for sc = 1:numel(stimConditions_unique)
        inds = find(stimConditions == stimConditions_unique(sc));
        subplot(numel(stimConditions_unique),1,sc)
        blah = trialSegmentedData(unilateralStimTrialNums{side});
        for ci = inds(:)'
            thisSig = blah{ci};
            for thisChan = 1:size(thisSig,2)
                if thisChan < 2                
                 plot(segmentTime*1000, thisSig(:,thisChan));
                 hold on
                else
                   plot(segmentTime*1000, thisSig(:,thisChan),'r');
                 end
            end          
            xlim(xLim)
            ylim(yLim)
            title(['Stim Amp: ' num2str(stimConditions_unique(sc))])
            box off
            if sc < numel(stimConditions_unique)
                set(gca,'xtick',[],'ytick',[]);
            end
        end
        set(gca,'tickdir','out')
    end
    xlabel('Time (ms)')
    
    %%%%% Smoothed traces
    figure('Name',['Stim ' num2str(side) ' only'])
    blah ={};
    for sc = 1:numel(stimConditions_unique)
        inds = find(stimConditions == stimConditions_unique(sc));
        subplot(numel(stimConditions_unique),1,sc)
        blah = trialSegData_smooth(unilateralStimTrialNums{side});
        for ci = inds(:)'
             thisSig = blah{ci};
             for thisChan = 1:size(thisSig,2)
                if thisChan < 2                
                 plot(segmentTime*1000, thisSig(:,thisChan));
                 hold on
                else
                   plot(segmentTime*1000, thisSig(:,thisChan),'r');
                 end
            end       
                    
            xlim(xLim)
            %         ylim(yLim)
            ylim(yLim_smooth)
            title(['Stim Amp: ' num2str(stimConditions_unique(sc))])
            box off
            if sc < numel(stimConditions_unique)
                set(gca,'xtick',[],'ytick',[]);
            end
        end
        set(gca,'tickdir','out')
    end
    xlabel('Time (ms)')
    
    %%%%% Burst Trains
    figure('Name',['Stim ' num2str(side) ' only - Burst trains'])
    blah ={};
      for sc = 1:numel(stimConditions_unique)
        inds = find(stimConditions == stimConditions_unique(sc));
        subplot(numel(stimConditions_unique),1,sc)
        blah = trialSegBurstTrain(unilateralStimTrialNums{side});
        counter = 0;
        trialOffset = 0;
        for ci = inds(:)'
            counter = counter+1;
            trialOffset = trialOffset+1; % Leave a gap of 1 row between trials
            thisSig = blah{ci};
            thisSig(thisSig==0)=nan;            
            for thisChan = 1:size(thisSig,2)
                trainShift = (counter-1)*numel(ePhysChannelToAnalyze)+ thisChan + (trialOffset-1);                
                if thisChan <2
                     plot(segmentTime*1000, thisSig(:,thisChan)+trainShift,'b.','markersize',5);
                    hold on                   
                else
                    plot(segmentTime*1000, thisSig(:,thisChan)+trainShift,'r.','markersize',5);
                    hold on
                end
                if sc < numel(stimConditions_unique)
                    set(gca,'xtick',[]);
                end
                set(gca,'yTick',[])
                xlim(xLim)
                ylim([0 trainShift+2])
                title(['Stim Amp: ' num2str(stimConditions_unique(sc))])
                box off
                set(gca,'tickdir','out')
            end
        end
    end
    ylabel('Trial Num')
    xlabel('Time (ms)')
end
