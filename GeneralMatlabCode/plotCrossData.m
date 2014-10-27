fields=fieldnames(dataStruct);
nFields=size(fields,1);
for k = 1:nFields;
%     figure('Name',fields{k})
    temp=chebfilt(dataStruct(1).(fields{k}),samplingInt,50,'high');
    blah=timeAxisStruct.(fields{k});
    blah2=smoothTimeAxisStruct.(fields{k});
    dummy=100:100:(size(temp,2))*100;
    offSetMat1=repmat(dummy,size(temp,1),1);
    temp=temp-offSetMat1;
    temp2=smoothStruct(1).(fields{k});
    temp2=temp2*100;
    offSetMat2=repmat(dummy,size(temp2,1),1);
    temp2=temp2-offSetMat2;
    subplot(nFields,1,k),plot(blah,temp);
    xlim([-1 10]),ylim([-500 0])
    box off,axis off;
    hold on,
    subplot(nFields,1,k),plot(blah2,temp2,'k','Linewidth',1.5);
    hold off;
 end