thresh=2*std(data);
supThreshData = data(find(data>thresh));
indexSupThresh =find(data>thresh);

dData=diff(data);
dData(end+1)=mean(dData);
d2Data=diff(dData);
d2Data([end+1 end+2])=0;
indexPeaks_from_zero_slope=find(data>thresh & dData==0);
indexPeaks_from_sign_switch=find(dData(1:end-1)>0 & dData(2:end)<0)

% peakSupThreshData= supThreshData(find(d2Data)+2);
indexVec=1:length(data);
interPeakIntervals = diff(indexpeaks);