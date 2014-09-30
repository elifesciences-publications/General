
% STIMARTDETECT
% Outputs a vector of values corresponding to the times of occurence of
% stimulus artifacts in inputted data.
%
% tStimArts=stimartdetect(data,timeAxis)
% 
% Author: AP

function tStimArts = stimartdetect(data,timeAxis)
timeAxis = timeAxis - min(timeAxis); % This adj is necessary in case the starting time value is not zero.
samplingInt = timeAxis(2) - timeAxis(1);

%% Data Reshaping
%%%% Assuming that there are more time points than signals, reshaping the
%%%% data matrix such that time increases with row #
if size(data,2)> size(data,1)
    data = data'; 
elseif size(data,2) == size(data,1)
    errordlg('Make sure that the row of the data matrix represents change in time/space')
end
    
%% Slope-based identification of stimulus artifact times
datProd=abs(prod(chebfilt(data,samplingInt,50,'high'),2)); % To amplify the stimulus artifacts in relation to other noise 
d2data=diff(datProd,2); % 2nd derivative gives the highest value for stimulus artifact onset
d2data_abs = abs(d2data); 
slopeThresh= 3*std(d2data_abs);
transients=find(d2data_abs >= slopeThresh);

%% Amplitude threshold-based identification of artifact times
figure('Name', 'Click on 2 locations along the time axis to expand traces')
title('Detecting stimulus artifacts')
plot(timeAxis,datProd)
[x,y]=ginput(2);
close

minPt = find(timeAxis>= min(x)); minPt = minPt(1);
maxPt = find(timeAxis>=max(x)); maxPt = maxPt(1);
figure('Name', '   Select an amplitude threshold')
plot(timeAxis,datProd)
 axis([min(x) max(x) 0 30*std(datProd(minPt:maxPt))]), set(gca,'ytick',[])
ampThresh = ginput(1); ampThresh=ampThresh(2);
stimPeaks = find(abs(datProd)>=abs(ampThresh));
close

% answer= questdlg('How would you like to detect the first artifact?',...
%     'First artifact detection','Automatic','Manual','Automatic');
% switch answer
%     case 'Manual'
%         v=[];
%         plot(timeAxis,data),legend('1','2','3','4'), box off
%         [v]=zinput(1);
%         v([end-1 end])=[-inf inf];
%         axis(v);hold on;
%         plot(timeAxis,data),legend('1','2','3','4'), box off;
%         x =ginput(1);
%         xPt = find(timeAxis>=x(1)); xPt = xPt(1);
%         hold off; close
%     case 'Automatic'
%         xPt=min(transients);
% end

xPt = min(transients);
transients(transients<xPt)=[];
transients=[xPt; transients(:)];
proxLimit=ceil((200e-6)/samplingInt); % 200 usec b/c this is usually the width of the stim pulse
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
testTransients=transients-6; % Since the stim artifact is very likely to get detected
tStimArts= timeAxis(testTransients) + min(timeAxis);  % The timeShifter addition
                                                     % is necessary in case
                                                     % the starting time
                                                     % value is not zero.


% figure
% plot(timeAxis,datProd), hold on
% plot(timeAxis(testTransients),datProd(testTransients),'ro')
% hold off


