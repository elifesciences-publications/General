% OVERTHRESHREMOVE  Removes stimulus artifacts above and below chosen
% amplitude thresholds.
%
%   data_mod = overthreshremove(data,timeAxis) returns data with stimulus
%   artifacts cut off below and above user selected amplitude thresholds.
%
% Modified 08-Jun-2009
  
function signal=overthreshremove(data,timeAxis)
signal =data;
% signal=chebfilt(data,samplingInt,50,'high');
clf,plot(timeAxis,signal)
title('Select X limits')
[x,y]=ginput(2);
first=min(x);
last=max(x);
axis([first last -inf inf])
for k = 1:size(signal,2)
    again = 1;
    while again ==1
%        clf, figure('Name', ['Channel: ' num2str(k)])
        clf, plot(timeAxis,signal(:,k)), axis([first last -inf inf ])        
        title('Select amplitude thresholds ')
        [x,y]=ginput(2);
        over = find(signal(:,k)>= max(y));
        under = find(signal(:,k)<= min(y));
        signal(over,k)=max(y);
        signal(under,k)=min(y);
        answer = questdlg('Do yo wanna further reduce threshold? ',...
            'Reducing threshold','Yes','No','No');
        switch answer
            case 'No'
                again=0;
        end
    end
end
close