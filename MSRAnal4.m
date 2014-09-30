% This program detects the stimulus artifact, onset of monosynaptic
% response, peak of monosynaptic response, etc.
clear all

%% Select and load the file into the matlab workspace and save it in the
%% variable name 'data'
[filename, path, filterindex]=uigetfile('*.abf',...
    'Click on the file you want to analyze Dr. Mentis ');
f=fullfile(path,filename);
[data, si] = abfload(f); % si = sampling interval in microseconds.

%% This part was used to obtain sampling frequencies for each channel from
%% the user, but now the program does it automatically using abfload

% prompt={'Channel 1'; 'Channel 2'; 'Channel 3'; 'Channel 4'};
% ss=inputdlg(prompt,'Enter sampling frequencies ');
% sampFreq=zeros(1,length(ss));
% for h=1:length(ss); sampFreq(h)=str2num(cell2mat(ss(h)));end

%% Some variables

if length(si)<size(data,2),si =repmat(si,1,size(data,2)); end % If sampling
% interval is same for all channels, si will be a scalar. This line
% converts it to a vector

samplingInt=si.*1E-6; % sampling interval in seconds.
% samplingInt = 1./sampFreq;
kernelRange = (1E-3)./samplingInt; % For the gaussian smoothing kernel
tLine1=zeros(size(data,2),size(data,3));
tLine2=zeros(size(data,2),size(data,3));
bLine=zeros(size(data,2),size(data,3));

sweep_averaged_data=sum(data,3)/size(data,3);
data=cat(3,sweep_averaged_data,data);

%% Actual processing part of the program

