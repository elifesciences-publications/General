
% AUTOARTREMOVE Automatically removes stimulus artifacts.
%   data_mod = autoartremove; selects data from workspace variables and
%   returns it with stimulus artifacts removed programmatically.
% 
%   data_mod = autoartremove(data,timeAxis); returns deartifacted data when
%   data is specified as input along with the time vector.
%
% Author: AP
% Modified 08-Jun-2009 

function data_mod = autoartremove(varargin);
if isempty(varargin)
    load_data
elseif nargin < 2
    error('Insufficient input: You must enter the time vector as well');
else
data= varargin{1};
timeAxis = varargin{2};
samplingInt = mean(diff(timeAxis));
end 

% %% Discard first column if its is time vector
% tOrNot=diff(data(:,1));
% if tOrNot(1)==tOrNot(2);
%     data(:,1)==[];
% end

%% Define some variables
dData=diff(data);
ddData=diff(dData);
clear data_mod;
data_mod=cell(1,size(data,2));


kernelRange = 1; % The width of the kernel in seconds.
kernelRangeInPts = round(kernelRange/samplingInt);
halfWidthInPts = round(kernelRangeInPts/2);
% gaussKernel=normpdf(-halfWidthInPts:halfWidthInPts,0, kernelRangeInPts/6);
 gaussKernel=hamming(kernelRangeInPts);
stimDuration = 0.2; % In milliseconds (default = 0.5)
stimDuration = stimDuration * 1e-3; % In seconds
stimDurationPts = round(stimDuration/samplingInt);
timeToEraseAfterStim = 3; % Time in ms (default = 10ms)
timeToEraseAfterStim = timeToEraseAfterStim *1e-3; % Converting to seconds.
ptsToEraseAfterStim = round(timeToEraseAfterStim/samplingInt);
removalPts = ptsToEraseAfterStim + stimDurationPts;
%% Go through the data column-by-column
for i=1:size(data,2)
    clear transientPts missingPts fillPts
    transientPts=find(abs(ddData(:,i))>(mean(ddData(:,i))+4*std(ddData(:,i))));
    transientPts=transientPts+2; % Compensating for shift due to double derivative
    d=diff(transientPts);
    transientPts(find(d==1)+1)=[]; % Eliminate points that are consecutive
    transientPts(transientPts<5)=[]; % Eliminate points that occur before 500 microseconds
    temp1=transientPts-3; % Just to be safe
    temp2=transientPts+ptsToEraseAfterStim;
    transientPts=unique(sort([temp1(:); transientPts(:); temp2(:)]));

    missingPts=[];
    for j=2:length(transientPts)
        %    if ((transientPts(j)-transientPts(j-1))>1 && (transientPts(j)-transientPts(j-1))<450)
        if ((transientPts(j)-transientPts(j-1))>1 && (transientPts(j)-transientPts(j-1))<=removalPts)
            fillPts= transientPts(j-1):transientPts(j);
            missingPts=[missingPts(:); fillPts(:)];
        end
    end
    transientPts= unique(sort([transientPts(:); missingPts(:)]));
    if max(transientPts)> length(data)
%         errordlg('Error in Stimulus Artifact Detection')
    transientPts(transientPts>length(data))=length(data);    
    end

    y=data(:,i);
    for jj=1:length(transientPts)
        if transientPts(jj)<=100
            y(transientPts(jj))= mean(y(1:transientPts(jj)-2))+...
                std(y(1:transientPts(jj)-2))*rand;
        else
            y(transientPts(jj))= mean(y(transientPts(jj)-99:transientPts(jj)-2))+...
                std(y(transientPts(jj)-99:transientPts(jj)-2))*rand;
        end
    end

    data_mod{:,i}=y;
end
 data_mod= cell2mat(data_mod);

%% Clear variables that take up space unnecessarily
clear tORNot f i j fillPts missingPts temp1 temp2 kernelRange trace_mod
