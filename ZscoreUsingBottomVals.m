
function [varargout] = ZscoreUsingBottomVals(varargin)
% ZscoreByHist - Computes the more accurate zscore of a signal by considering only the bottom 5% amplitude
%                values, and thereby ignoring the activity which can really
%                affect the estimated z-score values in a signal with lots
%                of activity.
% [zscoreX] = ZscoreUsingBottomVals(x);
% [zscoreX, muX] = ZscoreUsingBottomvals(x);
% [zscoreX, muX, sigmaX] = ZscoreUsingBottomVals(x);
% [zscoreX, muX, sigmaX] = ZscoreUingBottomVals(x, signifLevel);
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
    signifLevel = 0.68;
else
    signifLevel = varargin{2}/100;
end
x = varargin{1};
signifLevel = (1-signifLevel)/2;
len = round(1/signifLevel);

y = x;
y(y==0)=[]; % Eliminating zeros because if these entirely contribute to the bottom 5% values then the zscore values
            % can be outrageously large
            
[~,inds] = sort(abs(y),'ascend');
blah = x(inds);
muX = mean(blah(1:round(length(blah)/len)));
sigmaX = std(blah(1:round(length(blah)/len)));

zscoreX = (x-muX)/sigmaX;


varargout{1} = zscoreX;
varargout{2} = muX;
varargout{3} = sigmaX;