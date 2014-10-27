% BURSTONSETCALCULATE
% Plots burst by burst and allows user to determine burst onset and then
% computes burst onset in milliseconds with respect to stimulus time.
nFiles = 1;
stimNum = 4;
chosenChannel = [1:4]; % The channels whose delays are to be calculated.
xFirst = 50e-3; % Starts xlim from xFirst(def = 10)ms before stim onset
xLast = 1500e-3; % Ends xlim at xLast (def = 1500) ms after stim onset
hp = 40;
lp = 10;
kw = 100e-3; % kernel width in kw ms(def = 50)
% activity = 'stim'; % Type of activity to analyze ('stim' = stim evoked;
                   % 'spont' = spont)
activity = questdlg('Type of activity?', ...
                         'Activity Type', ...
                         'Stim', 'Spont','Stim');
for i = 1:nFiles
    load_data
    fileName = file(1:8);
    kernel = hamming(round(kw/samplingInt)); % Kernel function
    kernel = kernel(:); % Columnize kernel
    thresh = 1*ones(size(timeAxis));
    if strcmpi(activity, 'spont')
        stimTimes = eventdetect(data,timeAxis);
        stimNum = length(stimTimes);
    else
    stimTimes = stimartdetect(data,timeAxis); % Detecting times of stimuli
    dStimTimes = diff(stimTimes);
    invalids = find(dStimTimes<=1);
    stimTimes(invalids) = []; % Keeping only the last stim of the train
    end
    temp = data(:,chosenChannel); % Choosing channels
    temp = autoartremove(temp,timeAxis);
    temp = chebfilt(temp,samplingInt,hp,'high'); %
    temp(temp<0)=0;
    temp = zscore(conv2(temp,kernel,'same'));
    onsets = zeros(stimNum,nFiles,numel(chosenChannel));
    
    for j = 1:stimNum % Delays only for first stimNum bursts
        tFirst = stimTimes(j)-xFirst; % First time value of x-axis
        tLast = stimTimes(j)+ xLast; % Last time value of x-axis
        ptFirst = min(find(timeAxis>=tFirst)); % In point value
        ptLast = min(find(timeAxis>=tLast));
        stimPt = min(find(timeAxis>=stimTimes(j)));
        %         colors = ['b','g','r','k'];
         plot(timeAxis(ptFirst:ptLast), temp(ptFirst:ptLast,:),'linewidth',2)
%         legend([1:numel(chosenChannel)],'Location','best')
        title('Set X-Limits for burst onset detection')
        set(gcf,'Name',fileName)
        hold on
        plot(timeAxis(stimPt),0,'r^','linewidth',2)
        plot(timeAxis(ptFirst:ptLast),thresh(ptFirst:ptLast),'k:')
        axis([-inf inf -inf inf])
        [xLims,y,button] = ginput(2);
        xlim([xLims(1) xLims(2)])
        ylim([-1 3])
        title('Choose onset times for channels')
        [x,y,button] = ginput(numel(chosenChannel));
        x(button==3)=nan;
        onsets(j,i,:) = x;
        hold off
       end
    for k = 1:numel(chosenChannel)
        onsets(:,i,k) = round((onsets(:,i,k) - stimTimes(1:stimNum))*1000);
    end
end
onsets(onsets<=20)=nan;
close all
mat = zeros(size(onsets,1),size(onsets,3));
mat(:,:) = onsets(:,1,:);
minVec = min(mat')';
minMat = repmat(minVec,size(minVec,2),size(mat,2));
mat = mat-minMat;
plot(mat','o-')
[sortMat,order] = sort(mat,2)