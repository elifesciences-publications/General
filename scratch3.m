
fish = grpData.mHom.ctrl.vib.procData{1};
procData = grpData.mHom.ctrl.vib.procData;
H = fish.H;
time = H.time;
freq = H.freq;
H_avg = 0;
cMap = viridis(128);
xLim = [-40 300];
cl = [0 10];
ax = zeros(4,1);
close all
count = 0;
for fn = 1:length(procData)
    fish = procData{fn};
    H = fish.H;
    nTrls = length(H.curv.ts);
    disp(['Fish # ' num2str(fn) ', nTrls = ' num2str(nTrls)])
    for trl = 1:nTrls
            figure
            ax(1) = subaxis(4,1,1);
            imagesc(time,freq,H.head.coeff{trl})
            set(gca,'ydir','normal','xtick',[],'clim',cl)
            colormap(cMap)
            xlim(xLim)
            ylabel('Head')
            title(['Trl ' num2str(trl)])
        
            ax(3) = subaxis(4,1,2);
            imagesc(time,freq,H.tail.coeff{trl})
            set(gca,'ydir','normal', 'xtick',[],'clim',cl)
            colormap(cMap)
            xlim(xLim)
            ylabel('Tail')
        
            ax(3) = subaxis(4,1,3);
            imagesc(time,freq,H.curv.coeff{trl})
            set(gca,'ydir','normal', 'xtick',[],'clim',cl)
            colormap(cMap)
            xlim(xLim)
            ylabel('Curv')
        
            ax(4) = subaxis(4,1,4);
            plot(time,H.curv.ts{trl},'color',cMap(end,:))
            set(gca,'ydir','normal','color',cMap(1,:))
            colormap(cMap)
            xlim(xLim)
            ylabel('Curv')
        
        H_avg = H_avg + cat(1,H.head.coeff{trl},H.tail.coeff{trl},H.curv.coeff{trl});
        count = count + 1;
    end
end
H_avg = H_avg/count;

%%
figure
imagesc(time,freq,H_avg)
set(gca,'ydir','normal','clim',cl/4)
colormap(cMap)
xlim(xLim)
ttl = title('$\frac{1}{N}\sum_{n = 1}^{N}{H}$','interpreter','latex');
set(ttl,'fontsize',16)
