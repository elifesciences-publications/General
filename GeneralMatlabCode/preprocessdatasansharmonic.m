% PREPROCESSDATA
% Creates a data structure from many data files and preprocesses it to make
% it ready for wavelet analysis
% Updated: 01-Mar-2011 02:40:47
% Author: AP


%% Adjustable signal processing parameters
hpf = 50; % (default = 40)
lpf = 3; % Low pass filter value after high pass filtering and rectification of data. 
% Lpf value gets changed later in the program depending on freq range of interest.

peakStringency = 1; 
yShift = 25; 

dataFiles = [1];
ch =   [1 2];
timeRange = [5 20]; % Time period for which signal is to be displayed in XWT
freqRange = [1 50]; % Range of frequencies to be displayed in XWT
if max(freqRange) >= floor(1/samplingInt); errordlg('High frequency value above Nyquist limit'), end
lpf = ceil(freqRange(2)/3);

%% Appending file names to data matrices contained in the data structure
% created by 'comparedata.m'
% Also, finds the starting and end points for each time vector
minMat=[]; maxMat =[];
for fileNum = dataFiles
    clear(['data' num2str(fileNum)])
    clear(['time' num2str(fileNum)])
    eval(['data' num2str(fileNum) '= dataStruct.(fNames(fileNum,:))(:,[ch]);'])
    eval(['time' num2str(fileNum) '= timeAxisStruct.(fNames(fileNum,:));'])
    minMat =[minMat; eval(['time' num2str(fileNum) '(1);'])];
    maxMat =[maxMat; eval(['time' num2str(fileNum) '(end);'])];
end

%% Keeps common time portion of the data only
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

%% Processing data
for fileNum = dataFiles
    clear(['temp' num2str(fileNum)])
    clear(['signal' num2str(fileNum)])
    fstr = num2str(fileNum);
     eval(['temp' fstr '=chebfilt(autoartremove(data' fstr...
            ',time),samplingInt,hpf,''high'');']); % Highpasses
      eval(['temp' fstr ' = chebfilt(temp' fstr...
            ', samplingInt,[55 65],''stop'');']);
        % ... data and automatically remove stimulus artifacts. Also gets
        % ... rid of the channels not specified at the start of this file.
        eval(['temp' fstr ' = chebfilt(overthreshremove(temp' fstr...
            ',time),samplingInt,hpf,''high'');']); % Manually chops
        % ... off stim artifacts that were not properly removed.
     
%  eval(['temp' fstr '=chebfilt(data' fstr...
%              ',samplingInt,hpf,''high'');']) ----> Use this if you don't
%              want stim artifacts removed
        eval(['signal' fstr '=temp' fstr ';'])
        if hpf >= 40 % Rectification only when signal is highpassed over 40Hz
        eval(['f = signal' fstr '<0;'])
        eval(['signal' fstr '(f)=0;'])
        end
        eval(['signal' fstr '=chebfilt(signal' fstr...
            ',samplingInt,lpf,''low'');']) % Rectifies and lowpasses
        
    for chNum = 1:length(ch)
        chstr = ['ch' num2str(chNum)];
         eval(['[maxtab' fstr  chstr ',mintab' fstr  chstr '] = peakdet(zscore(signal'...
        fstr '(:,chNum)),peakStringency);']) % Find the peaks of lowpassed
    % ... data fulfilling stringency criterion (such as 2*stds away from valleys)
    end
end

