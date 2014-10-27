% GAP2SWEEP - Convert data recorded in gap-free mode to sweep mode.
%   GAP2SWEEP asks the user to select data and time variables from variables 
%   in the matlab workspace. By default, 'data' and 'timeAxis' are chosen
%   since these are the names given to these variables loaded into the
%   workspace by 'load_data.m.' After the variables are chosen the
%   continuous signal traces in 'data' are converted into sweeps with the
%   beginning of each sweep marked by the onset of a stimulus.

%   Modified 02-Jul-2009 03:01:35
%   Author: AP

%% Inputting the timeseries variables
clear channels sweepTime avgChannels j k legchannels legsweeps
prompt={'Enter the data variable name ', 'Enter the time axis variable name'};
dlgTitle='Inputting the data and time value ';
nLines=1;
def = {'data','timeAxis'};
answer=inputdlg(prompt,dlgTitle,nLines,def);
dataVar=eval(answer{1});
timeVar=eval(answer{2});
siVar=mean(diff(timeVar));

%% Obtaining the onset times of stimulus artifacts
t1=stimartdetect(dataVar, timeVar);

%  dataVar = autoartremove(dataVar,timeVar);
% dataVar = chebfilt(dataVar,samplingInt,50,'high');
% dataVar(dataVar < 0)=0;

%% Specifying length of sweep prior to and after stimulus
preStimDur = 5e-3;
preStimPts=round(preStimDur/siVar);
traceDur=250e-3;
traceDurPts=round(traceDur/siVar);
nChannels=size(dataVar,2);

%% Deciding about plotting the channels
answer=questdlg({'Plot channels? '},'To plot or not to plot...','Yes','No','Yes');

%% Creating the 'channels' matrix which contains channels and sweeps
legchannel={};
for k = 1:nChannels
    legsweep={};
    for j=1:length(t1)
        fpt(j)=min(find(timeVar>=t1(j)))-preStimPts;
        lpt(j)=fpt(j)+traceDurPts;
        %         colors={'b','g','r','k','c','m','y'};
        %         c=cell2mat(colors(j));
        %         c=num2str(c);
        channels(:,j,k)=dataVar(fpt(j):lpt(j),k)-dataVar(fpt(j),k);
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
            yMin = -0.5*sigmaCh;
            yMax = 5*sigmaCh;
            ylim([yMin yMax])
            xlim([-2 traceDur*1000])
    end
    end

%% Generating and plotting average of sweeps for all channels

lastPoint = min(find(sweepTime>=(4e-3)));
blah = channels(1:lastPoint,:,:);
meanMat = mean(blah);
meanMat = repmat(meanMat,size(channels,1),1);

channels = channels-meanMat; % Demeaning the sweeps wrt to the mean of the first 5ms

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
