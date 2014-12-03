% BURSTDURATIONCALCULATOR
% Plots burst by burst and allows user to determine burst onset and then
% computes burst onset in milliseconds with respect to stimulus time.
nFiles = 1;
stimNum = 6;
chosenChannel = 4;
xFirst = 100e-3; % Starts xlim from 10ms before stim onset
xLast = 7; % Ends xlim at 5s after stim onset
hp = 40;
lp = 1000;
durations = zeros(stimNum,nFiles);
for i = 1:nFiles
    load_data
    fileName = file(1:8);
    stimTimes = stimartdetect(data,timeAxis); % Detecting times of stimuli
    dStimTimes = diff(stimTimes);
    invalids = find(dStimTimes<=1);
    stimTimes(invalids+1) = [];
    temp = data(:,chosenChannel); % Choosing one channel
    temp = chebfilt(temp,samplingInt,[hp lp]); % Filtering signals
    for j = 1:stimNum % Delays only for first 11 bursts
        tFirst = stimTimes(j)-xFirst; % First time value of x-axis
        tLast = stimTimes(j)+ xLast; % Last time value of x-axis
        ptFirst = min(find(timeAxis>=tFirst)); % In point value
        ptLast = min(find(timeAxis>=tLast));
        stimPt = min(find(timeAxis>=stimTimes(j)));
        plot(timeAxis(ptFirst:ptLast), temp(ptFirst:ptLast),'b','linewidth',2)
        title('Detect burst onset and offset')
        set(gcf,'Name',fileName)
        hold on, plot(timeAxis(stimPt),0,'r^','linewidth',2), hold off
        ylim([-500 500])
        xlim([-inf inf])
        [x,y] = ginput(2);
        durations(j,i) = x(2)-x(1);
    end
    durations(:,i) = round((durations(:,i))*1000);
end
durations(durations<=100)=nan;

