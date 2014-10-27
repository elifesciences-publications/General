
function [varargout] = psrcompare(data,timeAxis)
% PSRCOMPARE  Alignment of signals wrt first stimulus artifact.
%   [data_mod, timeAxis_mod]= psrcompare(data,timeAxis) returns a modified 
%   data matrix and time axis vector such that data amplitude and time  
%   at onset of first stimulus have value zero. This allows for time
%   course/amplitude comparison or even averaging of stimulus-induced
%   responses from multiple files, which have been so shifted along the 
%   amplitude and time dimensions.
%
%   [data_mod, timeAxis_mod,stimTimes]= psrcompare(data,timeAxis) also
%   returns stimTimes, a vector of time values for all the stimuli in a
%   stimulus train.
%    
%   Author: AP
%   Last Modified: 07-Feb-2013
%% Variables


%%  Detecting stimulus artifacts
str = {'Automatic: Slope + Thresh','Automatic: Slope','Manual', 'None'};
[selection,ok] = listdlg('PromptString','Type of artifact detection? '...
    ,'SelectionMode','single','ListString', str);
switch selection
    case 3
        v=[];
        plot(timeAxis,data),legend('1','2','3','4'), box off
        [v]=zinput(1);
        axis(v);hold on;
        plot(timeAxis,data),legend('1','2','3','4'), box off;
        [x] =ginput(1);
        xPt=min(find(timeAxis>=x(1)));
                hold off;
        close
    case 2
        si = timeAxis(2)-timeAxis(1);
        dataProd=chebfilt(data,si,50,'high');
        dataProd= prod(dataProd,2);        
        d2data=diff(dataProd,2);
        slopeThresh=abs(3*std(d2data));
        transients=find(abs(d2data)>=slopeThresh);
        if isempty(transients)
            errordlg('Unable to detect artifact, try manual detection',...
                'Detection error')
        end
            
        xPt=min(transients);
        x=timeAxis(xPt);
        varargout{3} = timeAxis(transients);
    case 1
        tStimArts=stimartdetect(data,timeAxis);
        if nargout == 3
        varargout{3} = tStimArts;
        end
        x=tStimArts(1);
        xPt=min(find(timeAxis>=x));
    case 4
        x = 0;
        xPt = 1;
end

%% Some additional stuff
varargout{2}=timeAxis-x(1);
temp=data(xPt,:);
temp=temp(:)';
tempMat=repmat(temp,size(data,1),1);

varargout{1}= (data-tempMat);

