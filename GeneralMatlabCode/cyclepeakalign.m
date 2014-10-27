

signal = zscore(signal5); % To standardize across signals
time = time(:);
nChannels = min(size(signal));  

peakDetectionThresh = 0.4; % Input for peakdet.m
dt = mode(diff(time));
preLightPeriod = [0 62]; % Time period in sec
lightPeriod = [63 122];
postLightPeriod = [123 time(end)-2*dt]; % Note that this period is shorter
cycleFraction = 0.5;

%% Estimating Cycle Length of Dominant Frequency
[fourierPow,fourierFreq] = my_fft(signal,dt);
fourierPow = prod(fourierPow,2).^(1/nChannels);
fpt = find(fourierFreq>0.15);
lpt = find(fourierFreq>=4,1); % Frequency filtering to eliminate spurious freq peaks
fourierPow = fourierPow(fpt:lpt);
fourierFreq = fourierFreq(fpt:lpt);
fourierPow = fourierPow/max(fourierPow);
[maxtab,mintab] = peakdet(fourierPow,peakDetectionThresh);
if isempty(maxtab)
    errordlg('Peak Freq Not Detected: Lower Peak Detection Threshold');
    break
end

maxFreqPt = find(maxtab(:,2)==max(maxtab(:,2)));
dominantFreq = fourierFreq(maxtab(maxFreqPt,1));
cycleTime = 1/dominantFreq;
partialCyclePts = ceil(cycleFraction*cycleTime/samplingInt);

clear preLightSignal preLightTime preLightPeakIndices
clear lightSignal lightTime lightPeakIndices
clear  peakPts peakTimes peakAmplitudes
clear preLightStd preLightMean
clear lightStd lightMean
clear postLightSignal postLightTime postLightPeakIndices
clear postLightStd postLightMean
clear preLightMat lightMat postLightMat
% preLightMat = zeros(numel(loopPts),(2*partialCyclePts)+1,nChannels);
% lightMat = zeros(numel(loopPts),(2*partialCyclePts)+1,nChannels);
% postLightMat = zeros(numel(loopPts),(2*partialCyclePts)+1,nChannels);
for kk = 1:nChannels
%% Finding the Peaks of the Timeseries Signal
% fpt = find(time>=(time(1)+1),1); % Ignoring first 1 sec to avoid peak detection errors
% lpt = floor((time(end)-1.5)/samplingInt); % Ignoring last 1.5 sec for the same reason
clear maxtab mintab
[maxtab, mintab]= peakdet(signal(:,kk),peakDetectionThresh);
if isempty(maxtab)
    errordlg('Signal Peaks Not Detected: Lower Peak Detection Threshold');
end
maxtab([1 2 end],:) = []; % Ignoring first and last peak to avoid edge-related problems

peakPts{1,kk} = maxtab(:,1);
peakTimes{1,kk} = time(maxtab(:,1));
peakAmplitudes{1,kk} = maxtab(:,2);

%% Cutting the Signal up into Pre-, During- and Post-Light Periods
%%%%% Pre-Light Period
fpt = find(time>=preLightPeriod(1),1);
lpt = find(time>=preLightPeriod(2),1);
preLightSignal(:,kk) = signal(fpt:lpt,kk);
preLightTime(:,kk) = time(fpt:lpt);
loopPts = find(peakPts{1,kk}>=fpt & peakPts{1,kk}<=lpt);
preLightPeakIndices{1,kk} = peakPts{1,kk}(loopPts);
for cc = 1:numel(loopPts)
    preLightMat{1,kk}(:,cc) = signal(preLightPeakIndices{1,kk}(cc)-partialCyclePts : preLightPeakIndices{1,kk}(cc)+partialCyclePts,kk);
    mp = round(size(preLightMat{1,kk}(:,cc),1)/2);
    ep = round(mp/10);
    m = max(preLightMat{1,kk}(mp-ep:mp+ep,cc),[],1);
    preLightMat{1,kk}(:,cc) = preLightMat{1,kk}(:,cc)-m + 10;
end
preLightStd{:,kk} = std(preLightMat{1,kk}(:,:),0,2);
preLightMean{:,kk} =  mean(preLightMat{1,kk}(:,:),2);

%%%%% Light Period %%%%%
fpt =  find(time>=lightPeriod(1),1);
lpt = find(time>=lightPeriod(2),1);
lightSignal(:,kk) = signal(fpt:lpt,kk);
lightTime(:,kk) = time(fpt:lpt);
loopPts = find(peakPts{1,kk}>=fpt & peakPts{1,kk}<=lpt);
lightPeakIndices{1,kk} = peakPts{1,kk}(loopPts);
for cc = 1:numel(loopPts)
    lightMat{1,kk}(:,cc) = signal(lightPeakIndices{1,kk}(cc)-partialCyclePts : lightPeakIndices{1,kk}(cc)+partialCyclePts,kk);
     mp = round(size(lightMat{1,kk}(:,cc),1)/2);
    ep = round(mp/10);
    m = max(lightMat{1,kk}(mp-ep:mp+ep,cc),[],1);
    lightMat{1,kk}(:,cc) = lightMat{1,kk}(:,cc)-m + 10;