for j=1:size(data,2);
    temp=['ch' num2str(j)];
    gaussKernel.(temp) = normpdf(-kernelRange(j):kernelRange(j), 0 , 2*kernelRange(j)/6);
    timeAxis.(temp)=(0:length(data)-1)*samplingInt(j);
    
    for jj=1:size(data,3)
        temp2=['sw' num2str(jj)];
        if jj==1, averaged_sweep_temp2=temp2; end
        
        smooth.(temp).(temp2)=conv(data(:,j,jj),gaussKernel.(temp));
        ldiff=length(smooth.(temp).(temp2))-length(timeAxis.(temp));
        remainder=rem(ldiff,2);
        fpt=floor(ldiff/2);
        smooth.(temp).(temp2)=smooth.(temp).(temp2)(fpt+remainder:end-fpt-1);
        
        ds.(temp).(temp2) = diff(smooth.(temp).(temp2));
        dds.(temp).(temp2) = diff(smooth.(temp).(temp2),2);
        d3s.(temp).(temp2)=diff(smooth.(temp).(temp2),3);
        dds2.(temp).(temp2)=diff(data(:,j,jj),2);
        
        slopeThresh=mean(dds2.(temp).(temp2))+3*std(dds2.(temp).(temp2));
        transients.(temp).(temp2) = find(abs(dds2.(temp).(temp2))>slopeThresh);
        transients.(temp).(temp2)=transients.(temp).(temp2)+1;
        
        percRange = mean(smooth.(temp).(temp2))+3*std(smooth.(temp).(temp2));
        supraThresh.(temp).(temp2)=find(abs(data(:,j,jj))>percRange);
        
        
        bads1=find(transients.(temp).(temp2)<=(5E-3)/samplingInt(j));
        transients.(temp).(temp2)(bads1)=[];
        
        dTrans=diff(transients.(temp).(temp2));
        goods1=find(dTrans<=3);
        goods2=find(dTrans(2:end)<=3 & dTrans(1:end-1)>(100E-3)/samplingInt(j));
        %       goods2 = goods2+1;
        %       goods12 = [goods1(1); goods2(:)];
        %       transients.(temp).(temp2) = transients.(temp).(temp2)(goods12);
        transients.(temp).(temp2)=transients.(temp).(temp2)(goods1(1));
        
        if abs(transients.(temp).(temp2)-transients.(temp).(averaged_sweep_temp2))>=4
             transients.(temp).(temp2)=transients.(temp).(averaged_sweep_temp2);
         end
        
        for m=1:length(transients.(temp).(temp2))
            
            first=transients.(temp).(temp2)(m)+ round((3E-3)/samplingInt(j));
            middle= transients.(temp).(temp2)(m)+ round((6E-3)/samplingInt(j));
            last= transients.(temp).(temp2)(m)+ round((40E-3)/samplingInt(j));
            
            preFirst = transients.(temp).(temp2)(m)-round((5E-3)/samplingInt(j));
            preLast= transients.(temp).(temp2)(m)-round((1E-3)/samplingInt(j));
            
            
            shortSegment=dds.(temp).(temp2)(preFirst:preLast);
            longSegment=dds.(temp).(temp2)(first:last);    
            
            %           shortSegment=dds2.(temp).(temp2)(preFirst:preLast);
            %           longSegment=dds2.(temp).(temp2)(first:last); 
            
            preShortSegment= smooth.(temp).(temp2)(preFirst:preLast);
            preShortSegment2 = smooth.(temp).(temp2)(first:middle);
            postLongSegment=smooth.(temp).(temp2)(middle:last);
            
            shortSegment=shortSegment(:);
            longSegment=longSegment(:);
            preShortSegment =preShortSegment(:);
            postLongSegment= postLongSegment(:);
            
            localThresh= mean(shortSegment)+ 2*std(shortSegment);
            preLocalThresh = mean(preShortSegment2) + 3.2*std(preShortSegment2);
            
            bLine(j,jj)=mean(preShortSegment2);
            tLine1(j,jj)=preLocalThresh;
            tLine2(j,jj)=mean(preShortSegment2)-3.2*std(preShortSegment2);
            
            
            
            capOnset.(temp).(temp2)= min(find((longSegment(1:end-4)+...
                longSegment(2:end-3)+longSegment(3:end-2)+ ...
                longSegment(4:end-1)+longSegment(5:end))/5>localThresh));
            
            capOnset.(temp).(temp2)=capOnset.(temp).(temp2)+first +1;
            
            %         capOnset2.(temp).(temp2)= min(find(postLongSegment(1:end-14)>...
            %             preLocalThresh & (postLongSegment(1:end-14)+...
            %             postLongSegment(2:end-13)+ postLongSegment(3:end-12)+
            %             postLongSegment... (4:end-11)+ postLongSegment(5:end-10)+
            %             postLongSegment(6:end-9) +... postLongSegment(7:end-8)+
            %             postLongSegment(8:end-7)+... postLongSegment(9:end-6)+
            %             postLongSegment(10:end-5)+... postLongSegment(11:end-4) +
            %             postLongSegment(12:end-3)+ ... postLongSegment(13:end-2)+
            %             postLongSegment(14:end-1)+... postLongSegment(15:end))/15>
            %             postLongSegment(1:end-14)));
            %         
            %         dl=diff(postLongSegment); dl=[0; dl(:)];
            %         capOnset2.(temp).(temp2)=min(find(dl(1:end-9)>0 & dl(2:end-8)>0
            %         &...
            %             dl(3:end-7)& dl(4:end-6) & dl(5:end-5)>0 & dl(6:end-4)>0 &
            %             ... dl(7:end-3)>0 & dl(8:end-2)>0 & dl(9:end-1)>0 &...
            %              dl(10:end)>0 & postLongSegment(1:end-9)>preLocalThresh));
            %         capOnset2.(temp).(temp2)=min(find(postLongSegment(1:end-14)>=preL
            %         ocalThresh &...
            %             postLongSegment(2:end-13)>preLocalThresh &
            %             postLongSegment(3:end-12)>preLocalThresh &...
            %             postLongSegment(4:end-11)>preLocalThresh &
            %             postLongSegment(5:end-10)>preLocalThresh &...
            %             postLongSegment(6:end-9)>preLocalThresh &
            %             postLongSegment(7:end-8)>preLocalThresh... &
            %             postLongSegment(8:end-7)>preLocalThresh &
            %             postLongSegment(9:end-6)>preLocalThresh... &
            %             postLongSegment(10:end-5)>preLocalThresh &
            %             postLongSegment(11:end-4)>preLocalThresh... &
            %             postLongSegment(12:end-3)>preLocalThresh &
            %             postLongSegment(13:end-2)>... preLocalThresh &
            %             postLongSegment(14:end-1)>preLocalThresh &
            %             postLongSegment(15:end)>... preLocalThresh));
            
            capOnset2.(temp).(temp2)=min(find(postLongSegment(1:end-2)>=preLocalThresh &...
                postLongSegment(2:end-1)>preLocalThresh & postLongSegment(3:end)>preLocalThresh));
            capOnset2.(temp).(temp2)=capOnset2.(temp).(temp2)+ middle -round(0.3*length(gaussKernel.(temp)));
            y_lim(j,jj) = max(postLongSegment);
            
