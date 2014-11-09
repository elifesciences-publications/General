function [means,sigs] = ComputeSignalPairStats(normalizedSignalPairStrengthMatrix);
% ComputeSignalPairStats Computes the means and standard deviations for the
% normalized strengths of the individual signal pairs.
%   normalizedSignalPairStrengthMatrix - Matrix of normalized values for
%   individual signal pairs for all trials within and across expts.

vals = normalizedSignalPairStrengthMatrix;
vals(vals>10)=nan; % Removes strength computed from w/in isothreshold regions of Wxy_avg
vals(vals(:,2)==0,:)=nan;
f = find(isnan(vals(:,1)));
vals(f,:)=[];
boxplot(vals)
means = mean(vals,1);
sigs = std(vals);
end

