
function fileNames = GetFilenames(fileDir, varargin)
% GetFilenames - Given the path to a directory and an optional search
%   string, returns the names of files in the dir that have the seach
%   string in them (case-insensitive)
%  fileNames = GetFilenames(fileDir,varargin);

filesInDir = dir(fileDir);
filesInDir = {filesInDir.name};
if nargin==2
    matchStr = varargin{1};
elseif nargin ==1
    matchStr = [];
end

matchInds =[];
fldrInds = [];
for fn = 1:length(filesInDir)
    fName = filesInDir{fn};
    if ~isempty(strfind(fName,matchStr))
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
