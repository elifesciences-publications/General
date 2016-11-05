function varargout = OpenMatFile(varargin)
%OpenMatFile Interactively allows opening of matfile and creation of a
%   variable in the workspace that points to the matfile.
% var = OpenMatFile();
% var = OpenMatFile(fullPathToMatFile);
% var = OpenMatFile(matFile);
% 
% Avinash Pujala, HHMI, 2016

if nargin ==0
    [file,path] = uigetfile('*.mat');
    var = matfile(fullfile(path,file));
elseif nargin ==1
    if isdir(varargin{1});
        cd(varargin{1});
        procFileNames = GetFilenames(varargin{1},'searchStr','proc','ext','mat');
        if isempty(procFileNames)
               [file,path] = uigetfile('*.mat');
        else
            file = procFileNames{1};
            path = varargin{1};
        end     
        var = matfile(fullfile(path,file));
    else
        var = matfile(varargin{1});
    end
end

varargout{1} = var;

end

