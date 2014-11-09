% % 
% % 
% % signal = signal1;
% % close all
% % winSize = 30; % In seconds
% % nPts = floor(winSize/samplingInt);
% % winShift = 1; % In seconds
% % wsPts = round(1/samplingInt);
% % ls = length(signal);
% % for jj = 1:wsPts:length(signal)-nPts
% %     plot(time(jj:jj+nPts),signal(jj:jj+nPts,1),'b',time(jj:jj+nPts),signal(jj:jj+nPts,2),'r','linewidth',2)
% %     axis([-inf inf -15 15])
% %     drawnow
% %     pause
% end
%    
% for fn = 1:nFiles
%  plotxwt(W_gm(:,:,fn),time_reduced,freq,coi),
%  drawnow
%  pause
% end

% xlSheet = 6; 
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
% vals = num;


%% Finding the mean of \mathbb{S}^d at different intensities
clear IS IS_mat
ops = find(vals(:,2)>=4 & vals(:,2)<=5);
vals = vals(ops,:);
intensities = sort(unique(vals(:,1)));
IS = cell(length(intensities),3);
for jj = 1:length(intensities)
    IS{jj,1} = intensities(jj);
    intInds = find(vals(:,1)== intensities(jj));
    nSamples  = numel(intInds);
    muInts = mean(vals(intInds,4));
    gmInts = geomean(vals(intInds,4));
    IS{jj,2} = muInts;
    IS{jj,3} = gmInts;
    IS{jj,4} = nSamples;
end
IS_mat = cell2mat(IS);
labels = [{'Int (xThr)'}, {'Arith Mean'},{'Geo Mean'},{'# of samples'}];
IS = [labels; IS];
figure('Name','Locomotor Strength vs Stim Intensity')
set(gca,'tickdir','out')
plot(vals(:,1),vals(:,4),'.','color',[0.7 0.7 0.7])
hold on
plot(IS_mat(:,1),IS_mat(:,2),'ro-','linewidth',2)
plot(IS_mat(:,1),IS_mat(:,3),'b*-','linewidth',2)
% lh = legend('$S_n$','$\langle S_n \rangle$','$\left( \prod S_n \right)^{1/n}$');
% set(lh,'interpreter','latex','fontsize',14)
legend('Samples','Arithmetic Mean','Geometric Mean')
xlabel('$I_{stim}\ (\times Thr)$','interpreter','latex','fontsize',14)
ylabel('$\sqrt{\left| \sum_{f,t} W_{gm} \right|}$','interpreter',...
    'latex','fontsize',14)
box off
shg

%% Smoothing
% nBins = 4;
% bins = zeros(nBins,2);
% bins(1,:) = [0 0.9];
% bins(2,:) = [0.9 1];
% b = linspace(1,max(IS_mat(:,1)),nBins-1);
% for jj = 3:nBins
%     bins(jj,:) = [b(jj-2) b(jj-1)];
% end
maxInt = max(IS_mat(:,1));
%  bins = [0.7 1; 1 1.1; 1.1 2; 2.5 3.6; 4.5  5.6 ];
bins = [0.7 1; 1 1.1; 1.1 2; 1.5 2.6; 2.5 3.6];
% bins = [0.75 0.85; 0.85 0.95; 0.95 1.05; 1.9 2.1; 3.7 3.9];

blah = zeros(size(bins,1),3);
nPts = sum(vals(:,4));
binPts = zeros(size(bins,1),1);
clear ss
ss(:,1) = min(IS_mat(:,1)):0.1:max(IS_mat(:,1));
for jj = 2:size(IS_mat,2)
    ss(:,jj) = interp1(IS_mat(:,1),IS_mat(:,jj),ss(:,1),'linear');
end
allData = [];
figure
for jj = 1:size(bins,1)
    indices = find(ss(:,1)>= bins(jj,1) & ss(:,1) < bins(jj,2));
    temp = ss(indices,:);
    
    ind2 = find(IS_mat(:,1)>=bins(jj,1) & IS_mat(:,1)< bins(jj,2));
    temp2 = IS_mat(ind2,:);
    
    
    binPts(jj) = sum(temp2(:,4));
    temp(:,4) = temp(:,4)/sum(temp(:,4)); % Converting number of values into probs
    opp = flipud(temp(:,4));
    muT = (sum(temp(:,1).*temp(:,4)) + sum(temp(:,1).*opp))/2;
    muT = round(muT*10)/10;
    muS = sum(temp(:,2).*temp(:,4) + temp(:,2).*opp)/2;
    muS = round(muS*10)/10;
    sigS = circ_std(temp(:,2),temp(:,4));
    semS = sigS/sqrt(binPts(jj));
     [blah(jj,1), blah(jj,2),blah(jj,3)] = deal(muT,muS,semS);
     blah(find(blah(:,1)==0),:) = [];
    if binPts(jj) == 0
        binPts(jj) = 0.001; % Error-avoiding hack!
    end
    
    % For the Kruskal-Wallis Test
    ind3 = find(vals(:,1)>=bins(jj,1) & vals(:,1)< bins(jj,2) & vals(:,2)>3.5 & vals(:,2)<5.5);
    col1 =  vals(ind3,4);
    col2 = muT*ones(size(col1));
    col12 = [col1(:) col2(:)]; 
    allData = [allData; col12];
    
    
   
    
%     markerSize = (binPts(jj)/nPts)*nPts*0.75;
%     plot(blah(jj,1),blah(jj,2),'.','color',[0.7 0.7 0.7],'markersize',markerSize)
    markerSize = 30;
   plot(blah(jj,1),blah(jj,2),'.','color',[0.7 0.7 0.7],'markersize',markerSize)
   hold on
    
   
end
title('Smoothed and Binned Plot of Locomotor Strength versus VR Stimulus Intensity')
plot(blah(:,1),blah(:,2),'k-')
errorbar(blah(:,1),blah(:,2),blah(:,3),'k','linewidth',1.5)
xTick = sort(blah(:,1));
% yTick = sort(blah(:,2)); % Places yticks at data values
yTick = get(gca,'ytick');
if (numel(yTick) ~= numel(unique(yTick)) | numel(xTick) ~= numel(unique(xTick)))
    set(gca,'tickdir','out')
else
    set(gca,'tickdir','out','xtick',xTick,'ytick',yTick)
end
set(gca,'fontsize',14)
box off
xlim([0.5 inf])
ylim([-0.5 inf])



%% Statistics
[p,table,stats] = kruskalwallis(allData(:,1), allData(:,2),'off');
figure
[c] = multcompare(stats);
figure

boxplot(allData(:,1),allData(:,2),'boxstyle','filled')
set(gca,'tickdir','out','ytick',[0:1:100],'fontsize',14)
box off
ylim([-0.5 inf])
hold off
