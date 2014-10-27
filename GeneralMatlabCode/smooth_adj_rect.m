data(find(data<0))=0;
timeAxis=(1:length(data))*samplingInt;

kr= input('Kernel Range ? ');
kw=kr/2;
kr_pts= round(kr/samplingInt);
kw_pts=round(kw/samplingInt);
gker1=normpdf(-kw_pts:kw_pts, 0, kr_pts/6);
smooth1a=conv(data(:,1),gker1);
smooth2a=conv(data(:,2),gker1);
smooth3a=conv(data(:,3),gker1);
d=length(smooth1a)-length(timeAxis);
fpt=floor(d/2);
smooth1a=smooth1a(fpt+1:end-fpt);
smooth2a=smooth2a(fpt+1:end-fpt);
smooth3a=smooth3a(fpt+1:end-fpt);

smooth1a=smooth1a/std(smooth1a);
smooth2a=smooth2a/std(smooth2a);
smooth3a=smooth3a/std(smooth3a);

% kr_pts=kw_pts;
% kw_pts=kw_pts*2;
% gker2=normpdf(-kw_pts:kw_pts, 0, kr_pts/6);
% smooth1b=conv(data(:,1),gker2);
% smooth2b=conv(data(:,2),gker2);
% smooth3b=conv(data(:,3),gker2);
% d=length(smooth1b)-length(timeAxis);
% fpt=floor(d/2);
% smooth1b=smooth1b(fpt+1:end-fpt);
% smooth2b=smooth2b(fpt+1:end-fpt);
% smooth3b=smooth3b(fpt+1:end-fpt);
% 
% smooth1b=smooth1b/std(smooth1b);
% smooth2b=smooth2b/std(smooth2b);
% smooth3b=smooth3b/std(smooth3b);
% 
% smooth1_adj=smooth1a-smooth1b;
% smooth2_adj=smooth2a-smooth2b;
% smooth3_adj=smooth3a-smooth3b;
% 
% smooth1_adj=smooth1_adj/max(smooth1_adj);
% smooth2_adj=smooth2_adj/max(smooth2_adj);
% smooth3_adj=smooth3_adj/max(smooth3_adj);
% 


