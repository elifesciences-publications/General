%% Plotting Parameters
vs = -5; % Vertical Shift of pulse lines
sf = 18; % Scaling factor for pulse lines
lw = 1; % Width for pulse lines
%% UV Light
% t1 = 53.9;
% t2 = 66.2;
% t3 = 120.2;
% t4 = 130.8;
% pulse = zeros(size(time));
% pt1 = find(time>=t1,1,'first');
% pt2 = find(time>=t2,1,'first');
% pt3 = find(time>=t3,1,'first');
% pt4 = find(time>=t4,1,'first');
% pulse([pt1:pt2 pt3:pt4]) = 1;
% 
% plot(time,sf*pulse+vs,'m--','linewidth',2)
% hold on
%% Red Light
% t1 = 190.19;
% t2 = 204.28;
% t3 = 240.07;
% t4 = 251.18;
% pulse = zeros(size(time));
% pt1 = find(time>=t1,1,'first');
% pt2 = find(time>=t2,1,'first');
% pt3 = find(time>=t3,1,'first');
% pt4 = find(time>=t4,1,'first');
% pulse([pt1:pt2 pt3:pt4]) = 1;
% 
% plot(time,sf*pulse+vs,'r--','linewidth',2)


%% Blue Light
% t1 = 300.73;
% t2 = 311.20;
% t3 = 380.42;
% t4 = 391.88;
% pulse = zeros(size(time));
% pt1 = find(time>=t1,1,'first');
% pt2 = find(time>=t2,1,'first');
% pt3 = find(time>=t3,1,'first');
% pt4 = find(time>=t4,1,'first');
% pulse([pt1:pt2 pt3:pt4]) = 1;
% 
% plot(time,sf*pulse+vs,'b--','linewidth',2)
% 

%% Green Light
% t1 = 0;
% t2 = 0;
% t3 = 64.2;
% t4 = 200.21;
% pulse = zeros(size(time));
% pt1 = find(time>=t1,1,'first');
% pt2 = find(time>=t2,1,'first');
% pt3 = find(time>=t3,1,'first');
% pt4 = find(time>=t4,1,'first');
% pulse([pt1:pt2 pt3:pt4]) = 1;
% 
% plot(time,sf*pulse+vs,'--','color',[0 0.5 0],'linewidth',2)


% xlSheet = 5; 
% [f, p] = uigetfile('*.*');
% pf = [p f];
% [num,txt, raw]= xlsread(pf,xlSheet);
% 
% subs = find(num(:,1)<1);
% nSubs = numel(subs);
% subs_la = find(num(:,1)<1 & num(:,3)>0);
% nSubs_la = numel(subs_la);
% preps = sort(unique(num(subs,6)));
% nPreps = numel(preps);

%% This pulls out the avg total power for all alternate channel pairs from the variable 'statMat' and expresses them as strength
if size(statMat,2)~= 17
    statMat = statMat';
elseif size(statMat,1) == size(statMat,2)
    statMat = statMat';
end
% row(1) = [size(fNames,1)* (numel(ch)-1)] + 2;
% row(2) = row(1)+((numel(ch)-1)*2)- 1 ;

row(1) = (size(fNames,1)*(numel(ch)-1)) + 2*(numel(ch)-1) + 2; 
row(2) = row(1)+((numel(ch)-1)*2)-1;
col = 13;
b = statMat(row(1):row(2),col);
b = cell2mat(b);
b = round(sqrt(b)');
% b = sqrt(b(1:2:end))'

row(1) = 2;
row(2) = row(1)+(nChannelPairs*nFiles)-1;
c = statMat(row(1):row(2),13);
c = sqrt(cell2mat(c));
d = reshape(c,nChannelPairs,nFiles)';
d_norm = d./mean(d(:,1));
b = [d_norm;b];
b = round(b*100)/100;
b
vals(vals>10)=nan;
vals(vals(:,2)==0,:)=nan;


