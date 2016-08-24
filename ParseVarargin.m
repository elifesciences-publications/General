function varargout = ParseVarargin(varargin)
% ParseVarargin - When given varargin as input that contains key-value type
%   pairs, assumes all the odd-numbered cells are keys and the immediately next
%   cells are values

args = varargin;
% str = cellfun(@isstr,args);
% strInds = find(str);
% args_str = args(strInds);

count = 0;
for jj = 1:2:length(args)
    count = count + 1;
    varName = lower(args{jj});
    eval([varName '= args{jj+1};']);
    varargout{count} = eval([varName]);
end


end