%% PLOT PARAMETERS
ebticksize =70;
eblw = 1; % errorbar line width
ps = 20;

%% SETTINGS
ngps = 2; %%%% Number of groups
gp1 = [1]; % Enter the file number that you want to place in this group. For instance if 7 files have been ins
gp2 = [2];
gp3 = [];
gp4 =[];
ch  = [ch]; % can reset if I like.
blah = [];
for glp = 1:ngps;
    blah = eval(['[blah(:); gp' num2str(glp) '(:)];']);
end
 chk = diff(blah); chk = find(chk==0);   
chk = isempty(chk);
if chk ==0
    errordlg('Error! Check File Groups')
end

%% COMPUTING MEANS AND SIGMAS
 mp_serial = []; nf =[];
 rp_serial = []; mp_mat = []; mf_mat = [];
 figure, hold on
for outgploop = 1:ngps    
    gp = eval(['gp' num2str(outgploop) ';']);
    blah =[]; flah =[]; 
%     fn = numel(gp)/(numel(ch)-1);
   nf = numel(gp);
   for ingploop = 1:nf
fnum = gp(ingploop);
        meh= []; feh =[];
        for chNum = 1:numel(ch)-1 
            meh = eval(['[meh; time_varying_power_f' num2str(fnum) 'ch' num2str(chNum) num2str(chNum+1) '];']);
            feh = eval(['[feh; time_varying_pfreq_f' num2str(fnum) 'ch' num2str(chNum) num2str(chNum+1) '];']);       
        end
            meh = mean(meh,1);
            feh = mean(feh,1);
            colors = {'b' 'r' [0 0.4 0] 'k'};
            if ngps <=4
            plot(meh, 'color',colors{outgploop})
            else             
            plot(meh, 'color',rand(1,3)), hold on, 
            end
            blah = [blah; meh(:)'];
            flah = [flah; feh(:)'];
%           blah = eval(['[blah; transp(meh(:))];']);
%           flah = eval (['[flah; transp(feh(:))];']);
          mp_mat = [mp_mat; meh(:)'];
          mf_mat = [mf_mat; feh(:)'];
    end
    if size(blah,1)==1
        eval(['mp' num2str(outgploop) '=blah;']); 
        eval(['rp' num2str(outgploop) '=blah;']);
        eval(['sp' num2str(outgploop) '= blah*0;']);
        
        eval(['mf' num2str(outgploop) '=flah;']); 
        eval(['sf' num2str(outgploop) '= flah*0;']);
    else
        eval(['mp' num2str(outgploop) '=mean(blah);']); 
        eval(['rp' num2str(outgploop) '=prod(blah).^(1/nf);']);
%         eval(['sp' num2str(outgploop) '=std(blah)/sqrt(nf);']);
        eval(['sp' num2str(outgploop) '=std(blah)/(nf);']);

        eval(['mf' num2str(outgploop) '=mean(flah);']); 
        eval(['sf' num2str(outgploop) '=std(flah)/sqrt(nf);']);
         
    end
    
       mp_serial = eval(['[mp_serial(:); mp' num2str(outgploop) '(:)];']);
       rp_serial = eval(['[rp_serial(:); rp' num2str(outgploop) '(:)];']);
       
end
hold off
%% PLOTTING POWER (AFTER NORMALIZING)
% nf = max([mp1(:); mp2(:); mp3(:)]);
nfp = max(mp_serial);
nff = max(rp_serial);
figure, hold on
leg=[]; gp=[]; 
for outgploop = 1:ngps
    gp = eval(['gp' num2str(outgploop) ';']);
    eval(['mp' num2str(outgploop) '=mp' num2str(outgploop) '/nfp;']);
    eval(['sp' num2str(outgploop) '=sp' num2str(outgploop) '/nfp;']);
    eval(['rp' num2str(outgploop) '=rp' num2str(outgploop) '/nff;']);
    mp = eval(['mp' num2str(outgploop) ';']);
    sp = eval(['sp' num2str(outgploop) ';']);
    rp = eval(['rp' num2str(outgploop) ';']);
    
    col =[0 0 1; 1 0 0; 0 0.4 0; 0 0 0];
    if ngps<5
        rc = col(outgploop,:);
    else
    rc = rand(1,3);
    end
    ps2 = round(ps/10);
    plot(time_adjusted(1:ps2:end),mp(1:ps2:end),'color',rc)
   
eh = errorbar(time_adjusted(1:ps:end),mp(1:ps:end),sp(1:ps:end),sp(1:ps:end),'w.','color',rc,'markerfacecolor',rc,'linewidth',eblw);
% eh = errorbar(time_adjusted(1:ps:end),mp(1:ps:end),sp(1:ps:end),sp(1:ps:end),'color',rc,'linewidth',eblw);
errorbar_tick(eh,ebticksize);    
gpnom = ['gp' num2str(outgploop)];
leg = [leg;gpnom];
end
% legend(leg);
box off
xlim([timeRange]), ylim([-0.05 inf])
set(gca,'tickdir','out','xtick',[0 5 10],'ytick',[0 0.5 1],'fontsize',15)
% title('Time-varying locomotor power')
hold off

%% PLOTTING FREQUENCIES
figure, hold on
leg=[]; gp=[];
for outgploop = 1:ngps
    gp = eval(['gp' num2str(outgploop) ';']);
    eval(['mf' num2str(outgploop) '=mf' num2str(outgploop) ';']);
    eval(['sp' num2str(outgploop) '=sp' num2str(outgploop) ';']);
    
    mf = eval(['mf' num2str(outgploop) ';']);
    sf = eval(['sf' num2str(outgploop) ';']);
    
    
    col =[0 0 1; 1 0 0; 0 0.4 0; 0 0 0];
    if ngps<5
        rc = col(outgploop,:);
    else
    rc = rand(1,3);
    end
    ps2 = round(ps/10);
%     plot(time_adjusted(1:ps2:end),mf(1:ps2:end),'color',rc)
   
eh = errorbar(time_adjusted(1:ps:end),mf(1:ps:end),sf(1:ps:end),sf(1:ps:end),'.-','color',rc,'markerfacecolor',rc,'linewidth',eblw);
errorbar_tick(eh,ebticksize);    
gpnom = ['gp' num2str(outgploop)];
leg = [leg;gpnom];
end
% legend(leg);
box off
xlim([timeRange]), ylim([-0.05 inf])
set(gca,'tickdir','out','xtick',[0 5 10],'fontsize',15)
% title('Time-varying locomotor power')
hold off


%% Fill Plot
% msp1 = [mp1+sp1 fliplr(mp1-sp1)];
% msp2 = [mp2+sp2 fliplr(mp2-sp2)];
% msp3 = [mp3+sp3 fliplr(mp3-sp3)];

% tt = [time_adjusted time_adjusted(end:-1:1)];
% figure
% fill(tt,msp1,[0 0 1],'edgecolor',[1 1 1]); hold on
% plot(time_adjusted,mp1,'k','linewidth',2)
%
% fill(tt,msp2,[1 0 0],'edgecolor',[1 1 1])
% plot(time_adjusted,mp2,'k','linewidth',2)
%
% fill(tt,msp3,[0 0.6 0],'edgecolor',[1 1 1])
% plot(time_adjusted,mp3,'k','linewidth',2)
%
% box off
% set(gca,'tickdir','out')
