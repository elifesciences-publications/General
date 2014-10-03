


function tStimArts = stimartdetect(varargin)
% STIMARTDETECT
% Outputs a vector of values corresponding to the times of occurence of
% stimulus pulses/artifacts in inputted data.
%
% tStimArts = stimartdetect(data,timeAxis);
% tStimArts - A vector of times of occurrence of stimulus pulses/artifacts
% data - Matrix of traces containing stimuli with time increasing along the
%        row dimension
% timeAxis - Time vec
%
%
% tStimArts = stimartdetect(data,timeAxis,slopeThresh);
% slopeThresh = Threshold for detecting slopes in units of std. For eg.,
% a value of 3 implies detecting points with slopes greater than 3 times
% the mean slopes (default = 3)
%
%
% tStimArts = stimartdetect(data,timeAxis,slopeThresh,ampThresh);
% ampThresh = Amplitude threshold in units of std (default = 20)
% tStimArts = stimartdetect(data,timeAxis,[],ampThresh);
%   Detects stimuli based on amplitude only
% tStimArts = stimartdetect(data,timeAxis,..,[])
%   Interative choosing of amplitude threshold
%
%
% tStimArts = stimartdetect(data,timeAxis,slopeThresh,ampThresh,'MINPEAKDISTANCE',minPeakDistance);
% tStimArts = stimartdetect(data,...,[]);
%   minPeakDistance defaults to 200 microseconds
%
% Author: AP

%% Default Values
defSlopeThresh = 3;
defAmpThresh = []; % Indicates not using amplitude (ampThresh = 'UI' implies interative choosing of amplitude)
defMinPeakDistance = 200e-6; % Typical duraction (sec) of stimulus pulse in our expts

data = varargin{1};
timeAxis = varargin{2};
if nargin < 2
    errordlg('STIMARTDETECT needs at least 2 inputs!')
    return;
elseif nargin < 3
    slopeThresh = defSlopeThresh;
    ampThresh = defAmpThresh;
    minPeakDistance = defMinPeakDistance; 
elseif nargin < 4
    slopeThresh = varargin{3};
    ampThresh = defAmpThresh;
    minPeakDistance = defMinPeakDistance;
elseif nargin < 5
    slopeThresh = varargin{3};
    ampThresh = varargin{4};   
    minPeakDistance = defMinPeakDistance;
else
    slopeThresh = varargin{3};
    ampThresh = varargin{4};
    minPeakDistance = varargin{5};
end

if isempty(slopeThresh) && isempty(ampThresh)
    slopeThresh = 3;
elseif isempty(slopeThresh) && ~isempty(ampThresh)
    slopeThresh = 0;
end

if isempty(minPeakDistance)
    minPeakDistance = defMinPeakDistance;
end

timeAxis = timeAxis - min(timeAxis); % This adj is necessary in case the starting time value is not zero.
samplingInt = timeAxis(2) - timeAxis(1);


%% Data Reshaping
%%%% Assuming that there are more time points than signals, reshaping the
%%%% data matrix such that time increases with row #
if size(data,2)> size(data,1)
    data = data'; 
elseif size(data,2) == size(data,1)
    errordlg('Make sure that the row of the data matrix represents change in time/space')
end

datProd=abs(prod(chebfilt(data,samplingInt,50,'high'),2)); % To amplify the stimulus artifacts in relation to other noise 
%% Slope-based identification of stimulus artifact times
if (slopeThresh~=0)
fprintf('\nSlope-based identification of stimuli...\n')
d2data=diff(datProd,2); % 2nd derivative gives the highest value for stimulus artifact onset
d2data_abs = abs(d2data); 
slopeThresh= slopeThresh*std(d2data_abs);
transients=find(d2data_abs >= slopeThresh);
else 
 transients  = [];
end


%% Amplitude threshold-based identification of artifact times
if (nargin > 3) && (strcmpi(ampThresh,'UI'))
fprintf('\nAmplitude-based identification of stimuli...\n')
    figure('Name', 'Click on 2 locations along the time axis to expand traces')
    title('Detecting stimulus artifacts')
    plot(timeAxis,datProd)
    [x,y]=ginput(2);
    close    
    minPt = find(timeAxis>= min(x)); minPt = minPt(1);
    maxPt = find(timeAxis>=max(x)); maxPt = maxPt(1);
    figure('Name', '   Select an amplitude threshold')
    plot(timeAxis,datProd)
    axis([min(x) max(x) 0 30*std(datProd(minPt:maxPt))]), set(gca,'ytick',[])
    ampThresh = ginput(1); ampThresh=ampThresh(2);
    stimPeaks = find(abs(datProd)>=abs(ampThresh)); 
    close
elseif (nargin > 3) && ~(isempty(ampThresh))
fprintf('\nAmplitude-based identification of stimuli...\n')
    ampThresh = mean(datProd) + ampThresh*std(datProd);
    stimPeaks = find(abs(datProd)>=abs(ampThresh));
else
    stimPeaks = transients;
end


if isempty(transients) && (slopeThresh==0)
    transients = stimPeaks; % transients is used in the later part of the program
end


% answer= questdlg('How would you like to detect the first artifact?',...
%     'First artifact detection','Automatic','Manual','Automatic');
% switch answer
%     case 'Manual'
%         v=[];
%         plot(timeAxis,data),legend('1','2','3','4'), box off
%         [v]=zinput(1);
%         v([end-1 end])=[-inf inf];
%         axis(v);hold on;
%         plot(timeAxis,data),legend('1','2','3','4'), box off;
%         x =ginput(1);
%         xPt = find(timeAxis>=x(1)); xPt = xPt(1);
%         hold off; close
%     case 'Automatic'
%         xPt=min(transients);
% end

%% Cross-validation
if slopeThresh && ~isempty(ampThresh)
fprintf('\nCross-validating...\n')
end
xPt = min(transients);
transients(transients<xPt)=[];
transients=[xPt; transients(:)];
proxLimit=ceil(minPeakDistance/samplingInt); % 200 usec b/c this is usually the width of the stim pulse
for k = 1:length(transients)
    temp=stimPeaks-transients(k);
    if(find(abs(temp)<=proxLimit))
        transients(k)=transients(k);
    else transients(k)=0;
    end
end
transients(transients==0)=[];
dTransients=diff(transients);
badPts=find(dTransients<=proxLimit);
transients(badPts(1:end))=[];
testTransients=transients-6; % Since the stim artifact is very likely to get detected
tStimArts= timeAxis(testTransients) + min(timeAxis);  % The timeShifter addition
                                                     % is necessary in case
                                                     % the starting time

fprintf('\nDone!\n')

