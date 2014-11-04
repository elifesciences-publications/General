% MFLOAD - Load multiple files at once into MATLAB workspace. One
% limitation is that all the files must be in the same path or directory.
%
% ***** Author: AP *******

sid = getsid;
if strcmpi(sid,'S-1-5-21-3197369867-541179473-1092110829')
cd('C:\Users\Avi\Documents\All Things Research\Research Data\Data');    
end

[files,paths] = uigetfile({'*.*';'*.abf';'*.atf';'*.mat';},'SELECT MULTIPLE FILES USING CTRL OR SHIFT KEY','Multiselect','on');
nFiles = size(char(files),1);
[dataStruct,timeAxisStruct,samplingInts] = createdatastructure(files,paths);

cd(paths(end,:)); 