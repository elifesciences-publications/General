function outputMatrix = Downsample2DMatrix(inputMatrix, factor )
%DownsampleMatrix Downsamples a matrix both along the rows and columns by a
%factor of 'factor'
%   outputMatrix = DownsampleMatrix(inputMatrix,downsamplingFactor);

% Author: Avinash Pujala
% email: avinashpujala@gmail.com

outputMatrix = transpose(downsample(transpose(downsample(inputMatrix,factor)),factor));

end

