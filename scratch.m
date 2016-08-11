
%% Plot tail curvatures atop moving fish
fps = 500;
pauseDur = [];
trl = 3;
inds = (trl-1)*750 + 1: (trl-1)*750 + 750;
var1 = IM_proc_crop(:,:,inds);
var2 = repmat([71 71],numel(inds),1);
mlInds2 = midlineInds(inds);
tC = tailCurv(:,:,inds);

PlayFishTracking2(IM_proc_crop,'fishPos',[71 71], 'midlineInds',midlineInds,'tailAngles',tA,'plotCurv',1,'tailCurv',tailCurv,'frameInds',inds,'pauseDur',pauseDur);

%%

zThr = 1.5;
mu = mean(IM_proc_crop(:));
sigma = std(IM_proc_crop(:));
minPxls = 40;
maxPxls = 100;

inds = 69;
mlInds = GetMidlinesByThinning(IM_proc_crop(:,:,inds),'zThr',zThr,...
    'mu',mu,'sigma',sigma,'minPxls',minPxls,'maxPxls',maxPxls,...
    'fishPos',repmat([71 71],numel(inds),1));


lineLens = [10 9 8 7 6 5];

midlineInds = GetMidlines(IM_proc_crop,(fishPos./fishPos)*(size(IM_proc_crop,1)/2+1),...
    lineLens,'bmp','procType','parallel','headVec',hOr_crop);
