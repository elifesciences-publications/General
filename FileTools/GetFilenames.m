
function fileNames = GetFilenames(fileDir, varargin)
% GetFilenames - Given the path to a directory and an optional search
%   string, returns the names of files in the dir that have the seach
%   string in them (case-insensitive)
% fileNames = GetFileNames(fileDir);
% fileNames = GetFilenames(fileDir,'searchStr',searchStr,'ext',ext);
% Inputs:
% fileDir - Directory in which to look for files
% nameMatchStr - Finds only files with names containing the string, nameMatchStr.
% ext - Finds files with specified extension
%
% Avinash Pujala, JRC/HHMI, 2016

nameMatchStr = '.';
ext = '*';

for jj = 1:numel(varargin)-1
    if ischar(varargin{jj})
        val = varargin{jj+1};
        switch lower(varargin{jj});
            case 'searchstr'
                nameMatchStr = val;
            case 'ext'
                ext = val;
        end
    end
end

ext(strfind(ext,'.'))=[];
ext = ['*.' ext];
filesInDir = dir(fullfile(fileDir,ext));
filesInDir = {filesInDir.name};
matchInds =[];
fldrInds = [];
for fn = 1:length(filesInDir)
    fName = filesInDir{fn};
    if ~isempty(strfind(fName,nameMatchStr))
        matchInds = [matchInds;fn];
    end
    if isdir(fullfile(fileDir,fName))
        fldrInds = [fldrInds,fn];
    end
end

nonMatchInds = setdiff(1:length(filesInDir),matchInds);
remInds = union(nonMatchInds,fldrInds);
filesInDir(remInds)=[];
fileNames = filesInDir;
end
