
function [signals1,signals2,time] = custprocess1(data,timeAxis)
samplingInt = mean(abs(diff(timeAxis)));

%% Truncating data so as to keep only the portion of the signals containing
%  stimulus train and a little beyond on either side.
clf, plot(timeAxis,data), shg
prompt={'Enter the starting time point','Enter the ending time point'};
name='Truncating data';
numlines=1;
defaultanswer={'0','50'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
fTime=str2double(answer{1});
lTime=str2double(answer{2});
fpt=min(find(timeAxis>=fTime));
lpt=min(find(timeAxis>=lTime));
signals1 = data(fpt:lpt,:);
time = timeAxis(fpt:lpt);

%% Filtering the data
    prompt={'Highpass value','Lowpass value'};
    name=['Filtering: Sf = ' num2str(samplingInt)];
    numlines=1;
    defaultanswer={'0','0'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    low=str2double(answer{1});
    high=str2double(answer{2});
    if all([low high]==0)
        return;
    elseif low==0
        signals1=chebfilt(signals1,samplingInt,high,'low');
    elseif high==0
        signals1=chebfilt(signals1,samplingInt,low,'high');
    else
        signals1=chebfilt(signals1,samplingInt,[low high]);
    end
    clf, plot(time, signals1)

%% Reducing the stimulus artifacts
for k = 1:size(signals1,2)
    again= 1;
    while again ==1
        clf, figure('Name',['Channel ' num2str(k)]),
        plot(time,signals1(:,k)), axis([-inf inf -inf inf])
        [x,y]=ginput(2);
        neg = find(signals1(:,k)<=min(y));
        pos = find(signals1(:,k)>=max(y));
        signals1(neg,k)=min(y);
        signals1(pos,k)=max(y);
        clf, plot(time,signals1(:,k));
        answer= questdlg('Do you wanna further reduce the stimulus artifacts ?',...
            'Yes','No');
        switch answer
            case 'No'
            again =0;
        end
    end
end


%% First smoothing of data by convolution
   prompt={'Enter the kernel range in milliseconds '};
    dlgTitle= 'First convolution ';
    lineNum=1;
    def={'0'};
    kr= inputdlg(prompt, dlgTitle, lineNum, def);
    kr=cell2mat(kr); kr= str2double(kr);
    kr=kr*1E-3;  % Converting the kernel range into seconds from ms.
    kw=kr/2;
    kr_pts= round(kr/samplingInt);
    kw_pts=round(kw/samplingInt);

    strList={'Boxcar','Gaussian','Hamming','Exponential'};
    selection = listdlg('PromptString', 'Choosing smoothDataing Kernel',...
        'SelectionMode','single','ListString',strList);
    switch selection
        case 2
            gKernel=normpdf(-kw_pts:kw_pts, 0, kr_pts/6);
            for k=1:size(signals1,2)
                smoothData(:,k)=conv(signals1(:,k),gKernel);
            end
            d=length(smoothData)-length(signals1);
            if rem(d,2)==0
                dd=d/2;
                smoothData([1:dd end-(dd-1):end],:)=[];
            else dd =floor(d/2);
                smoothData([1:dd end-dd:end],:)=[];
            end

        case 3
            hKernel=hamming(kr_pts);
            for k=1:size(data,2)
                smoothData(:,k)=conv(signals1(:,k),hKernel);
            end
            d=length(smoothData)-length(signals1);
            if rem(d,2)==0
                dd=d/2;
                smoothData([1:dd end-(dd-1):end],:)=[];
            else dd =floor(d/2);
                smoothData([1:dd end-dd:end],:)=[];
            end
        case 1
            rKernel=ones(kr_pts,1)/kr_pts;
            for k=1:size(signals1,2)
                smoothData(:,k)=conv(signals1(:,k),rKernel);
            end
            d=length(smoothData)-length(signals1);
            if rem(d,2)==0
                dd=d/2;
                smoothData([1:dd end-(dd-1):end],:)=[];
            else dd =floor(d/2);
                smoothData([1:dd end-dd:end],:)=[];
            end

        case 4
            eKernel=exppdf(0:kr_pts, kr_pts/6);
            for k=1:size(signals1,2)
                smoothData(:,k)=conv(signals1(:,k),eKernel);
            end
            d=length(smoothData)-length(signals1);
            smoothData(end-(d-1):end,:)=[];
    end
    mMat=max(smoothData);
    mMat = repmat(mMat,size(smoothData,1),1);
    smoothData=smoothData./mMat;
    signals1 = smoothData;
    clear smoothData;

%% Reducing data
    newSF = 100;
    newSamplingInt = 1/newSF;
    signals1 = reduceData(signals1,samplingInt, newSF);
    time = reduceData(time,samplingInt,newSF);

%% Second smoothing of data by convolution
    signals2=abs(signals1);
    prompt={'Enter the kernel range in milliseconds '};
    dlgTitle= 'Second convolution ';
    lineNum=1;
    def={'0'};
    kr= inputdlg(prompt, dlgTitle, lineNum, def);
    kr=cell2mat(kr); kr= str2double(kr);
    kr=kr*1E-3;  % Converting the kernel range into seconds from ms.
    kw=kr/2;
    kr_pts= round(kr/newSamplingInt);
    kw_pts=round(kw/newSamplingInt);

    strList={'Boxcar','Gaussian','Hamming','Exponential'};
    selection = listdlg('PromptString', 'Choosing smoothDataing Kernel',...
        'SelectionMode','single','ListString',strList);
    switch selection
        case 2
            gKernel=normpdf(-kw_pts:kw_pts, 0, kr_pts/6);
            for k=1:size(signals2,2)
                smoothData(:,k)=conv(signals2(:,k),gKernel);
            end
            d=length(smoothData)-length(signals2);
            if rem(d,2)==0
                dd=d/2;
                smoothData([1:dd end-(dd-1):end],:)=[];
            else dd =floor(d/2);
                smoothData([1:dd end-dd:end],:)=[];
            end

        case 3
            hKernel=hamming(kr_pts);
            for k=1:size(data,2)
                smoothData(:,k)=conv(signals2(:,k),hKernel);
            end
            d=length(smoothData)-length(signals2);
            if rem(d,2)==0
                dd=d/2;
                smoothData([1:dd end-(dd-1):end],:)=[];
            else dd =floor(d/2);
                smoothData([1:dd end-dd:end],:)=[];
            end
        case 1
            rKernel=ones(kr_pts,1)/kr_pts;
            for k=1:size(signals2,2)
                smoothData(:,k)=conv(signals2(:,k),rKernel);
            end
            d=length(smoothData)-length(signals2);
            if rem(d,2)==0
                dd=d/2;
                smoothData([1:dd end-(dd-1):end],:)=[];
            else dd =floor(d/2);
                smoothData([1:dd end-dd:end],:)=[];
            end

        case 4
            eKernel=exppdf(0:kr_pts, kr_pts/6);
            for k=1:size(signals2,2)
                smoothData(:,k)=conv(signals2(:,k),eKernel);
            end
            d=length(smoothData)-length(signals2);
            smoothData(end-(d-1):end,:)=[];
    end
    mMat = max(smoothData);
    mMat = repmat(mMat,size(smoothData,1),1);
    smoothData= smoothData./mMat;
    signals2 = smoothData;
    clear smoothData
close all
