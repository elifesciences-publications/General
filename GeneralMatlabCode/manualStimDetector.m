function tStims= manualStimDetector(data,timeAxis)

%% Automatic detection of fast inflections i.e. stim onsets.
varProd=abs(data);
varProd=cumprod(varProd,2);
varProd=varProd(:,end);
hp=50;
samplingInt=timeAxis(2)-timeAxis(1);
varProd=chebfilt(varProd,samplingInt,hp,'high');
ddVariable=diff(varProd,2);
slopeThresh=abs(3*std(ddVariable));
transients=find(abs(ddVariable)>=abs(slopeThresh))-1;

%% Entering the stimulus frequency and the number of stimuli whose onset
%% is to be detected
prompt={'Enter stimulus frequency ' 'Enter number of stim to detect'};
name ='Detecting stimuli';
numLines=1;
default={'4','40'};
answer = inputdlg(prompt,name,numLines,default);
stimFreq=str2double(answer{1});
nStims=str2double(answer{2});

%% Detecting the first stimulus artifact
answer= questdlg('How would you like to detect the first artifact?',...
    'First artifact detection','Automatic','Manual','Automatic');
switch answer
    case 'Manual'
        plot(timeAxis,varProd)
        legend('Multiplied signal')
        [v]=zinput(1);
%         v([end-1 end])=[-inf inf];
        axis(v);hold on;
        plot(timeAxis,varProd)
        firstStimTime =ginput(1);
        firstStimTime=firstStimTime(1);
        firstStimPt=min(find(timeAxis>=firstStimTime));
        hold off;
        close
    case 'Automatic'
        firstStimPt=min(transients);
end
%% Detecting the subsequent stimuli after the first stimulus.
interStimInt=round((1/stimFreq)/samplingInt);
periStimInt = 3E-3;
periStimInt=round(periStimInt/samplingInt);
stims=zeros(1,nStims);
stims(1)=firstStimPt;
for k = 2:nStims
    tempPts=(stims(k-1)+interStimInt-periStimInt):(stims(k-1)+interStimInt...
        + periStimInt);
    tempTransients=intersect(transients,tempPts);
    if isempty(tempTransients);
        stims(k)= round(median(tempPts));
    else
        stims(k)= min(tempTransients);
    end
    
    xMin= (min(tempPts)*samplingInt);
    xMax= max(tempPts)*samplingInt-1E-3;
%     yMax=  max(varProd(tempPts))*10;
%     yMin= -yMax;
    figure
    plot(timeAxis,varProd)
    hold on
    plot(timeAxis(stims(k)),varProd(stims(k)),'ko')
    xlim([xMin  xMax])
%   ylim([yMin yMax])
    title(['Stim # ' num2str(k) '   ' num2str(timeAxis(stims(k)))])
    shg
    [time,amp,button]=ginput(1);
    timePt=min(find(timeAxis>=time));
    close
    if button ==1
        stims(k)=timePt;
    end
end
tStims=stims.*samplingInt;
