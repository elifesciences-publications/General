
function pkInds = FindStimPulses(varargin)
% FindStimPulses - Returns the indices of stimulus pulses/artifacts in a
%   timeseries
% stimInds = FindStimPulses(x,slopeThresh,ampThresh,minPeakDistance)
% Inputs:
% x - timeseries in which to find stim pulse
% slopeThresh - slope threshold in units of std for detecting pulse onset
%   (default = 20)
% ampThresh - amplitude threshold in units of std (default = 20)
% minPeakDistance - minimum expected distance between consecutive peaks
% stimInds = FindStimPulse(...,'exact'), using the 'exact' option results
%   in finding peaks that are exactly above the specified amplitude
%   threshold
%
% Author: AP

%% Default Values
x = varargin{1};
defSlopeThresh = [];
defAmpThresh = 20;
defMinPkDist = 3;

if nargin == 1;
    x = zscore(x);
    slopeThresh = defSlopeThresh;
    ampThresh = defAmpThresh;
    minPkDist = defMinPkDist;
elseif nargin == 2
    slopeThresh = varargin{2};
    x = zscore(x);
    ampThresh = defAmpThresh;
    minPkDist = defMinPkDist;
elseif nargin ==3
    slopeThresh = varargin{2};
    ampThresh  = varargin{3};
    x = zscore(x);
    minPkDist = defMinPkDist;
elseif nargin ==4
    slopeThresh = varargin{2};
    ampThresh  = varargin{3};
    minPkDist = varargin{4};
    x = zscore(x);
elseif nargin ==5 & strcmpi(varargin{5},'exact')
    slopeThresh = varargin{2};
    ampThresh  = varargin{3};
    minPkDist = varargin{4};
elseif nargin > 5
    error('No more than 5 inputs accepted!')
else
    error('Please check inputs!')
end

if isempty(slopeThresh)
    slopeThresh = defSlopeThresh;
end

if isempty(ampThresh)
    ampThresh = defAmpThresh;
end
if isempty(minPkDist)
    minPkDist = defMinPkDist;
end

pkInds = GetPks(x);
pkInds(x(pkInds)<ampThresh) = [];

% Validating each pk by checking for a nearby preceding onset
if ~isempty(slopeThresh)
    dx = zscore(diff(abs(x)));
    onsetInds = GetPks(dx);
    onsetInds(dx(onsetInds)< slopeThresh) = [];
    if isempty(onsetInds)
        error('Did not find any onset points, consider lowing slope threshold!')
    end
    removeInds = [];
    for pk = 1:numel(pkInds)
        pkOnLat = pkInds(pk)-onsetInds;
        if ~ any((pkOnLat>=1 & pkOnLat<5))
            removeInds = [removeInds;pk];
        end
    end
    pkInds(removeInds) =[];
end


%% Nearest neighbor method of eliminating all transients
disp('Eliminating artifacts closer than minimum specified distance...')
amps = ones(size(pkInds));
[~, pkInds] = RemovePeaksWithinRefractoryPeriod(amps, pkInds, minPkDist);





