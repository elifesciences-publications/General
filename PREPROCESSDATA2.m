% PREPROCESSDATA2
% Creates a data structure from many data files and preprocesses it to make
% it ready for wavelet analysis
% Updated: 14-Mar-2014 19:57:52
% Author: AP

%% NOTES
% 1) First run 'comparedata.m' to load slightly processed .abf files into
%    matlab. Allow loading multiples files at once.

%% Extracting Basic File Information
fNames = char(fieldnames(dataStruct)); % Converting to 'char' type variable for ease of size indexing
nFiles = size(fNames,1);

%% Comparing Signal Lengths to Determine the Smallest Permissible Common Signal Length
minMat=[]; maxMat =[]; loopCounter = 0;

for fileNum = 1:nFiles
    data = dataStruct.(fNames(fileNum,:));
    timeAxis = timeAxisStruct.(fNames(fileNum,:));
    if loopCounter < 2 % This is to prevent asking for artifact detection mode repeatedly by applying the first detection mode to all the files
        [data,timeAxis,tStimArts,selection] = artifactalign(data,timeAxis);
    else
        [data,timeAxis] = artifactalign(data,timeAxis,selection);
    end
    eval(['data' num2str(fileNum) '= data;']);
    eval(['time' num2str(fileNum) '= timeAxis;']);
    
%     eval(['data' num2str(fileNum) '= dataStruct_mod.(fNames{fileNum,:})(:,[ch]);'])
%     eval(['time' num2str(fileNum) '= timeAxisStruct.(fNames{fileNum,:});'])
    minMat =[minMat; eval(['time' num2str(fileNum) '(1);'])];
    maxMat =[maxMat; eval(['time' num2str(fileNum) '(end);'])];
end

%% Keeps common time portion of the data only
firstCommonTime = max(minMat); % Starting point for common time vector
lastCommonTime = min(maxMat); % End point

% if timeRange(1)<firstCommonTime
%     error_msg = {'Time range out of bounds! First value of the variable "timeRange" must at least equal' num2str(firstCommonTime)};
%     errordlg(error_msg,'Time Range Out of Bounds!')
%     break
% elseif timeRange(2)>lastCommonTime
%     error_msg = {'Time range out of bounds! Second value of the variable "timeRange" cannot exceed' num2str(lastCommonTime)};
%     errordlg(error_msg,'Time Range Out of Bounds!')
%     break
% else
%     firstCommonTime = timeRange(1);
%     lastCommonTime = timeRange(end);
% end

sichck = diff(samplingInts);
if any(sichck ~= 0)
    errordlg('Signals Sampled at Different Intervals!')
    break
else
    samplingInt = samplingInts;
end
time = firstCommonTime:samplingInt:lastCommonTime; % Creates a common time vector
lenTime =length(time);

%%%%%%%%%%% Keeps only the data correspoding to the common time vector
for fileNum = dataFiles
    [fpt,lpt] = deal([]);
    eval(['fpt = min(find(time' num2str(fileNum) '>=firstCommonTime));'])
    eval(['lpt = min(find(time' num2str(fileNum) '>=lastCommonTime));'])
    commonPts = fpt:lpt;
    lenDiff = length(time) - length(commonPts);
    lpt = lpt+lenDiff;
    commonPts = fpt:lpt;
    eval(['data' num2str(fileNum) '= data' num2str(fileNum) '(commonPts,:);'])
end

prompts = {'Channel Pairs to Analyze', 'Highpass Before Rectification (If < 20, no rectification)',...
    'Lowpass after Rectification', 'Time Range', 'Freq Range', 'Statistical Stringency (1 = 95% CI, 2 > 95% CI )',...
    'Phase Filtering ("Alt" = Alternation, "Synch" = Only synchronous, "All" = No filtering)'...
    'Trace type for plotting ("Raw" or "Smoothed")'};
dlgTitle = 'Processing Parameters';
numLines = 1;
defaults = {'1 2 3 4', '50','4','0'}

%% Adjustable signal processing parameters
hpf = 50; % (default = 40)
lpf  = 2; % Low pass filter value after high pass filtering and rectification of data.
% Lpf value gets changed later in the program depending on freq range of interest.

