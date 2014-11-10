% LoadMultipleFiles - Function version of MFLOAD where filenames can
% specified
% ***** Author: AP *******

% 
% fileNames = {'T10624001'
%     'T10624003'
%     'T10624006'};
% clear yrs
% for nFile = 1:size(fileNames,1)
%     if ~isempty(findstr('_',fileNames{nFile,:}))
%         yrs(nFile,:) = [num2str(20) [fileNames{nFile}(4:5)]];
%     else
%         yrs(nFile,:) = [num2str(20) [fileNames{nFile}(2:3)]];
%     end
% end

%%
sid = getsid;
if strcmpi(sid,'S-1-5-21-3197369867-541179473-1092110829')
cd('C:\Users\Avi\Documents\All Things Research\Research Data\Data');    
end

[files,paths] = uigetfile({'*.*';'*.abf';'*.atf';'*.mat';},'SELECT MULTIPLE FILES USING CTRL OR SHIFT KEY','Multiselect','on');
nFiles = size(char(files),1);
[dataStruct,timeAxisStruct,samplingInts] = createdatastructure(files,paths);

cd(paths(end,:)); 