function varargout = OpenMatFile(varargin)
%OpenMatFile Interactively allows opening of matfile and creation of a
%   variable in the workspace that points to the matfile.
% var = OpenMatFile();
% var = OpenMatFile(fullPathToMatFile);
% var = OpenMatFile(matFile);
% var = OpenMatFile(pathToMatFileDir,'nameMatchStr',nameMatchStr);
% Inputs:
% fullPathToMatFile - Full path to .mat file ()
% matFile - .mat file that has already been loaded into the workspace or
%   the path to the directory containing the .mat file
% 'nameMatchStr' - In the event there are multiple .mat files in the input
%   directory, nameMatchStr, which is a string to filter only those .mat
%   files containing this string in their names. If there multiple .mat
%   files still, then allows user to interactively select the appropriate
%   .mat file.
% 
% Avinash Pujala, HHMI, 2016

nameMatchStr = [];
for jj = 1:numel(varargin)
    if ischar(varargin{jj})
        switch lower(varargin{jj})
            case lower('nameMatchStr')
                nameMatchStr = varargin{jj+1};
        end
    end
end

if nargin ==0
    [file,path] = uigetfile('*.mat','Select .mat file to open...');
    var = matfile(fullfile(path,file));
elseif nargin > 0
    if isdir(varargin{1});
        cd(varargin{1});
        procFileNames = GetFilenames(varargin{1},'nameMatchStr',nameMatchStr,'ext','mat');
        if isempty(procFileNames)
               [file,path] = uigetfile('*.mat');
        elseif length(procFileNames)>1
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

