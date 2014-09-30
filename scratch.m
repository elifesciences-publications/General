prompt={'Enter the starting time point','Enter the ending time point'};
name='Truncating data';
numlines=1;
defaultanswer={'0','50'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
fTime=str2double(answer{1});
lTime=str2double(answer{2});
[handles.zData,handles.timeAxis]= truncateData(handles.zData,...
    handles.SamplingInt,[fTime lTime]);
m=0;
for k=1:handles.nSignals,
    m = m+1;
    subplot(handles.nSignals,1,k),plot(handles.timeAxis,handles.zData(:,k),'color', c(m*cSkip,:))
    yMin = min(handles.zData(:,k));
    yMax = max(handles.zData(:,k));
    ylim([yMin yMax]), xlim([-inf inf])
    box off
end