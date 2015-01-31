
function [varargout] = ZscoreByHist(x)
% ZscoreByHist - Computes the 'true' zscore of a signal with lots of activity by using a 
%                histogram-based method to extract baseline values.
% [zscoreX] = ZscoreByHist(x);
% [zscoreX, muX] = ZscoreByHist(x);
% [zscoreX, muX, sigmaX] = ZscoreByHist(x);
% 
% Inputs: x is the input signal
% Outputs: 
% zscoreX - signal expressed in true zscore units
% muX - true mean of the signal
% simaX - true std of the signal


[count,vals] = hist(x,round(length(x)/10));
cdf = cumsum(count./sum(count));
cdf_norm = (1/(max(cdf)-min(cdf))) * (cdf-min(cdf));
[~,ind] = min(abs(cdf_norm-0.2));
cutoffVal = vals(ind);
baselineVals = x(x<=cutoffVal);
muX = mean(baselineVals);
sigmaX = std(baselineVals);

zscoreX = (x-muX)/sigmaX;

varargout{1} = zscoreX;
varargout{2} = muX;
varargout{3} = sigmaX;