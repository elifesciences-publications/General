% Randomtalk.m
% Script to generate figures for random fields web page
% The script requires spm96 or 99 on the matlab path 
% and will run in matlab 4 or 5
%
% Many thanks to Federico Turkheimer for the code to
% correct the variance of the smoothed images
%
% Matthew Brett - October 1999

% The relationship of p values to Z scores
Zscores = spm_invNcdf(1 - [0.05 0.01]);

% Constants for image simulations etc
Dim = [128 128];	% No of pixels in X, Y
VNo = prod(Dim);	% Total pixels
sFWHM = 8;		% Smoothing in number of pixels in x, y
seed = 6;		% Seed for random no generator
alpha = 0.05;           % Default alpha level

% Image of independent random nos
randn('seed', seed);
testimg = randn(Dim);
figure
colormap('bone');
imagesc(testimg)
axis xy;
xlabel('Pixel position in X')
ylabel('Pixel position in Y')
title('Image 1 - array of independent random numbers')

% Bonferroni threshold for this image
Bthresh = spm_invNcdf(1 - (alpha / VNo));

% Divide into FWHM chunks and fill square from mean value
sqmeanimg = testimg;
tarr = ones(sFWHM)* sFWHM; % mutliply up to unit variance
for i = 1:sFWHM:Dim(1)
  for j = 1:sFWHM:Dim(2)
    Vals = sqmeanimg(i:i+sFWHM-1,j:j+sFWHM-1);
    sqmeanimg(i:i+sFWHM-1,j:j+sFWHM-1) = tarr * mean(Vals(:));
  end
end
figure
colormap('bone');
imagesc(sqmeanimg);
axis xy;
xlabel('Pixel position in X')
ylabel('Pixel position in Y')
title(['Taking means over ' num2str(sFWHM) ' by ' num2str(sFWHM) ...
       ' elements from image 1'])

% Bonferroni threshold for the mean-by-square image
mBthresh = spm_invNcdf(1 - (alpha / prod(Dim / sFWHM)));

% smooth random number image
sd    = sFWHM/sqrt(8*log(2));   % sigma for this FWHM
smmat = spm_sptop(sd, Dim(1));  % (sparse) smoothing matrix in 1D
stestimg = smmat * testimg;     % apply in x
stestimg = (smmat * stestimg')';% then in y
stestimg = full(stestimg);      % back to non-sparse

% Restore smoothed image to unit variance - this code is tough
% 2d Gaussian kernel
[x,y] = meshgrid(-(Dim(2)-1)/2:(Dim(2)-1)/2,-(Dim(1)-1)/2:(Dim(1)-1)/2);
gf    = exp(-(x.*x + y.*y)/(2*sd*sd));
gf    = gf/sum(sum(gf));
% expectation of variance for this kernel
AG    = fft2(gf);
Pag   = AG.*conj(AG);     % Power of the noise
COV   = real(ifft2(Pag));
svar  = COV(1,1);

% smoothed image to unit variance
scf = sqrt(1/svar);
stestimg = stestimg .* scf;

% display smoothed image
figure
colormap('bone');
imagesc(stestimg)
axis xy;
xlabel('Pixel position in X')
ylabel('Pixel position in Y')
title(['Image 1 - smoothed with Gaussian kernel of FWHM ' num2str(sFWHM) ' by ' ...
      num2str(sFWHM) ' pixels'])

% No of resels
resels = prod(Dim ./ [sFWHM sFWHM]);

% threshold at 2.75 and display
th = 2.75;
thimg = (stestimg > th);
figure
colormap('bone');
imagesc(thimg)
axis xy;
xlabel('Pixel position in X')
ylabel('Pixel position in Y')
title(['Smoothed image thresholded at Z > ' num2str(th)])

% threshold at 3.5 and display
th = 3.5;
thimg = (stestimg > th);
figure
colormap('bone');
imagesc(thimg)
axis xy;
xlabel('Pixel position in X')
ylabel('Pixel position in Y')
title(['Smoothed image thresholded at Z > ' num2str(th)])

% expected EC at various Z thresholds, for two dimensions
figure
Z = 0:0.01:5;
expEC = (resels*(4*log(2))*((2*pi)^(-3/2))*Z).*exp((Z.^2)*(-0.5));
plot(Z, expEC)
xlabel('Z score threshold')
ylabel('Expected EC for thresholded image')
title(['Expected EC for smoothed image with ' num2str(resels) ' resels'])

% simulation to test the RFT threshold.
% find approx threshold from the vector above
tmp = find(Z > 3 & expEC<=alpha);
alphaTH = Z(tmp(1));
disp('Doing simulation, please wait...')
repeats = 1000;
falsepos = zeros(1, repeats);
edgepix = sFWHM;  % to add edges to image - see below
smmat = spm_sptop(sd, Dim(1) + edgepix*2);
for i = 1:repeats
  timg = randn(Dim + edgepix*2); % gives extra edges to throw away
  stimg = full(smmat*(smmat*(timg))')' * scf;
  % throw away edges to avoid artefactually high values
  % at image edges generated by the smoothing 
  stimg = stimg(edgepix+1:Dim(1)+edgepix, edgepix+1:Dim(2)+edgepix);
  falsepos(i) = any(stimg(:) >= alphaTH);
end
disp(['False positive rate in simulation was '...
      num2str(sum(falsepos) / repeats) ' (' ...
     num2str(alpha) ' expected).'])
