% SWEEPDATA
% Loads atf files into matlab workspace. The atf tiles in this case are
% created from transferring traces from data recroded in high speed
% oscilloscope mode.

% Creates the variables TIME and DATA
% TIME is a vector of time values.
% DATA is matrix of size N by S by C
% N = Number of data points in each trace
% S = Number of sweeps of each trace plus the average trace (last trace)
% C = Number of channels
%% Importing the data file
[file,path]=uigetfile('*.atf');
f=fullfile(path,file);
[header,labels, comments, data]=import_atf(f);
time  = data(:,1)*1e-3;
traces = data(:,2:end);
cd(path) % Change path to that which contains the file opened.
samplingInt = (time(2)-time(1))*1e-3; % Converts sampling interval to seconds.

%% Inputting the number of channels and sweeps
prompt={'How many channels?','How many sweeps?'};
name='Collecting channel and sweep info';
numlines=1;
defaultanswer={'4','20'};
answer=inputdlg(prompt,name,numlines,defaultanswer);

nChannels = str2double(answer{1});
nSweeps = str2double(answer{2});

%% Reshaping data to arrange sweeps and channels along different dimensions.
% Creates a 3-D matrix with 2nd dim representing sweeps & 3rd dim
% representing channels. Also subtracts mean of baseline prior to
% stimulation from all sweeps and then calculates the average and standard
% deviation of the sweeps for all the channels
temp = zeros(length(traces),nSweeps+1,nChannels);
avgSweeps = zeros(length(traces),nChannels);
devSweeps = zeros(length(traces),nChannels);
mu = zeros(1,nChannels);
sigma = zeros(1,nChannels);
counter = 1;
fPt = find(time>=1e-3,1);
lPt = find(time>=4e-3,1);

for k = 1:nChannels
    temp(:,1:nSweeps+1,k) = traces(:,counter:k*(nSweeps+1));
    baseline =  mean(temp(fPt:lPt,1:nSweeps+1,k),1);
    baseMat = repmat(baseline,length(traces),1);
    temp(:,1:nSweeps+1,k)= temp(:,1:nSweeps+1,k)-baseMat;
    temp(:,nSweeps+1,k)  = mean(temp(:,1:nSweeps+1,k),2);
    avgSweeps(:,k) = temp(:,nSweeps+1,k);
    devSweeps(:,k) = std(temp(:,1:nSweeps+1,k)');
    mu(1,k) = mean(avgSweeps(fPt:lPt,k));
    sigma(1,k) = std(avgSweeps(fPt:lPt,k));
    counter = counter+nSweeps+1;
end
data = temp;

%% Determining onset latencies from averages of sweeps
blah = prod(avgSweeps,2);
stimOnset = stimartdetect(blah,time)*1000;
clear blah
question = 'Do you wanna calculate onset latencies for sweep averages?';
dlgTitle = 'Onset latency determination!';
ButtonName = questdlg(question, dlgTitle, 'Yes', 'No', 'Yes');

if strcmpi('Yes',ButtonName)
    muvec_avg = repmat(mu,length(traces),1); % Matricize for ease of plotting
    sigmavec_avg = repmat(sigma,length(traces),1);
    for k = 1:nChannels
        figure
        hold on
        xlabel('Time (ms)')
        ylabel('Amplitude')
        xlim([3 20]),shg
        ymin = mu(k)- 20*sigma(k);
        ymax = mu(k)+ 30*sigma(k);
        ylim ([ymin ymax]), shg
        plot(time*1000,avgSweeps(:,k),'linewidth',2); shg
        plot(time*1000,muvec_avg,'k')
        plot(time*1000, muvec_avg(:,k) + 2*sigmavec_avg(:,k),'r:','linewidth',1.5)
        plot(time*1000, muvec_avg(:,k) - 2*sigmavec_avg(:,k),'r:','linewidth',1.5)
        title('Left-click at the onset of response')
        shg
        [x,y] = ginput(1);
        responseOnsets.(['ch' num2str(k)])= x-stimOnset;
    end
end
clear muvec sigmavec
close all

%% Determining onset latencies from individual sweeps

question = 'Do you wanna calculate onset latencies for individual sweeps?';
dlgTitle = 'Onset latency determination!';
ButtonName = questdlg(question, dlgTitle, 'Yes', 'No', 'Yes');

if strcmpi('Yes',ButtonName)
    mu_sweeps = zeros(nSweeps,nChannels);
    sigma_sweeps = zeros(nSweeps,nChannels);
    responseOnsetsForSweeps = zeros(nSweeps,nChannels);
    for k = 1:nChannels
        for kk = 1:nSweeps
            mu_sweeps(kk,k)= mean(data(fPt:lPt,kk,k));
            sigma_sweeps(kk,k) = std(data(fPt:lPt,kk,k));
            muvec = repmat(mu_sweeps(kk,k),length(traces),1); % Matricize for ease of plotting
            sigmavec = repmat(sigma_sweeps(kk,k),length(traces),1);
            figure
            hold on
            xlabel('Time (ms)')
            ylabel('Amplitude')
            xlim([3 30]),shg
            ymin = mu_sweeps(kk,k)- 10*sigma_sweeps(kk,k);
            ymax = mu_sweeps(kk,k)+ 50*sigma_sweeps(kk,k);
            ylim ([ymin ymax]), shg
            plot(time*1000,data(:,kk,k),'linewidth',2); shg
            plot(time*1000,muvec,'k')
            plot(time*1000, muvec + 2*sigmavec,'r:','linewidth',1.5)
            plot(time*1000, muvec - 2*sigmavec,'r:','linewidth',1.5)
            title('Left-click at the onset of response')
            shg
            [x,y] = ginput(1);
            responseOnsetsForSweeps(kk,k)= x-stimOnset;
            close
        end
    end
end
close all