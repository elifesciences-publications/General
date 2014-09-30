%PLOTAP Does the same thing as figure, but customizes to my liking
% Author: AP
function plotap(varargin)
p = plot(varargin{1});
set(gca,'fontsize',14,'tickDir','out')
box off
end