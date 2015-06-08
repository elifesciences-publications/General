function varargout = WeightedStats(varargin)
%WeightedStats Function for computing stats such as mean, std, etc.
% weightedMean = WeightedStats(scalars,weights);
% [weightedMean, weightedStd] = WeightedStats(scalars,weights, dim);
% 
% Inputs: 
% scalars - Values for which weighted stats are to be computed
% weights - Weights
% dim - For matrix inputs, the dimension along which to compute stats

if nargin < 2
    weights = ones(size(scalars));
    dim = 1;
    scalars = varargin{1};
elseif nargin < 3
      dim = 1;
      scalars = varargin{1};
      weights = varargin{2};
end

if isvector(scalars)
    wtMu = sum(scalars.*weights)/sum(weights);
    wtSig = sqrt(sum(((scalars-wtMu).*weights).^2)/(sum(weights)-mean(weights)));
else
    wtMu = sum(scalars.*weights,dim)./sum(weights,dim);
    dMat = ones(1,ndims(scalars));
    dMat(dim) = size(scalars,dim);
    wtMuMat = repmat(wtMu,dMat);
    wtSig = sqrt(sum(((scalars-wtMuMat).*weights).^2,dim)./(sum(weights,dim)-mean(weights,dim)));
end
% wtMat  = scalars.*weights;
% mu = sum(wtMat,1)

varargout{1} = wtMu;
varargout{2} = wtSig;
end

