
function stimInds = FindStimPulses(varargin)
% FindStimPulses - Returns the indices of stimulus pulses/artifacts in a
% time series
% 
% signals - Matrix of traces containing stimuli with time increasing along the
%        row dimension
%
% stimInds = FindStimPulses(signals);
% slopeThresh = Threshold for detecting slopes in units of std. For eg.,
% a value of 3 implies detecting points with slopes greater than 3 times
% the mean slopes (default = 3)
%
%
% stimInds = stimartdetect(data,timeAxis,slopeThresh,ampThresh);
% ampThresh = Amplitude threshold in units of std (default = 20)
% stimInds = stimartdetect(data,timeAxis,[],ampThresh);
%   Detects stimuli based on amplitude only
% stimInds = stimartdetect(data,timeAxis,..,[])
%   Interative choosing of amplitude threshold
%
%
% stimInds = stimartdetect(data,timeAxis,slopeThresh,ampThresh,minPeakDistance);
% stimInds = stimartdetect(data,...,[]);
%   minPeakDistance defaults to 500 microseconds
%
% Author: AP

%% Default Values
defSlopeThresh = 3;
defAmpThresh = []; % Indicates not using amplitude (ampThresh = 'UI' implies interative choosing of amplitude)
defMinPeakDistance = 1e-3; % Typically, the stim pulse duraction does not exceed this value in our expts

signals = varargin{1};

%% Make sure that signals are arranged as columns
if size(signals,2) >  size(signals,1)
    signals = signals';
elseif size(signals,2) == size(signal,s1)
    warndlg('Make sure that the timeseries form columns of the input matrix')
end
signals = zscore(detrend(mean(signals,2))); % Assuming all signals have coincident stimulus pulses


%%
if nargin ==0
    errordlg('Please enter an input!')
elseif nargin < 2
    slopeThresh = defSlopeThresh;
    ampThresh = defAmpThresh;
    minPeakDistance = defMinPeakDistance; 
elseif nargin < 3
     slopeThresh = varargin{2};
    ampThresh = defAmpThresh;
    minPeakDistance = defMinPeakDistance; 
elseif nargin < 4
    slopeThresh = varargin{2};
    ampThresh = varargin{3};
    minPeakDistance = defMinPeakDistance;
else
    slopeThresh = varargin{2};
    ampThresh = varargin{3};   
    minPeakDistance = varargin{4};
end

if isempty(slopeThresh) && isempty(ampThresh)
    slopeThresh = defSlopeThresh;
elseif isempty(slopeThresh) && ~isempty(ampThresh)
    slopeThresh = 0;
end

if isempty(minPeakDistance)
    minPeakDistance = defMinPeakDistance;
end


%% Slope-based identification of stimulus artifact onsets
if (slopeThresh~=0)
fprintf('\nSlope-based identification of stimuli...\n')
d2data=diff(signals,2); % 2nd derivative gives the highest value for stimulus artifact onset
slopeThresh= mean(d2data) + slopeThresh*std(d2data);
transients=find(d2data >= slopeThresh);
else 
 transients  = [];
end
transients = transients + 1; % Because of 2nd derivative 

%% Amplitude threshold-based identification of artifact times
if (nargin > 3) && (strcmpi(ampThresh,'UI'))
fprintf('\n Amplitude-based identification of stimuli... \n')
    figure('Name', 'Click on 2 locations along the time axis to expand traces')
    title('Detecting stimulus artifacts')
    plot(time,signals)
    [x,~]=ginput(2);
    close    
    minPt = find(time>= min(x)); minPt = minPt(1);
    maxPt = find(time>=max(x)); maxPt = maxPt(1);
    figure('Name', ' Select an amplitude threshold')
    plot(time,signals)
    axis([min(x) max(x) 0 30*std(signals(minPt:maxPt))]), set(gca,'ytick',[])
    ampThresh = ginput(1); ampThresh=ampThresh(2);
    stimPeaks = find(signals >= ampThresh);
%     stimPeaks = find(abs(datProd)>=abs(ampThresh)); 
    close
elseif (nargin > 3) && ~(isempty(ampThresh))
fprintf('\n Amplitude-based identification of stimuli... \n')
    stimPeaks = find(signals >= ampThresh);
else
    stimPeaks = transients;
end

if isempty(transients) & (slopeThresh==0)
    transients = stimPeaks; % transients is used in the later part of the program
end

transients = union(transients(:), stimPeaks(:));



%% Nearest neighbor method of eliminating all transients
fprintf('\n Eliminating artifacts closer than minimum specified distance... \n')
amps = ones(size(transients));
[amps, transients] = RemovePeaksWithinRefractoryPeriod(amps, transients, minPeakDistance);

stimInds = transients; 


