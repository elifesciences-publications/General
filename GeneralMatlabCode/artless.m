% ARTLESS  Loads >=1 '.abf' files into the matlab workspace
% ARTLESS (1) Extracts timeseries data from user-selected '.abf' files and loads
% into matlab workspace. Timeseries signals are stored in the structure
% variable 'dataStruct' and time vectors are stored in the structure
% variable 'timeAxisStruct'. The fieldnames correspond to the filenames.
%(2) Presents the option for detecting stimulus artifacts either manually 
% or automatically. Time value in each time vectors is set to 0 at the onset 
% of first stimulus in stimulus train.
%(3) Stimulus artifacts are detected by slope and removed.
%(4) Presents the option for selecting amplitude threshold over which
% unremoved artifacts are chopped off.
%(5) Common time vector for all files is saved in the variable 'time' and
% timeseries signals are stored in the variable 'temp*', where *
% corresponds to filenumber.

%% Première Partie - Sélectionne des fichiers et des téléchargements en
%% matlab
answer='Yes';
nFiles=0;
while strcmpi(answer,'Yes');
    nFiles = nFiles + 1;
    if nFiles >1
        answer=questdlg('Would you like to analyze another file? ',...
            'Choosing another file','Yes','No','No');
        cd(path);
    end
    switch answer
        case 'Yes'
            load_data;
            f=findstr('.',file);
            file=file(1:f-1);
            file=num2str(file);
            file=['T' file];
            [data,timeAxis]=psrcompare(data,timeAxis);
            dataStruct.(file)= data;
            timeAxisStruct.(file)= timeAxis;
        case 'No'
            fNames=char(fieldnames(dataStruct));
    end
end
close all

%% Deuxième Partie  - Suppression des artefacts de stimulation 
hpf = 0.01;
dataFiles = 1:size(fNames,1);
minMat=[]; maxMat =[];
for fileNum = dataFiles
    clear(['data' num2str(fileNum)])
    clear(['time' num2str(fileNum)])
    eval(['data' num2str(fileNum) '= dataStruct.(fNames(fileNum,:));'])
    eval(['time' num2str(fileNum) '= timeAxisStruct.(fNames(fileNum,:));'])
    minMat =[minMat; eval(['time' num2str(fileNum) '(1);'])];
    maxMat =[maxMat; eval(['time' num2str(fileNum) '(end);'])];
end

% Keeps common time portion of the data only
firstTime =max(minMat); % Starting point for common time vector
lastTime = min(maxMat); % End point
time=(firstTime:samplingInt:lastTime);  % Creates common time vector
samplingInt = time(2)-time(1);
lenTime =length(time);

% Keeps only the data correspoding to the common time vector
lenMat =[];
for fileNum = dataFiles
    fpt = eval(['min(find(time' num2str(fileNum) '>= firstTime));']);
    lpt = eval(['min(find(time' num2str(fileNum) '>= lastTime));']);
    eval(['data' num2str(fileNum) '= data' num2str(fileNum) '(fpt:lpt,:);'])
    lenMat =[lenMat; eval(['length(data' num2str(fileNum) ');'])];
end
lenData = min(lenMat);

% Makes sure all the data vectors have equal length
for fileNum =dataFiles
    eval(['data' num2str(fileNum) '= data' num2str(fileNum) '(1:lenData-1,:);']);
end

% Makes sure time vector is as long as data vectors
diffLength= abs(length(time)-eval(['length(data'  num2str(dataFiles(1)) ');']));
d= diffLength/2;
f = floor(d);
l = ceil(d);
time = time(1+f:end-l);
samplingInt = time(2)-time(1);

% Processing data
for fileNum = dataFiles
    clear(['temp' num2str(fileNum)])
    fstr = num2str(fileNum);
    eval(['temp' fstr '=chebfilt(autoartremove(data' fstr...
        ',time),samplingInt,hpf,''high'');']); % Highpasses
    % ... data and automatically remove stimulus artifacts. Also gets
    % ... rid of the channels not specified at the start of this file.
    eval(['temp' fstr ' = chebfilt(overthreshremove(temp' fstr...
        ',time),samplingInt,hpf,''high'');']); % Manually chops
    % ... off stim artifacts that were not properly removed.
end

