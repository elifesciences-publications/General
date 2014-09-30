time = [0:length(wave)-1]*si;
freq=1./period;
base2Freq=log2(freq); % Determines the freq scale.
base2coi=log2(1./coi);
yMin=min(base2coi);
yMax=max(base2coi);
wave = abs(wave)./max(max(abs(wave))); % Normalize wavelet coefficents to max.
figure
contourf(time,base2Freq,wave); shading flat
hold on
plot(time,base2coi,'k:','Linewidth',1.5)
colorbar;
% colorbar('YTickLabel', {'Freezing','Cold','Cool','Neutral',...
%      'Warm','Hot','Burning','Nuclear'});
 
ylabel('Frequency (Hz)')
xlabel('Time (s)')
h=get(gcf);
g=h.CurrentAxes;
set(g,'Yscale','linear');
ticFun=inline('2.^x');
set(g,'YTickLabel',ticFun(str2num(get(g,'YTickLabel'))),'yLimMode','manual');
