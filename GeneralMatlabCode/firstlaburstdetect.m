%% Variables
channels = [2 3];
hp = 50;
samplingInt = timeAxis(2)-timeAxis(1);
kernelRange = 250e-3; % In milliseconds
kernel = hamming(round(kernelRange/samplingInt));

%% Data Processing
data_mod = data(:,channels);
[data_mod,timeAxis_mod,stimTimes] = psrcompare(data_mod,timeAxis);
data_mod = autoartremove(data_mod,timeAxis_mod);
data_mod = chebfilt(data_mod,samplingInt,hp,'high');
data_mod = overthreshremove(data_mod,timeAxis_mod);
data_mod(data_mod<0)=0;
fpt = min(find(timeAxis_mod>-20));
lpt = min(find(timeAxis_mod>30));
data_smooth = conv2(data_mod(fpt:lpt,:),kernel(:),'same');
time_smooth = timeAxis_mod(fpt:lpt);

%% Plotting data for determining sigmas of traces
staggerMat = repmat(20*[1:size(data_smooth,2)],size(data_smooth,1),1);
figure('Name','Selecting region of data for std calculation')
plot(time_smooth,data_smooth-staggerMat)
title('Select x-lims')
xlim([-10 10])
ylim([-inf inf])
[x,y] = ginput(2);
fpt = min(find(time_smooth>x(1)));
lpt = min(find(time_smooth>x(2)));
temp = data_smooth(fpt:lpt,:);
sigmaMat = std(temp);
meanMat = mean(temp);
threshMat = meanMat+50*sigmaMat;
threshMat = threshMat(:)';
threshMat = repmat(threshMat,size(data_smooth,1),1);

%% Detecting burst onsets
onset = zeros(size(data_smooth,2),1);
   clf
    plot(time_smooth,data_smooth-staggerMat,'linewidth',2);
    hold on
    plot(time_smooth,threshMat-staggerMat,':','linewidth',2);
xlim([-2 4])
ylim([-inf inf])
shg
    