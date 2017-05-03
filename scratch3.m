
%%
% im = procData.IM_crop;
tc = procData.tailCurv;
or = FishOrientationFromTailCurves(tc);
or = chebfilt(or,1/500,60,'low');
%%

figure
for jj = 751:1500
    cla
%     imagesc(im(:,:,jj))
    imagesc(imrotate(im(:,:,jj),or(jj)-90,'bilinear','crop'))
    set(gca,'ydir','normal')
    title(['Frame ' num2str(jj) ', Angle ' num2str(round(or(jj)))])
    shg
    pause(0.1)
end