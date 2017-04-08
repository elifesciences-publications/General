
pkThr = 0.5;
polarity = 1;
thrType = 'rel';
minPkDist = round(15*6000);
prePer = 0.5;
postPer = 1;
lpf = 100;


pks = GetPks(data.patch2,'polarity',polarity,'peakThr',pkThr,...
    'thrType',thrType,'minPkDist',minPkDist);

rp = randperm(length(pks));
spikeInds = pks(rp(1:3));
spikeTimes = data.t(spikeInds);
raw = zscore(data.ch2);
smooth = zscore(SmoothVRSignals(raw,1/6000,lpf));
raw_trl = SegmentDataByEvents(raw,1/6000,spikeInds,prePer,postPer);
patch = zscore(data.patch2);
patch_trl = SegmentDataByEvents(patch,1/6000,spikeInds,prePer,postPer);
smooth_trl = SegmentDataByEvents(smooth,1/6000,spikeInds,prePer, postPer);
time_trl = SegmentDataByEvents(data.t,1/6000,spikeInds,prePer,postPer);

% figure
% plot(data.t,data.patch2)
% hold on
% plot(data.t(pks),data.patch2(pks),'ro')


f1 = figure('Name','Trigeminal-elicited escapes');
f2 = figure('Name', 'Trigeminal-elicited escapes (smoothed)');
yShift = 60;
yOff  = nan(length(spikeTimes),1);
for ss = 1:length(spikeTimes)
    offset = yShift*(ss-1);
    yOff(ss) = offset;
    figure(f1)
    plot(time_trl{ss}-spikeTimes(ss),raw_trl{ss}-offset,'k')
    hold on
    plot(time_trl{ss}-spikeTimes(ss),2*patch_trl{ss}-offset,'r')
    
    figure(f2)
    l1 = plot(time_trl{ss}-spikeTimes(ss),zscore(smooth_trl{ss})-offset*0.75,'b');
    hold on
    l2 =  plot(time_trl{ss}-spikeTimes(ss),2*patch_trl{ss}-offset*0.75,'r');
   
end
figure(f1)
box off
set(gca,'tickdir','out','ytick',sort(-yOff),'yticklabel',length(spikeInds):-1:1)
xlim([-inf inf])
ylim([-inf inf])
xlabel('Time (sec)')
ylabel('Trials')
legend('Contra')

figure(f2)
box off
set(gca,'tickdir','out','ytick',sort(-yOff),'yticklabel',length(spikeInds):-1:1)
xlim([-inf inf])
ylim([-inf inf])
xlabel('Time (sec)')
ylabel('Trials')
legend([l1,l2],'Contra EMG','M-Cell');


