function img_trans = TranslateImage(img,coords)
%TranslateImage Translates an image by specified coordinates
% img_trans = TranslateImage(img,coords);
% Inputs:
% img - Image to be translated
% coords - Coordinates to be translated by, given as [row, col]. The
%   translation is such that the point specified by [row, col] is brought
%   to the center of the img.

imgCtr = [round(size(img,1)/2 + 0.499), round(size(img,2)/2 + 0.499)];

img_trans = circshift(img,[imgCtr(1)-coords(1) imgCtr(2)-coords(2)]);


end

