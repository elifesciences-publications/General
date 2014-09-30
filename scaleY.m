orig=gca;theLim=get(orig,'Ylim');thePos=get(orig,'Position');
for k =1:length(theLim), temp=theLim(k); theLim(k)= eval('log2(temp)');end
temp=axes('Position', thePos,'Visible','off');
set(temp,'YLim',theLim,'YMinorTick','on');
theTick=get(temp,'YTick');
theTickLabels=get(temp,'YTickLabel');
blah=num2str(2.^(str2num(theTickLabels)));
theTickLabels=blah;
delete(temp)
for k =1:length(theTick), temp=theTick(k); theTick(k)= eval('2.^(temp)');end
set(orig,'YTick',theTick,'YTickLabel',theTickLabels,'YMinorTick','off');
zoom yon
shg
