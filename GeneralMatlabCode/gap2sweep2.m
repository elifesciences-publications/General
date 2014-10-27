clear channels avgChannels j k legchannels legsweeps
%% Inputting the timeseries variables
prompt={'Enter the data variable name ', 'Enter the time axis variable name'};
dlgTitle='Inputting the data and time value ';
nLines=1;
def = {'data','timeAxis'};
answer=inputdlg(prompt,dlgTitle,nLines,def);
dataVar=eval(answer{1});
timeVar=eval(answer{2});
siVar=mean(diff(timeVar));

%% Obtaining the onset times of stimulus artifacts
t1=stimartdetect(dataVar,timeVar);

%% Specifying length of sweep prior to and after stimulus
preStimDur = 5e-3;
preStimPts=round(preStimDur/siVar);
traceDur=2500e-3;
traceDurPts=round(traceDur/siVar);
nChannels=size(dataVar,2);
answer = questdlg('Would you like to verify stimulus onset times? '...
    ,'Yes','No');
if strcmp(answer,'Yes')
    dataVarProd=cumprod(dataVar,2);
    dataVarProd = dataVarProd(:,end);
    sigma= std(dataVarProd);
    mu = mean(dataVarProd);
    yMin = mu - 10*sigma;
    yMax = mu + 10*sigma;
    clf,plot(timeVar,dataVarProd),ylim([yMin yMax]), title('Select Y axis limits')
    [x,y] = ginput(2);
    yMin = min(y);
    yMax = max(y);
    for k = 1:length(t1)
        fpt(k)=min(find(timeVar>=t1(k)))-floor(preStimPts/2);
        lpt(k)=fpt(k)+ round(5e-3/siVar);
        stimPt(k) = min(find(timeVar>=t1(k)));
        clf, plot(timeVar(fpt(k):lpt(k)),dataVarProd(fpt(k):lpt(k)),...
            'linewidth',1.5)
        axis([-inf inf yMin yMax])
        hold on
        plot(t1(k),dataVarProd(stimPt(k)),'ro')
        hold off
        [x,y,button] = ginput(1)
        if button==3
            t1(k)=t1(k);
        else
            t1(k)=x;
        end
    end
end

%% Deciding about plotting the channels
answer=questdlg({'Plot channels? '},'To plot or not to plot...','Yes','No','Yes');

%% Creating the 'channels' matrix which contains channels and sweeps
legchannel={};
for k = 1:nChannels
    legsweep={};
    for j=1:length(t1)
        fpt(j)=min(find(timeVar>=t1(j)))-preStimPts;
        lpt(j)=fpt(j)+traceDurPts;
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
mat=mean(channels,2); % A matrix with sweeps of each channel averaged
avgChannels=zeros(size(mat,1),size(mat,3),size(mat,2));
avgChannels(:,:,1)=mat(:,1,:); % Converting 3rd dimension into 2nd
avgChannels(:,:,2:end)=[]; % Eliminating the 3rd dimension
switch answer
    case 'Yes'
        figure('Name','Averaged sweeps for each channel')
        plot(sweepTime*1000,avgChannels,'Linewidth', 1.5)
        legend(legchannel)
        ylim([yMin yMax])
end
clear dataVar timeVar siVar
close all
