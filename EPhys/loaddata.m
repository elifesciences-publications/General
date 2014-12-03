% LOADDATA  Loads selected data into matlab workspace.

[file,path]=uigetfile({'*.abf';'*.atf';'*.mat'},'SELECT A FILE TO LOAD INTO MATLAB WORKSPACE');
f=fullfile(path,file);

dotind = findstr('.',file);
ext = file(dotind+1:dotind+3);
if strcmpi(ext,'abf')
    [data, samplingInt, fileInfo]=abfload(f);
    samplingInt = samplingInt*1e-6; % Expresses sampling interval in seconds.
    timeAxis = (0:length(data)-1)*samplingInt; % Creates a time axis vector starting with time zero
elseif strcmpi(ext,'atf')
    [header, labels, comments, data] = import_atf(f);
    timeAxis = data(:,1);
    timeAxis = timeAxis*1e-3;
    samplingInt = timeAxis(2)-timeAxis(1);
    data(:,1)=[];
elseif strcmpi(ext,'mat')
    ds =  load(f);
    fn = fieldnames(ds);
    data = ds.(fn{end});
    firstCol = data(:,1);
    if any(diff(firstCol)<0)
        errordlg('First column in the selected .mat file must be time')
        break
    end
    timeAxis = data(:,1);
    samplingInt = timeAxis(2)-timeAxis(1);
    data(:,1) = [];
else
    errordlg('Error in "LOADDATA.m". Try changing the format of the file to ".atf" or ".mat"');
    break
end

%% Modifications to the code
% Now accepts .atf and .mat files as input in addition to .abf  - 18-Mar-2013 22:48:18

