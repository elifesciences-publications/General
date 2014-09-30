% clear all
[filename, path, filterindex]=uigetfile('*.abf',...
    'Click on the file you want to analyze Mr. Mentis ');
f=fullfile(path,filename);
data=abfload(f);

% % ss=inputdlg(' What is the sampling frequency in KHz George? ');
% ss=cell2mat(ss);
% ss=ss*1000;
samplingInt = 100E-6;
kernelRange = 0.5E-3/samplingInt;
gaussKernel = normpdf(-kernelRange:kernelRange, 0 , 2*kernelRange/(6));
timeAxis=(0:length(data)-1)*samplingInt;

% blah=size(data);
for j=1:size(data,2);
    for jj=1:size(data,3)
    temp=['ch' num2str(j)];
    smooth.(temp)=conv(data(:,j),gaussKernel);
    ldiff=length(smooth.(temp))-length(timeAxis);
    remainder=rem(ldiff,2);
    fpt=floor(ldiff/2);
    smooth.(temp)=smooth.(temp)(fpt+remainder:end-fpt-1);
    ds.(temp) = diff(smooth.(temp));
    dds.(temp) = diff(ds.(temp));
    transients.(temp)=find(dds.(temp)>mean(dds.(temp))+3*std(dds.(temp)));
    transients.(temp)=transients.(temp)+1;
    supraThresh.(temp)=find(data(:,j)>mean(data(:,j))+3*std(data(:,j)));

    clear k
    bads1=[];
    for k=1:length(transients.(temp))
        goods= find((supraThresh.(temp)-transients.(temp)(k))>0 &...
            (supraThresh.(temp)-transients.(temp)(k))<(2E-3)/samplingInt);
        if isempty(goods)
            bads1=[bads1(:);k];
        end
    end
    iti=diff(transients.(temp));
    bads2=find(iti<(2E-3/samplingInt)); bads2=bads2+1;
    allBads=unique(sort([bads1(:);bads2(:)]));
    transients.(temp)(allBads)=[];
%     zeros=find(transients.(temp)==0);
%     transients.(temp)(zeros)=[];
    end
end



        
        
        
    

