% LoadFiles - Load multiple files at once into MATLAB workspace. One
% limitation is that all the files must be in the same path or directory.
% For loading files from different directories, migrate files to be loaded
% to a common directory
%
% Author: Avinash Pujala

baseDir = 'C:\Users\Avi\Documents\Research\ODonovan Lab\Data\Raw Data'; % Default location of data
sid = getsid;
if strcmpi(sid,'S-1-5-21-3197369867-541179473-1092110829')
cd(baseDir);    
end

[files,paths] = uigetfile({'*.*';'*.abf';'*.atf';'*.mat';},'SELECT MULTIPLE FILES USING CTRL OR SHIFT KEY','Multiselect','on');
nFiles = size(char(files),1);

fprintf('\n Creating data structure from loaded files \n')
[dataStruct,timeAxisStruct,samplingInts] = CreateDataStructure(files,paths);

cd(paths(end,:)); % Change path to most recent directory 