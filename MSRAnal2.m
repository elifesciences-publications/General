% This program detects the stimulus artifact, onset of monosynaptic
% response, peak of monosynaptic response, etc.
clear all

%% Select and load the file into the matlab workspace and save it under the
%% variable name data
[filename, path, filterindex]=uigetfile('*.abf',...
    'Click on the file you want to analyze Mr. Mentis ');
f=fullfile(path,filename);
data=abfload(f);

%% Declare some variables
prompt={'Channel 1'; 'Channel 2'; 'Channel 3'; 'Channel 4'};
ss=inputdlg(prompt,'Sampling frequencies');
for h=1:length(ss), sampFreq(h)=str2num(cell2mat(ss(h))); end

samplingInt = 1./sampFreq;
kernelRange = (0.5E-3)./samplingInt;

% blah=size(data);
for j=1:size(data,2);
    temp=['ch' num2str(j)];
    gaussKernel.(temp) = normpdf(-kernelRange(j):kernelRange(j), 0 , 2*kernelRange(j)/6);
    timeAxis.(temp)=(0:length(data)-1)*samplingInt(j);

    for jj=1:size(data,3)    
    temp2=['sw' num2str(jj)];
    smooth.(temp).(temp2)=conv(data(:,j,jj),gaussKernel.(temp));
    ldiff=length(smooth.(temp).(temp2))-length(timeAxis.(temp));
    remainder=rem(ldiff,2);
    fpt=floor(ldiff/2);
    smooth.(temp).(temp2)=smooth.(temp).(temp2)(fpt+remainder:end-fpt-1);
    ds.(temp).(temp2) = diff(smooth.(temp).(temp2));
    dds.(temp).(temp2) = diff(ds.(temp).(temp2));
    transients.(temp).(temp2) = find(dds.(temp).(temp2)>...
        mean(dds.(temp).(temp2))+ std(dds.(temp).(temp2)));
    transients.(temp).(temp2)=transients.(temp).(temp2)+1;
%     supraThresh.(temp).(temp2)=find(data(:,j)>mean(data(:,j,jj))+3*std(data(:,j,jj)));
      percRange = 0.8*(max(smooth.(temp).(temp2)));
      supraThresh.(temp).(temp2)=find(data(:,j,jj)>percRange);

    clear k
    bads1=[];
    for k=1:length(transients.(temp).(temp2))
        goods= find((supraThresh.(temp).(temp2)-transients.(temp).(temp2)...
            (k))>0 & (supraThresh.(temp).(temp2)-transients.(temp).(temp2)...
            (k))<(2E-3)/samplingInt(j));
        if isempty(goods)
            bads1=[bads1(:);k];
        end
               
    end
    iti=diff(transients.(temp).(temp2));
    bads2=find(iti<(2E-3/samplingInt(j))); bads2=bads2+1;
    allBads=unique(sort([bads1(:);bads2(:)]));
    transients.(temp).(temp2)(allBads)=[];
    
    for m=1:length(transients.(temp).(temp2))
        first=transients.(temp).(temp2)(m)+(3E-3)/samplingInt(j);
        middle= transients.(temp).(temp2)(m)+(4E-3)/samplingInt(j);
        last= transients.(temp).(temp2)(m)+(40E-3)/samplingInt(j);
        preFirst = transients.(temp).(temp2)(m)-(2E-3)/samplingInt(j);
        preLast= transients.(temp).(temp2)(m)-(1E-3)/samplingInt(j);
        
        shortSegment=dds.(temp).(temp2)(first:middle);
        preShortSegment= smooth.(temp).(temp2)(preFirst:preLast);
        
        longSegment=dds.(temp).(temp2)(first:last);
        postLongSegment=smooth.(temp).(temp2)(first:last);
        shortSegment=shortSegment(:);
        preShortSegment =preShortSegment(:);
        postLongSegment= postLongSegment(:);
        longSegment=longSegment(:);
        localThresh= mean(shortSegment)+3.5*std(shortSegment);
        preLocalThresh = mean(preShortSegment) + 7*std(preShortSegment);
       
        capOnset.(temp).(temp2)= min(find((longSegment(1:end-4)+...
            longSegment(2:end-3)+longSegment(3:end-2)+ ...
            longSegment(4:end-1)+longSegment(5:end))/5>localThresh));
        capOnset.(temp).(temp2)=capOnset.(temp).(temp2)+...
            transients.(temp).(temp2)+ (3E-3)/samplingInt(j) +1;
        capOnset2.(temp).(temp2)= min(find((postLongSegment(1:end-4)+...
            postLongSegment(2:end-3)+ postLongSegment(3:end-2)+ postLongSegment...
            (4:end-1)+ postLongSegment(5:end))/5>preLocalThresh));
        capOnset2.(temp).(temp2)=capOnset2.(temp).(temp2)+...
            transients.(temp).(temp2)+ (3E-3)/samplingInt(j) +1;
    end
        
%     zeros=find(transients.(temp)==0);
%     transients.(temp)(zeros)=[];
    end
end
close
showFig = 'y';
while (strcmp(showFig,'y') || strcmp(showFig,'yes') ||...
        strcmp(showFig, 'Y') || strcmp(showFig, 'Yes'))
     showFig=inputdlg('Would you like to see any trace plotted from the data file? (y/n) '...
         ,'Figure display dialog');
     showFig = cell2mat(showFig);
     showFig =num2str(showFig);
     if (strcmp(showFig,'y') || strcmp(showFig,'yes') ||...
        strcmp(showFig, 'Y') || strcmp(showFig, 'Yes')) ==0
     break;
     end
     prompt={'Channel number?' , 'Sweep number'};
     blah=inputdlg(prompt,'Channel and sweep information');
     blah=cell2mat(blah); blah=str2num(blah);
     
     channel = blah(1);
     sweep = blah(2);
     chLabel=['ch' num2str(channel)];
     swLabel=['sw', num2str(sweep)];
     figure
     plot(timeAxis,data(:,channel,sweep));
     hold on;
     plot(timeAxis,smooth.(chLabel).(swLabel),'r')
     plot(timeAxis(transients.(chLabel).(swLabel)),...
         data(transients.(chLabel).(swLabel),channel,sweep),'k*');
     plot(timeAxis(capOnset.(chLabel).(swLabel)),...
         data(capOnset.(chLabel).(swLabel),channel,sweep),'k*');
     plot(timeAxis(capOnset2.(chLabel).(swLabel)),...
         data(capOnset2.(chLabel).(swLabel),channel,sweep),'kp');
     xlim([timeAxis(transients.(chLabel).(swLabel)-10)...
         timeAxis(capOnset2.(chLabel).(swLabel)+200)])
     shg
     hold off;
     
end

        
        
        
    

