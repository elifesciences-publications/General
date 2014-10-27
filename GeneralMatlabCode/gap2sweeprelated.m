
stimOnsetTime_ms = 5.7; 
chNum = 2;
% color = 'r';
 color = [0 0.4 0];

lastPoint = min(find(sweepTime>=(5e-3))); 
mat2 = channels(1:lastPoint,:,chNum);
mu = mean(mat2'); mu = mean(mu); sig = std(mat2'); sig = mean(sig);
muline = mu*ones(size(sweepTime)); sigline = (sig)*ones(size(sweepTime)); 

sweepTime_ms = sweepTime*1000;
sweepTime_ms_stimShifted = sweepTime_ms - stimOnsetTime_ms;


plot(sweepTime_ms_stimShifted(:), channels(:,:,chNum),'b.')
hold on
% plot(sweepTime_ms_stimShifted,muline,'k--')
% plot(sweepTime_ms_stimShifted, muline + 2*sigline,'--','color', color)
% plot(sweepTime_ms_stimShifted, muline - 2*sigline,'--','color',color)

plot(sweepTime_ms_stimShifted, muline + 2*sigline,'b--')
plot(sweepTime_ms_stimShifted, muline - 2*sigline,'b--')

plot(sweepTime_ms_stimShifted, avgChannels(:,chNum),'k','linewidth',2)

box off
% set(gca,'tickdir','out')
xlim([-inf 30]), ylim([-50 100])
shg
xlabel('Time (ms)')
ylabel('Amplitude (uV)')