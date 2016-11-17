function varargout = ParseVarargin(argList,argNames)
%% Not complete....
out = struct;
for jj = 1:length(argNames)
    ind = strfind(argList,argNames{jj});
    out.(argNames{jj}) = argList{ind+1};
end

varargout{1} = out;
end