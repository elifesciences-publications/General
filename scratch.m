
% posMap = (posMap-min(posMap(:)))/(max(posMap(:))-min(posMap(:)));
% negMap = (negMap-min(negMap(:)))/(max(negMap(:))-min(negMap(:)));
% avgStack = (stack.avg-min(stack.avg(:)))/(max(stack.avg(:))-min(stack.avg(:)));
% activityMap = permute(cat(4,posMap, negMap, 0.25*avgStack),[2 1 4 3]);


function SaveImageStack(I, imgDir, fileName)
if ~exist(imgDir)
    mkdir(imgDir)
end

if ndims(I) == 4
    nImages = size(I,4);
elseif ndims(I) == 3
    nImages = size(I,3);
elseif nDims(I)==2
    nImages = 1
else
    disp('Check size of image input!')
end

fp = fullfile(imgDir,[fileName '.tif']);
for imgNum = 1:nImages
    if ndims(I)==4
        imwrite(I(:,:,:,imgNum),fp,'tif')
    else
        imwrire(I(:,:,imgNum),fp,'tif')
    end
    disp(imgNum)
end