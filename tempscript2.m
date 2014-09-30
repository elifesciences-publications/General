

mu1 = mean(newsweeps1);
sig1 = std(newsweeps1);
mu2 = mean(newsweeps2);
sig2 = std(newsweeps2);
mu3 = mean(newsweeps3);
sig3 = std(newsweeps3);
tt = [time_adjusted fliplr(time_adjusted)];

mpp1 = [(mu1+sig1) fliplr(mu1-sig1)]; mpp1 = mpp1/max(mu1);
mpp2 = [(mu2+sig2) fliplr(mu2-sig2)]; mpp2 = mpp2/max(mu1);
mpp3 = [(mu3+sig3) fliplr(mu3-sig3)];  mpp3 = mpp3/max(mu1);

xlims = [timeRange];
ylims = [-0.05 1.24];

figure
subplot(1,2,1),plot(time_adjusted,newsweeps1/max(mu1),'b'),hold on
subplot(1,2,1),plot(time_adjusted,newsweeps2/max(mu1),'r')
% subplot(1,2,1),plot(time_adjusted,newsweeps3/max(mu1),'color',[0 0.4 0])
xlim(xlims)
ylim(ylims)
box off
set(gca,'xtick',[0 10],'ytick',[0 0.5 1],'tickdir','out','fontsize',14)

% subplot(1,2,2),fh1 = fill(tt,mpp1,'b'); set(fh1,'facecolor','b','edgecolor','b','facealpha',0.4,'edgealpha',0), hold on, plot(time_adjusted,mp1,'k','linewidth',3)
% subplot(1,2,2),fh2 = fill(tt,mpp2,'r'); set(fh2,'facecolor','r','edgecolor','r','facealpha',0.4,'edgealpha',0), hold on, plot(time_adjusted,mp2,'k','linewidth',3)
% subplot(1,2,2),fh3 = fill(tt,mpp3,'g'); set(fh3,'facecolor','g','edgecolor','g','facealpha',0.4,'edgealpha',0), hold on, plot(time_adjusted,mp3,'k','linewidth',3)

subplot(1,2,2),fh1 = fill(tt,mpp1,'b'); set(fh1,'facecolor','b','edgecolor','b'), hold on, plot(time_adjusted,mu1/max(mu1),'k','linewidth',3)
subplot(1,2,2),fh2 = fill(tt,mpp2,'r'); set(fh2,'facecolor','r','edgecolor','r'), hold on, plot(time_adjusted,mu2/max(mu1),'k','linewidth',3)
subplot(1,2,2),fh3 = fill(tt,mpp3,'g'); set(fh3,'facecolor','g','edgecolor','g'), hold on, plot(time_adjusted,mu3/max(mu1),'k','linewidth',3)
xlim(xlims)
ylim(ylims)
box off
set(gca,'xtick',[0 10],'ytick',[],'tickdir','out','fontsize',14)
shg
