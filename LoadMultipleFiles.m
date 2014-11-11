% LoadMultipleFiles - Function version of MFLOAD where filenames can
% specified
% ***** Author: AP *******

try
    paths = FileNameToFullPath(fileNames{1},baseDir)
    paths = [paths '\']
    clear files
    for nFile = 1:size(fileNames,1)
        files(nFile) = {[fileNames{nFile}(2:end) '.abf']};
    end
%     files = fileNames';
    nFiles = size(char(files),1);
    [dataStruct,timeAxisStruct,samplingInts] = ...
        createdatastructure(files,paths);
catch
fprintf('\n Automatic file detection failed, please choose files manually! \n')
sid = getsid;
if strcmpi(sid,'S-1-5-21-3197369867-541179473-1092110829')
cd('C:\Users\Avi\Documents\All Things Research\Research Data\Data');    
end
clear files paths
[files,paths] = uigetfile({'*.*';'*.abf';'*.atf';'*.mat';},'SELECT MULTIPLE FILES USING CTRL OR SHIFT KEY','Multiselect','on');
nFiles = size(char(files),1);
[dataStruct,timeAxisStruct,samplingInts] = createdatastructure(files,paths);

cd(paths(end,:));  
    
end