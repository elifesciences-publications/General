function output = burstenvelope(data,timeAxis);
% BURSTENVELOPE   Obtains envelope of inputted traces
%
%   OUTPUT = BURSTENVELOPE(DATA,TIMEAXIS), outputs highpassed, rectified &
%   lowpassed timeseries signals contained in DATA and also plots it against
%   TIMEAXIS.
%
%   Modified: 12-Jun-2009 20:57:21
%   Author: AP

%% Preset variables
hp = 40; % Highpass value
lp = 1;  % Lowpass value
ch = [2 3];
samplingInt = timeAxis(2)-timeAxis(1);
lw = 2;  % linewidth for plots

%% Checking that there are enough input arguments
if nargin <2
    error('And who will enter the other input argument');
elseif nargin>2
    error('Too many input arguments you dope!')
end

%% Computing the smoothed traces & z-score normalizing them
stimTimes = stimartdetect(data,timeAxis);
stimOnset = stimTimes(1);
stimOnsetPt = min(find(timeAxis>=stimOnset));
output = data(:,[ch]);
output = autoartremove(output,timeAxis);
output = chebfilt(output,samplingInt,hp,'high');
output(output<0)=0;
output = chebfilt(output,samplingInt,lp,'low');
output = zscore(output);

%% Plotting the smoothed traces
colors = ['b','g','r','k','m','c'];
figure('name','Smoothed traces')
hold on
for chNum = 1:length(ch)
    if chNum>6
        plot(timeAxis,output(:,chNum)-(chNum)*5,'color',rand(1,3),...
            'linewidth',lw)
    elseif chNum == 2
        plot(timeAxis,output(:,chNum)-(chNum)*5,'color',[0 0.4 0],...
            'linewidth',lw)
    else
        plot(timeAxis,output(:,chNum)-(chNum)*5, colors(chNum),...
            'linewidth',lw)
    end
end
plot(stimOnset,output(stimOnsetPt,end)-4,'rv','linewidth',lw)
xlim([-inf inf])
ylim([-inf inf])
box off
set(gca,'ytick',[],'ycolor','w','tickdir','out')

