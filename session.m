%% Adjustable Parameters
% nSignals = 5;
signals =[1:5];
nSignals = numel(signals);
prefix = 'temp';
chb = [1 2 3 4];
mult = [1 2 1 1];
fig_arrange = [3,2]; % [# of rows, # of cols]
yt = 800;
xLim = [-0.5 11];
xTick = [0 10];

%% Processing
nch = numel(chb);
% if  nch < 3
%     colorMat = [0 0 1; 1 0 0];
% else
% colorMat = [0 0 1; 0 0.4 0; 1 0 0; 0 0 0];
% end
colorMat = [0 0 0; 0 0 0; 0 0 0; 0 0 0];
figure
for jj = 1:nSignals
    eval(['var' num2str(jj) '=' prefix num2str(signals(jj)) ';']);
    var = eval(['var' num2str(jj) ';']);
%     var = zscore(var);
    
    
    subplot(fig_arrange(1),fig_arrange(2),jj)
    for kk = 1:numel(chb)
        row = ceil(rem(kk,4.2));
        plot(time,mult(kk)*var(:,chb(kk))-yt*(kk-1),'color',colorMat(row,:))
        drawnow
        hold on
    end
    title(['File ' num2str(jj)])
    box off
    set(gca,'ytick',[],'ycolor','w','tickdir','out', 'xtick',xTick)
    xlim(xLim)
    ylim([-nch*yt+yt/2 1.2*yt])
end
% var1 = temp3;
% var2 = temp4;
% chb = [1 2 3];


%% Plotting
% figure
% subplot(2,1,1)
% plot(time,zscore(var1(:,chb(1))))
% box off
% hold on
% set(gca,'tickdir','out','xtick',[0 10],'ytick',[],'ycolor','w','fontsize',14)
% plot(time,zscore(var1(:,chb(2)))-yt,'r')
% plot(time,zscore(var1(:,chb(3)))-2*yt,'color',[0 0.4 0])
% % plot(time,zscore(var1(:,ch(4)))-3*yt,'k')
% xlim(xLim)
% nch = numel(ch);
% ylim([-nch*yt yt])
% 
% subplot(2,1,2)
% plot(time,zscore(var2(:,chb(1))))
% box off
% hold on
% set(gca,'tickdir','out','xtick',[0 10],'ytick',[],'ycolor','w','fontsize',14)
% plot(time,zscore(var2(:,chb(2)))-yt,'r')
% plot(time,zscore(var2(:,chb(3)))-2*yt,'color',[0 0.4 0])
% % plot(time,zscore(var2(:,ch(4)))-3*yt,'k')
% xlim(xLim)
% ylim([-nch*yt yt])
% 
% shg
% 
