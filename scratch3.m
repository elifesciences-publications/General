
%%
disp('Reading relevant data for subsequent midline tracking...')
tic
IM_proc_crop = procData.IM_proc_crop;
fishPos = procData.fishPos;
hOr_crop = procData.hOr_crop;
toc

%%

lineLens = [10 9 8 7 6 5];
fps = 500;
trl = 2;
inds = (trl-1)*750 + 1: (trl-1)*750 + 750;
var1 = IM_proc_crop(:,:,inds);
var2 = repmat([71 71],numel(inds),1);
var3  = hOr_crop(inds);

% mlInds= GetMidlines(var1,var2,lineLens,'bmp','procType','serial','headVec',var3,'pauseDur',[]);

% img_flt = conv2(var1,ker,'same');

% [mlInds2,dsVecs,failedInds] = GetMidlinesByThinning(var1,'fishPos',var2,'plotBool',0,'pauseDur',0.1);

mlInds2 = midlineInds(inds);

% img_flt = conv2(var1,ker,'same');[thr,img_quant] = GetMultiThr(img_flt,4,'minThr',0);


 %%
% tC = SmoothenMidlines(mlInds2,var1,3,'plotBool',0,...
%     'pauseDur',[],'smoothFactor',8,'dsVecs',dsVecs);

tC = tailCurv(:,:,inds);

tA = GetTailTangents(tC);
time = (0:size(tA,2)-1)*(1/fps);

% inds = 751:1500;
% figure
% for ind = inds(:)'
%     img =  Standardize(IM_proc_crop(:,:,ind));
%     img_grad = Standardize(imgradient(img));
%     img_edge = img-img_grad;
%     imagesc(img_edge),axis image
%     title(num2str(ind))
%     shg
%     pause(0.1)
% end


%%
fp = repmat(ceil([size(IM_proc_crop,1), size(IM_proc_crop,2)]/2),size(fishPos,1),1);
[mlInds,dsVecs,~] = GetMidlinesByThinning(IM_proc_crop,...
    'fishPos',fp,'process','parallel','plotBool',1,'kerSize',9);


if isempty(nFramesInTrl)
    nFramesInTrl = 750;
end
nTrls = size(IM_proc_crop,3)/nFramesInTrl;
trlStartFrames =  (0:nTrls-1)*750 + 1;
[tailCurv, tailCurv_uncorrected] = SmoothenMidlines(mlInds,IM_proc_crop,3,'plotBool',0,...
    'pauseDur',0,'smoothFactor',8,'dsVecs',dsVecs,'trlStartFrames',trlStartFrames);