%             gapPt_for_slope=round((0.5E-3)/samplingInt(j));
%             tempVec= [postLongSegment(gapPt_for_slope+1:end)-postLongSegment(1:end-gapPt_for_slope)];
%             capOnset3.(temp).(temp2)=find(tempVec==max(tempVec));
%             capOnset3.(temp).(temp2)=capOnset3.(temp).(temp2)+middle;
            
            
        end
    end
end
%% Graph display dialog
close
% showFig = 'y';
% while (strcmp(showFig,'y') || strcmp(showFig,'yes') ||...
%         strcmp(showFig, 'Y') || strcmp(showFig, 'Yes'))
%      showFig=inputdlg('Would you like to see any trace plotted from the data file? (y/n) '...
%          ,'Figure display dialog');
%      showFig = cell2mat(showFig);
%      showFig =num2str(showFig);
%      if (strcmp(showFig,'y') || strcmp(showFig,'yes') ||...
%         strcmp(showFig, 'Y') || strcmp(showFig, 'Yes')) ==0
%      break;
%      end
%      prompt={'Channel number?' , 'Sweep number'};
%      blah=inputdlg(prompt,'Channel and sweep information');
%      blah=cell2mat(blah); blah=str2num(blah);
     
   for n=1:size(data,2)
     channel = n;
     chLabel=['ch' num2str(channel)];     
    
     for nn=1:size(data,3)
      sweep = nn;
      swLabel=['sw', num2str(sweep)];
     
     figure(n*10+nn)
     plot(timeAxis.(chLabel),data(:,channel,sweep));
     hold on;
     title([chLabel '   ' swLabel])
     plot(timeAxis.(chLabel),smooth.(chLabel).(swLabel),'r')
     plot(timeAxis.(chLabel)(transients.(chLabel).(swLabel)),...
         data(transients.(chLabel).(swLabel),channel,sweep),'k*');
     plot(timeAxis.(chLabel)(capOnset2.(chLabel).(swLabel)),...
         data(capOnset2.(chLabel).(swLabel),channel,sweep),'ko',...
         timeAxis.(chLabel)(capOnset2.(chLabel).(swLabel)),...
         data(capOnset2.(chLabel).(swLabel),channel,sweep),'kp--');
%      plot(timeAxis.(chLabel)(capOnset.(chLabel).(swLabel)),...
%          data(capOnset.(chLabel).(swLabel),channel,sweep),'k^');
%      plot(timeAxis.(chLabel)(capOnset3.(chLabel).(swLabel)),...
%          data(capOnset3.(chLabel).(swLabel),channel,sweep),'gd');
     plot(timeAxis.(chLabel),bLine(n,nn)*ones(1,length(timeAxis.(chLabel))),'k--');
     plot(timeAxis.(chLabel),tLine1(n,nn)*ones(1,length(timeAxis.(chLabel))),'r:');
     plot(timeAxis.(chLabel),tLine2(n,nn)*ones(1,length(timeAxis.(chLabel))),'r:');
     
     t1 = timeAxis.(chLabel)(transients.(chLabel).(swLabel)(1)...
             -round((5E-3)/samplingInt(n)));
     t2 = t1+ (50E-3);
     xlim([t1 t2])
     
     y_low= bLine(n,nn)-20*abs(bLine(n,nn)-tLine1(n,nn));
     y_high =bLine(n,nn)+40*abs(bLine(n,nn)-tLine1(n,nn));
  
%      ylim([y_low y_high])
       ylim([y_low max([y_lim(n,nn) y_high])])
     shg
     [x,y,button]=ginput(1);
     if button ==1, capOnset2.(chLabel).(swLabel)= round(x/samplingInt(n));end
     hold off;
     close
     end
   end

  latencies = zeros(size(data,2),size(data,3));
  for j =1:size(data,2),ch=['ch' num2str(j)];
      for jj=1:size(data,3),sw=['sw' num2str(jj)]; 
          if isempty(transients.(ch).(sw)), transients.(ch).(sw)=0; 
          elseif isempty(capOnset2.(ch).(sw)), capOnset2.(ch).(sw)=0;
          end
          latencies(j,jj)=(capOnset2.(ch).(sw)-transients.(ch).(sw))*samplingInt(j)*1000; 
      end 
  end 
        
        
    

