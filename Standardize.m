function y = Standardize(x,varargin)
%Standardize Given a variable of any dimension, standardizes the values
%   in the variable (min-max = 0-1) along a specified dimension or across
%   all dimensions
% y = Standardize(x);
% y = Standardize(x,dim);
%
% Inputs:
% x - Input variable to standardize; x can be a vector or matrix of any
%   dimension
% dim - Dimension along with to standardize x. For e.g., if dim  = 3 (such as for an image stack)
%   then standardizes x along the 3rd dimension
%
% Avinash Pujala, Koyama lab/HHMI, 2016

dim = [];

if nargin > 1
    dim = varargin{1};
end


y = nan(size(x));
if isempty(dim)
    y = (x-min(x(:)))/(max(x(:))-min(x(:)));
else
    x_min =  min(x,[],dim);
    x_max = max(x,[],dim);
    x_mean = mean(x,3);
    sizeVec = size(x);
    for jj = 1:sizeVec(dim)
        expr = GetCorrectExpression(sizeVec,dim,jj);
        eval(['y' expr '= (x' expr '-x_min)./(x_max-x_min);']);
        %         eval(['y' expr '= (x' expr '-x_min);']);
        %         eval(['y' expr '= (x' expr '-x_mean);']);
    end
end
end

function expr = GetCorrectExpression(sizeVec,dim,currDim)
v = 1:numel(sizeVec);
expr1 = [];
expr2 =[];
for jj = 1:length(v);
    if jj == 1
        expr1 =[expr1 '(:,'];
    elseif jj > 1 && jj < dim
        expr1 = [expr1 ':,'];
    elseif jj > dim
        expr2 = [expr2 ',:,'];
    elseif jj == length(v)
        expr2 = [expr2,')'];
    end
end
expr = [expr1, num2str(currDim), expr2];
end