end
lightStd{:,kk} = std(lightMat{1,kk}(:,:),0,2);
lightMean{:,kk} =  mean(lightMat{1,kk}(:,:),2);

%%%%% Post-Light Period %%%%%
fpt =  find(time>=postLightPeriod(1),1);
lpt = find(time>=postLightPeriod(2),1);
postLightSignal(:,kk) = signal(fpt:lpt,kk);
postLightTime(:,kk) = time(fpt:lpt);
loopPts = find(peakPts{1,kk}>=fpt & peakPts{1,kk}<=lpt);
postLightPeakIndices{1,kk} = peakPts{1,kk}(loopPts);
for cc = 1:numel(loopPts)
    postLightMat{1,kk}(:,cc) = signal(postLightPeakIndices{1,kk}(cc)-partialCyclePts : postLightPeakIndices{1,kk}(cc)+partialCyclePts,kk);
     mp = round(size(postLightMat{1,kk}(:,cc),1)/2);
    ep = round(mp/10);
    m = max(postLightMat{1,kk}(mp-ep:mp+ep,cc),[],1);
    postLightMat{1,kk}(:,cc) = postLightMat{1,kk}(:,cc)-m + 10;
end
postLightStd{:,kk} = std(postLightMat{1,kk}(:,:),0,2);
postLightMean{:,kk} =  mean(postLightMat{1,kk}(:,:),2);

peakAlignedTime = (-partialCyclePts:partialCyclePts)*samplingInt;
%% Plotting the Signal with Pre-,During-, and Post-Light Cycle Peaks Detected
figName = ['Signal # ' num2str(kk) ' with Detected Peaks'];
fh = figure('Name',figName,'color','w');
monSize = getMonitorSize;
set(fh,'position',[monSize(1)+50 monSize(2)+150 monSize(3)-150 monSize(4)-300]);
plot(time,signal(:,kk),'k'), box off
set(gca,'fontsize',14)
xlabel('Time (sec)')
ylabel('Amplitude (z-score)')
axis([-inf inf -inf 4])
hold on
plot(time(preLightPeakIndices{1,kk}),signal(preLightPeakIndices{1,kk},kk),'bo')
plot(time(lightPeakIndices{1,kk}),signal(lightPeakIndices{1,kk},kk),'go')
plot(time(postLightPeakIndices{1,kk}),signal(postLightPeakIndices{1,kk},kk),'ro')
leg = legend('Signal','Pre-light Peaks','During-light Peaks','Post-light Peaks');
set(leg,'fontsize',14,'location','best')

%% Plotting Peak-Aligned Individual Cycle & the Average
figName = ['Signal # ' num2str(kk) 'Separated into Pre-, During-, & Post-Light Peaks'];
fh = figure('Name',figName,'color','w');
subplot(3,1,1), plot(peakAlignedTime,preLightMat{1,kk}(:,:),'k'),box off
hold on
plot(peakAlignedTime,preLightMean{1,kk},'r','linewidth',2), hold off
axis([-inf inf -inf 11])
set(gca,'xtick',[],'ytick',[],'xcolor','w','ycolor','w')
title('Pre-Light Cycles')

subplot(3,1,2), plot(peakAlignedTime,lightMat{1,kk}(:,:),'k'),box off
title('During-Light Cycles')
hold on
plot(peakAlignedTime,lightMean{1,kk},'r','linewidth',2), hold off
axis([-inf inf -inf 11])
set(gca,'xtick',[],'ytick',[8 10],'xcolor','w')
ylabel('Amplitude (z-score)')

subplot(3,1,3), plot(peakAlignedTime,postLightMat{1,kk}(:,:),'k'),box off
title('Post-Light Cycles')
hold on
plot(peakAlignedTime,postLightMean{1,kk},'r','linewidth',2), 
axis([-inf inf -inf 11])
set(gca,'xtick',[-0.5 0 0.5],'ytick',[],'ycolor','w')
xlabel('Time (sec)')
hold off

%% Superimposing the Average Cycles from the Three Time Periods
figName = ['Signal # ' num2str(kk) ' Overlaid Avg Cycles from the 3 Time Periods'];
fh = figure('Name',figName,'color','w');
title('Overlaid Average Cycles')
title('Overlaid Avg Cycle Periods')
plot(peakAlignedTime,preLightMean{1,kk},'b','linewidth',2), box off
hold on
plot(peakAlignedTime, lightMean{1,kk},'g:','linewidth',2)
plot(peakAlignedTime,postLightMean{:,kk},'r:','linewidth',2)
legend('Pre-Light','During-Light','Post-Light')
set(gca,'tickdir','out')
xlabel('Time (sec)')
ylabel('Amplitude (z-score)')
axis([-inf inf -inf 10.5])

end