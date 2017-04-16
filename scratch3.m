
%% Plot a few trials to test the performance of the hht_dy
cMap = viridis(128);
tRange = [-50 300];
fish = grpData.mHom.ctrl.vib.procData{1};
W = fish.W;
time = W.time;
inds = find(time>=tRange(1) & time<=tRange(2));
freq = W.freq;
freqRange = [min(freq) max(freq)];
nTrls = length(W.curv.ts);
[~,zerInd] = min(abs(time-0));
t_stim = time(zerInd);
close all
W_avg = 0;
H1_avg = 0;
H2_avg = 0;
for trl = 1:nTrls
    ts = W.curv.ts{trl};
    w = W.curv.coeff{trl};
    W_avg = W_avg + w;
    figure
    subaxis(3,1,1)
    imagesc(time(inds),freq,w(:,inds).^2)
    set(gca,'ydir','normal')
    hold on
    plot([t_stim, t_stim],[min(freq),max(freq)],'r--')
    colormap(cMap)
    title(num2str(trl))
    ylabel('W')
    
    [H1,H2,~,freqH] = hht_dy(ts,1e-3*(time(2)-time(1)),'freqRange',freqRange,...
        'plotBool',0, 'tKerWid',1, 'fKerWid',40,'energyThr',0.05);
    H1_avg = H1_avg + H1;
    H2_avg = H2_avg + H2;
    
    subaxis(3,1,2)
    imagesc(time(inds),freqH,H1(:,inds).^2), colormap(cMap)
    set(gca,'ydir','normal')
    hold on
    plot([t_stim, t_stim],[min(freqH),max(freqH)],'r--')
    ylabel('H1')
    
    subaxis(3,1,3)
    imagesc(time(inds),freqH,H2(:,inds).^2), colormap(cMap)
    set(gca,'ydir','normal')
    hold on
    plot([t_stim, t_stim],[min(freqH),max(freqH)],'r--')
    ylabel('H2')
end
W_avg = W_avg/nTrls;
H1_avg = H1_avg/nTrls;
H2_avg = H2_avg/nTrls;

figure('Name','Averages')
subaxis(3,1,1)
imagesc(time(inds),freq,W_avg(:,inds)); colormap(cMap)
hold on
set(gca,'ydir','normal')
plot([t_stim, t_stim],[min(freq),max(freq)],'r--')
ylabel('W_{avg}')

subaxis(3,1,2)
imagesc(time(inds),freq,H1_avg(:,inds)); colormap(cMap)
set(gca,'ydir','normal')
hold on
plot([t_stim, t_stim],[min(freqH),max(freqH)],'r--')
ylabel('H1_{avg}')

subaxis(3,1,3)
imagesc(time(inds),freq,H2_avg(:,inds)); colormap(cMap)
hold on
plot([t_stim, t_stim],[min(freqH),max(freqH)],'r--')
set(gca,'ydir','normal')
ylabel('H2_{avg}')
