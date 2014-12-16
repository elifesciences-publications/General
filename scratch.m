

%% Plotting Stim Freq and Stim Onset for unilateral stimulation conditions
fprintf('\n Plotting swimming frequency and onset vs intensity for unilateral stim trials \n')
if any(stimIsolGain==0) % For the time being, only plotting for single sided stimulation
    figure('Name','Swim Freq & Onset vs Stim Intensity')
    f = find(stimIsolGain~=0);
    sc = unique(stimAmp(f,:));
    xLim2 = [min(sc) max(sc)];
    sa = unique(stimAmp(f,:));
    for cc = 1:numel(ePhysChannelToAnalyze)
        badInd = find(isnan(freqMat_mat(:,:,cc)));
        freqMat_mat_short = freqMat_mat(:,:,cc); freqMat_mat_short(badInd)=[];
        sfMat_short = sfMat(:,:,cc); sfMat_short(badInd) = [];
        nfMat_short = nfMat(:,:,cc); nfMat_short(badInd)=[];
        sa_short = sa; sa_short(badInd)=[];
        %     markerSize = 1.5*(nfMat_short/min(nfMat_short(:)));
        subplot(2,1,1)
        for jj = 1:numel(sa_short)
            temp = freqMat(:,:,cc);
            temp(badInd) =[];
            blah = temp{jj};
            blah(blah==0)=[];
            sa_temp = ones(size(blah))*sa_short(jj);
            if cc ==1,
                plot(sa_temp,blah,'b.')
                 hold on
                plot(sa_short(jj),freqMat_mat_short(jj),'bo')
            else
                plot(sa_temp,blah,'r.')
                hold on
                plot(sa_short(jj),freqMat_mat_short(jj),'ro')
            end         
       end
        plot(sa_short,freqMat_mat_short,'k')
        xlim([xLim2(1)-2 xLim2(2)+2]), ylim([-inf inf]), box off
        set(gca,'tickdir','out')
        ylabel('Swim Frequency (Hz)')
        title('Swim Freq vs Stim Int')
        
        
        onMat_mat_short = onMat_mat(:,:,cc); onMat_mat_short(badInd)=[];
        soMat_short = soMat(:,:,cc); soMat_short(badInd)=[];
        noMat_short = noMat(:,:,cc); noMat_short(badInd)=[];
        %     markerSize = 1.5*(noMat_short/min(noMat_short(:)));
        subplot(2,1,2)
        for jj = 1:numel(sa_short)
            temp = onMat(:,:,cc);
            temp(badInd) = [];
            blah = temp{jj}*1000; % Converting to ms
            blah(blah==0)=[];
            sa_temp = ones(size(blah))*sa_short(jj);
             if cc ==1,
                plot(sa_temp,blah,'b.')
                hold on
                 plot(sa_short(jj),onMat_mat_short(jj),'bo')
            else
                plot(sa_temp,blah,'r.')
                  hold on
                 plot(sa_short(jj),onMat_mat_short(jj),'ro')
            end
          legend('Raw data points', 'Mean values')
            %         errorbar(sa_short(jj),onMat_mat_short(jj),soMat_short(jj),'r')
        end
        plot(sa_short,onMat_mat_short,'k')
        xlim([xLim2(1)-2 xLim2(2)+2]), ylim([-inf inf]), box off
        set(gca,'tickdir','out')
        ylabel('Swim Onset (ms)')                
    end       
end