% num_files_loaded = size(fNames,1);
% dataFiles = [1:num_files_loaded];


ch =   [2 1 3];
timeRange = [0 154]; % Time period for which signal is to be displayed in XWT

if numel(ch)<2
    errordlg('Select at least two channels to compare! Enter channel number twice for autowavelet')
    return
end 
    
%% OPTIONS
stopband =[58 62];
denoise = 'y'; % 'y' = removes 60Hz by stopbanding b/w values specified in "stopband"; 'n' = no fitering;
threshdenoising ='n'; %%%% 'y' = gives the option of setting threshold for artifact truncation; 'n' =  no option;


peakStringency = 1;
yShift = 25;

% if max(freqRange) >= floor(1/samplingInt); errordlg('High frequency value above Nyquist limit'), end
% lpf = ceil(freqRange(2)/3);

ques = questdlg('Automatically remove light artifacts?','LIGHT ARTIFACT REMOVAL','Yes','No','No');
if strcmpi(ques,'yes')
    dataStruct_mod = slowartifactremove(dataStruct,samplingInt);

else
    dataStruct_mod = dataStruct;
end


%% PROCESSING DATA
artChk = questdlg('Auto-remove Stimulus Artifacts?');
for fileNum = dataFiles
    eval(['temp' num2str(fileNum) ' = [];'])
    eval(['signal' num2str(fileNum) ' = [];'])
    fstr = num2str(fileNum);
    eval(['temp' fstr ' = chebfilt(data' fstr ',samplingInt,hpf,''high'');']);
    
    %%%% Filtfilt.m Error Message
    blah = eval(['temp' fstr ';']);
    if any(isnan(blah(:)))
        errordlg('Signal Filtering Error! Please re-specify the time range')
    end
    
    if strcmpi(artChk,'yes')
    eval(['temp' fstr ' = autoartremove(temp' fstr ',time);']); 
    else
    end
%     eval(['temp' fstr '=chebfilt(autoartremove(data' fstr...
%         ',time),samplingInt,hpf,''high'');']); % Highpasses
    % ... data and automatically remove stimulus artifacts. Also gets
    % ... rid of the channels not specified at the start of this file.
    if lower(threshdenoising) == 'y';
        eval(['temp' fstr ' = chebfilt(overthreshremove(temp' fstr...
            ',time),samplingInt,hpf,''high'');']); % Manually chops
        %         % ... off stim artifacts that were not properly removed.
    %%%% Filtfilt.m Error Message
    blah = eval(['temp' fstr ';']);
    if any(isnan(blah(:)))
        errordlg('Signal Filtering Error! Please re-specify the time range')
    end
    
    end
    %% DENOISE OR NOT?
    if denoise =='y'
        eval(['temp' fstr ' = double(temp' fstr ');']);
        eval(['temp' fstr '=chebfilt(temp' fstr...
            ',samplingInt,stopband,''stop'');']) %%%%% Stopbands
    %%%% Filtfilt.m Error Message
    blah = eval(['temp' fstr ';']);
    if any(isnan(blah(:)))
        errordlg('Signal Filtering Error! Please re-specify the time range')
    end
    
    end
    
    %% RECTIFYING,LOW-PASSING

    eval(['signal' fstr '=temp' fstr ';'])
    %%%% Filtfilt.m Error Message
    blah = eval(['temp' fstr ';']);
    if any(isnan(blah(:)))
        errordlg('Signal Filtering Error! Please re-specify the time range')
    end
    
    if hpf >= 20 % Rectification only when signal is highpassed over 20Hz
        eval(['f = signal' fstr '<0;'])
        eval(['signal' fstr '(f)=0;'])
    end
    eval(['signal' fstr '=chebfilt(signal' fstr...
        ',samplingInt,lpf,''low'');']) %%%%% Lowpasses
    %%%% Filtfilt.m Error Message
    blah = eval(['signal' fstr ';']);
    if any(isnan(blah(:)))
        errordlg('Signal Filtering Error! Please re-specify the time range')
    end
    
end

