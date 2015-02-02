
function [varargout] = ZscoreByHist(varargin)
% ZscoreByHist - Computes the 'true' zscore of a signal with lots of activity by using a 
%                histogram-based method to extract baseline values first.
% [zscoreX] = ZscoreByHist(x);
% [zscoreX, muX] = ZscoreByHist(x);
% [zscoreX, muX, sigmaX] = ZscoreByHist(x);
% [zscoreX, muX, sigmaX] = ZscoreByHist(x, signifLevel);
% 
% Inputs: 
% x - the input signal
% signifLevel - the percentile where values are considered baseline;
%               defaults to 5% if not specified 
% Outputs: 
% zscoreX - signal expressed in true zscore units
% muX - true mean of the signal
% simaX - true std of the signal

if nargin < 2
    signifLevel = 0.68; % This is because for a normal distribution at least 68% values are within 1 s.d.
else
    signifLevel = varargin{2}/100;
end
x = varargin{1};
% signifLevel = signifLevel + (1-signifLevel);

y = x;
y(y==0)=[];

[count,vals] = hist(abs(x),round(length(x)/10));
cdf = cumsum(count./sum(count));
cdf_norm = (1/(max(cdf)-min(cdf))) * (cdf-min(cdf)); % Because sometimes the hist binning can produce offset in cdf
[~,ind] = min(abs(cdf_norm - signifLevel));
cutoffVal = vals(ind);
baselineVals = x(abs(x)<=cutoffVal);
muX = mean(baselineVals);
sigmaX = std(baselineVals);
zscoreX = (x-muX)/sigmaX;

varargout{1} = zscoreX;
varargout{2} = muX;
varargout{3} = sigmaX;