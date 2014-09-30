% PREPROCESSDATA
% Creates a data structure from many data files and preprocesses it to make
% it ready for wavelet analysis
% Updated: 01-Mar-2011 02:40:47
% Author: AP

%% NOTES
% 1) First run 'comparedata.m' to load slightly processed .abf files into
%    matlab. Allow loading multiples files at once.


%% Adjustable signal processing parameters
hpf = 1; % (default = 40)
lpf = 20; % Low pass filter value after high pass filtering and rectification of data.
% Lpf value gets changed later in the program depending on freq range of interest.

dataFiles = [1];
ch =   [2 3];
timeRange = [-2  20]; % Time period for which signal is to be displayed in XWT



%% OPTIONS
stopband =[58 62];
denoise = 'y'; % 'y' = removes 60Hz by stopbanding b/w values specified in "stopband"; 'n' = no fitering;
threshdenoising ='n'; %%%% 'y' = gives the option of setting threshold for artifact truncation; 'n' =  no option;


peakStringency = 1;
yShift = 25;

% if max(freqRange) >= floor(1/samplingInt); errordlg('High frequency value above Nyquist limit'), end
% lpf = ceil(freqRange(2)/3);

%% Appending file names to data matrices contained in the data structure
% created by 'comparedata.m'
% Also, finds the starting and end points for each time vector
minMat=[]; maxMat =[];
for fileNum = dataFiles
    eval(['data' num2str(fileNum) '= dataStruct.(fNames(fileNum,:))(:,[ch]);'])
    eval(['time' num2str(fileNum) '= timeAxisStruct.(fNames(fileNum,:));'])
    minMat =[minMat; eval(['time' num2str(fileNum) '(1);'])];
    maxMat =[maxMat; eval(['time' num2str(fileNum) '(end);'])];
end

%% Keeps common time portion of the data only
firstCommonTime = max(minMat); % Starting point for common time vector
lastCommonTime = min(maxMat); % End point
time=(firstCommonTime:samplingInt:lastCommonTime);  % Creates common time vector


%%%%%%%%%%%%%% EDITS  - 15-Feb-2013
if timeRange(1)<time(1), 
    errordlg('Lower value of the chosen time range is out of bounds! Re-enter values for the variable "timeRange"','Time Range Out of Bounds!')
elseif timeRange(2)>time(end)
    errordlg('Upper value of the chosen time range is out of bounds! Re-enter values for the variable "timeRange"','Time Range Out of Bounds!')
end

[fpt,lpt] = deal([]);
fpt = min(find(time>=timeRange(1)));
lpt =  min(find(time>=timeRange(2)));
time = time(fpt:lpt);
lenTime =length(time);

% Keeps only the data correspoding to the common time vector
lenMat =[];
for fileNum = dataFiles
    eval(['data' num2str(fileNum) '= data' num2str(fileNum) '(fpt:lpt,:);'])
end

%% PROCESSING DATA
for fileNum = dataFiles
    clear(['temp' num2str(fileNum)])
    clear(['signal' num2str(fileNum)])
    fstr = num2str(fileNum);
    eval(['temp' fstr '=chebfilt(autoartremove(data' fstr...
        ',time),samplingInt,hpf,''high'');']); % Highpasses
    % ... data and automatically remove stimulus artifacts. Also gets
    % ... rid of the channels not specified at the start of this file.
    if lower(threshdenoising) == 'y';
        eval(['temp' fstr ' = chebfilt(overthreshremove(temp' fstr...
            ',time),samplingInt,hpf,''high'');']); % Manually chops
        %         % ... off stim artifacts that were not properly removed.
    end
    %% DENOISE OR NOT?
    if denoise =='y'
        eval(['temp' fstr '=chebfilt(temp' fstr...
            ',samplingInt,stopband,''stop'');']) %%%%% Stopbands
    end
    
    %% HIGHPASSING, RECTIFYING,LOW-PASSING
    eval(['temp' fstr '=chebfilt(temp' fstr...
        ',samplingInt,hpf,''high'');']) %%%%% Highpasses
    eval(['signal' fstr '=temp' fstr ';'])
    
    if hpf >= 20 % Rectification only when signal is highpassed over 20Hz
        eval(['f = signal' fstr '<0;'])
        eval(['signal' fstr '(f)=0;'])
    end
    eval(['signal' fstr '=chebfilt(signal' fstr...
        ',samplingInt,lpf,''low'');']) %%%%% Lowpasses
    
end

