function y = Standardize(x)
%Standardize Given a variable of any dimension, standardizes the values
%   in the variable (min-max = 0-1) along a specified dimension or across
%   all dimensions
% y = Standardize(x)
% 
% Avinash Pujala, Koyama lab/HHMI, 2016

y = (x-min(x(:)))/(max(x(:))-min(x(:)));

end

