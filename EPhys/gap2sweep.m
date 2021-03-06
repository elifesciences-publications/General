% GAP2SWEEP - Convert data recorded in gap-free mode to sweep mode.
%   GAP2SWEEP asks the user to select data and time variables from variables 
%   in the matlab workspace. By default, 'data' and 'timeAxis' are chosen
%   since these are the names given to these variables loaded into the
%   workspace by 'loaddata.m.' After the variables are chosen the
%   continuous signal traces in 'data' are converted into sweeps with the
%   beginning of each sweep marked by the onset of a stimulus.

%   Modified 26-Oct-2014 16:45:
%   Author: AP

%% Setting some values
preStimDur = 5e-3; % In seconds
traceDur=250e-3;

onsetThresh = 2; % In terms of std of baseline
kernelWidth = 1e-3; % In seconds - used for onset detection
refPeriod = 2e-3; % Time after stimulus to not look for response onset

manualDetection = true;

%% Inputting the timeseries variables
clear channels sweepTime avgChannels j k legchannels legsweeps
prompt={'Enter the data variable name ', 'Enter the time axis variable name'};
dlgTitle='Inputting the data and time value ';
nLines=1;
def = {'data','timeAxis'};
answer=inputdlg(prompt,dlgTitle,nLines,def);
dataVar=eval(answer{1});
timeVar=eval(answer{2});
siVar= median(diff(timeVar));

%% Obtaining the onset times of stimulus artifacts
tStimuli=stimartdetect(dataVar, timeVar,10,[],5); % Find transients that are at least 5 seconds apart
iStimuli = round(tStimuli/siVar)-1;

%  dataVar = autoartremove(dataVar,timeVar);
% dataVar = chebfilt(dataVar,samplingInt,50,'high');
% dataVar(dataVar < 0)=0;

%% Specifying length of sweep prior to and after stimulus
preStimPts=round(preStimDur/siVar);
traceDurPts=round(traceDur/siVar);
nChannels=size(dataVar,2);

%% Deciding about plotting the channels
answer=questdlg({'Plot channels? '},'To plot or not to plot...','Yes','No','Yes');

%% Creating the 'channels' matrix which contains channels and sweeps
legchannel={};
channels = [];
tOnsets = zeros(length(tStimuli),nChannels);
kernel = hamming(ceil(kernelWidth/siVar));
refPts = ceil(refPeriod/siVar);
for k = 1:nChannels
    legsweep={};
    for j=1:length(tStimuli)
        fpt(j)=min(find(timeVar>=tStimuli(j)))-preStimPts;
        fpt(j) = max(1,fpt(j)); % In case the pre-stim period is longer than when the 1st stim begins
        lpt(j)=fpt(j)+traceDurPts; 
        lpt(j) = min(length(timeVar),lpt(j)); % In case the trace duration does not fit the trace.
        %         colors={'b','g','r','k','c','m','y'};
        %         c=cell2mat(colors(j));
        %         c=num2str(c);
        baselineMean = mean(dataVar(fpt(j):iStimuli(j),k));
        baselineStd = std(dataVar(fpt(j):iStimuli(j),k));
        
        %         channels(:,j,k)=dataVar(fpt(j):lpt(j),k)-dataVar(fpt(j),k);
        channels(:,j,k) = dataVar(fpt(j):lpt(j),k) - baselineMean; % Baseline adjustment
%         smoothTrace = conv(dataVar(iStimuli(j)+1 + refPts:lpt(j)),kernel(:),'same');
        smoothTrace = dataVar(iStimuli(j)+1 + refPts:lpt(j),k);
        thresh =  onsetThresh *baselineStd;
        tOnsets(j,k) = min(find(smoothTrace(1:end-2)>=thresh & smoothTrace(2:end-1)>=thresh & smoothTrace(3:end)>=thresh));
        tOnsets(j,k) = (tOnsets(j,k)+ refPts)*siVar;

        legsweep=[legsweep; num2str(j)];
    end
    legchannel=[legchannel; num2str(k)];    
    
    %% Plotting the channels and sweeps
    switch answer
        case 'Yes'
            figName=['Channel' num2str(k)];
            figure('Name',figName)
            sweepTime=(0:size(channels,1)-1)*siVar;
            plot(sweepTime*1000,channels(:,:,k),'Linewidth',1.5);
            legend(legsweep)
            sigmaCh = std(dataVar(:,k));
            yMin = -2*sigmaCh;
            yMax = 20*sigmaCh;
            ylim([yMin yMax])
            xlim([-5 traceDur*1000])
    end
end
    
%% Generating and plotting average of sweeps for all channels

mat=mean(channels,2); % A matrix with sweeps of each channel averaged
avgChannels=zeros(size(mat,1),size(mat,3),size(mat,2));
avgChannels(:,:,1)=mat(:,1,:); % Converting 3rd dimension into 2nd
avgChannels(:,:,2:end)=[]; % Eliminating the 3rd dimension

% avgChannels_deArt = autoartremove()

switch answer
    case 'Yes'
        figure('Name','Averaged sweeps for each channel')
        plot(sweepTime*1000,avgChannels,'Linewidth', 1.5)
        legend(legchannel)
        ylim([yMin yMax])
             end
clear dataVar timeVar siVar
close all

%% Manual Onset Detection
if manualDetection
mOnsets = zeros(length(tStimuli),nChannels);
figure
for cn = 1:nChannels
    for sn = 1:length(tStimuli)
        plot(sweepTime*1000,channels(:,sn,cn))
        title(['Chan Num: ' num2str(cn) ', Stim Num: ' num2str(sn)])
        xlim([-inf 25])
        ylim([-100 200])
        [mOnsets(sn,cn),~] = ginput(1);
    end
  end
end
close