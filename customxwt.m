function Wxy = customxwt(time,x,y)
% Wxy = customxwt(time,x,y);
% Customized plot of the wavelet transform
% Adapted from xwt.m by Alsak Grinsted et al.
% Modified 27-Aug-2008 18:46:55
%% Some variables
dt = time(2)-time(1);
lpf = 50;
hpf = 0.1;
newSamplingFrequency = lpf*4;
fourier_factor = 1.0330;
freq_limits_for_xwt = [1 20];
scale_limits_for_xwt = (1./freq_limits_for_xwt)*fourier_factor;
Pad = 1;
dj = 1/64;
S0 = min(scale_limits_for_xwt);
MaxScale = max(scale_limits_for_xwt);
significance_stringency = 1;
phaseMode = 'alt'; %(default mode = 'alt'; Other possibility is 'synch')
sigMat = [x(:), y(:)];
sigMat = reducedata(sigMat,time,newSamplingFrequency);
time_reduced = linspace(0,time(end),size(sigMat,1));
lenTime  = length(time_reduced);
sigmax = std(x);
sigmay = std(y);

%% XWT
statMat = cell(2,7);
statMat(1,:)= deal({'Mean f', 'Std f', 'Mean Ph', 'Std Ph',...
    'Mean Pow','Std Pow', 'Tot Pow'});
[Wxy,period,scale,coi,sig95] = xwt([time_reduced(:) sigMat(:,1)],...
    [time_reduced(:),sigMat(:,2)],Pad, dj,'S0',S0,'ms',MaxScale);
freq =1./period;
ftmat = repmat(freq(:), 1, lenTime);
coimat = repmat(1./coi(:)',length(freq), 1);
Wxy_coi = Wxy;
Wxy_coi(ftmat<coimat) = 0;
Wxy_coi_sig = Wxy_coi;
Wxy_coi_sig(sig95< mean(sig95(:))+ significance_stringency*std(sig95(:))) = 0;
angles = abs(angle(Wxy));
Wxy_coi_sig_phase = Wxy_coi_sig;
switch phaseMode
    case 'alt'
        Wxy_coi_sig_phase(angles <= pi/2) = 0;
    case 'synch'
        Wxy_coi_sig_phase(angles >= pi/2) = 0;
end
Wxy = Wxy_coi_sig_phase;
oneMat =Wxy; oneMat(Wxy~=0)=1;
temp = ftmat.*oneMat;
temp(temp==0)=[];
if numel(temp)==0
    temp=0;
end
meanFreq = round(mean(temp(:))*100)/100; % Rounded...
% to two decimal places
stdFreq = round(std(temp(:))*100)/100;
Axy = angle(Wxy);
Axy(Axy<0)= (Axy(Axy<0))+2*pi;
temp =Axy.*oneMat;
temp(temp==0)=[];
if numel(temp)==0
    temp=0;
end
meanPhase = round(mean(temp(:))*360/(2*pi));
stdPhase= round(std(temp(:))*360/(2*pi));
temp = Wxy.*oneMat;
temp(temp==0)=[];
if numel(temp)==0
    temp=0;
end
meanPower = round(mean(abs(temp))*100)/100;
stdPower = round(std(abs(temp))*100)/100;
totalPower = round(sum(abs(temp)));
CData = Wxy_coi_sig_phase;
CData(CData==0)=nan;
statMat(2,:)= deal({meanFreq, stdFreq, meanPhase, stdPhase,...
    meanPower, stdPower,totalPower});

%% Plotting figures
figPos = get(gcf,'position');
set(gcf,'position',[figPos(1) figPos(2)-figPos(4)/2 figPos(3)...
    figPos(4)+figPos(4)/2]);
ax1 = axes;
aPos = get(ax1,'position');
set(ax1,'position',[aPos(1) aPos(2)+ aPos(4)*(1/3) aPos(3) aPos(4)*(2/3)])
plotwave(Wxy_coi_sig_phase,time_reduced,period,coi,sig95,sigmax, sigmay)
set(ax1,'xtick',[], 'xcolor','w')
xlabel('')
aPos = get(ax1,'position');
ax2=axes; hold on
tempSig = zscore(sigMat);
plot(time_reduced,tempSig(:,1),'linewidth',1.5)
aPos2 = get(ax2,'position');
set(ax2,'position',[aPos2(1) aPos2(2) aPos(3) aPos2(4)*(1/3)])
hold on
plot(time_reduced,tempSig(:,2)-max(tempSig(:,2)+2),'r','linewidth',1.5)
box off, axis([-inf inf -inf inf])
xlabel('Time (s)','fontsize',14)
set(gca,'fontsize',14)
set(ax2,'ytick',[],'ycolor','w')
figPos = get(gcf,'position');
set(gcf,'position',[figPos(1:2) figPos(4) figPos(4)]); % Square shaped figure
hold off;

