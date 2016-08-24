% close all
figure
var = hOr_crop;
% inds = 1:size(IM_proc_crop,3);
inds = 1500:2250;
imgDims_crop = size(IM_proc_crop);
for imgNum = inds(:)'
    imagesc(IM_proc_crop(:,:,imgNum)),axis image
    colormap(gray)
    hold on
    [y,x] = ind2sub(imgDims_crop(1:2),var{imgNum});  
    hAngle = angle(x(end)-x(1) + (y(end)-y(1))*1i)*180/pi;
    hAngle(hAngle <0) = hAngle(hAngle<0) + 360;
    hAngle = 360-hAngle;
%     hAngle = mod(hAngle+180,360);
    plot(x,y,'r.')
    plot(x(1,1),y(1,1),'g+')    
    title([num2str(time(imgNum)) 'sec, ' num2str(round(hAngle)) ' deg'])
    shg
    pause(0.1)
end