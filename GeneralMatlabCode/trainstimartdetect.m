
% STIMARTDETECT
% Outputs a vector of values corresponding to times of occurence of
% stimulus artifacts.
%
% tStimArts=stimartdetect(data,timeAxis)
% Modified 08-Jul-2008 16:59:47

function tStimArts = stimartdetect(data,timeAxis)
clear tStimArts stimPeaks testTransients
timeShifter = min(timeAxis);
timeAxis=timeAxis - timeShifter; % This adj is necessary in case the starting
                                 % time value is not zero.
samplingInt=mean(diff(timeAxis));
datProd=abs(prod(chebfilt(data,samplingInt,50,'high'),2));
d2data=diff(datProd,2);
slopeThresh=abs(3*std(d2data));
transients=find(abs(d2data)>=slopeThresh);
figure('Name', '   Select X-limits')
plot(timeAxis,datProd)
[x,y]=ginput(2);
xMin=min(x);
xMax =max(x);
minPt = min(find(timeAxis>=xMin));
maxPt = min(find(timeAxis>=xMax));
figure('Name', '   Select an amplitude threshold')
plot(timeAxis,datProd)
 axis([xMin xMax 0 50*std(datProd(minPt:maxPt))]), set(gca,'ytick',[])
[ampThresh]=ginput(1); ampThresh=ampThresh(2);
close
stimPeaks=find(abs(datProd)>=abs(ampThresh));



answer= questdlg('How would you like to detect the first artifact?',...
    'First artifact detection','Automatic','Manual','Automatic');
switch answer
    case 'Manual'
        v=[];
        plot(timeAxis,data),legend('1','2','3','4'), box off
        [v]=zinput(1);
        v([end-1 end])=[-inf inf];
        axis(v);hold on;
        plot(timeAxis,data),legend('1','2','3','4'), box off;
        x =ginput(1);
        xPt=min(find(timeAxis>=x(1)));
        hold off;
        close
    case 'Automatic'
        xPt=min(transients);
end
transients=[xPt; transients(:)];
proxLimit=ceil((200E-6)/samplingInt);
for k = 1:length(transients)
    temp=stimPeaks-transients(k);
    if(find(abs(temp)<=proxLimit))
        transients(k)=transients(k);
    else transients(k)=0;
    end
end

transients(transients==0)=[];
dTransients=diff(transients);
badPts=find(dTransients<=(100*proxLimit));
transients(badPts(1:end))=[];
testTransients=transients-6; %%%%%% modified 062508T2100 (used to be -5)
tStimArts=testTransients.*samplingInt + timeShifter; % The timeShifter additiom
                                                     % is necessary in case
                                                     % there starting time
                                                     % value is not zero.


figure
plot(timeAxis,datProd), hold on
plot(timeAxis(testTransients),datProd(testTransients),'ro')
hold off

