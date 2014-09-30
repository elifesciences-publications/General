% smooth_adj  Smooths data by convolving data with a chosen kernel function of a chosen width. High pass filters
% the data at 50Hz and rectifies before convolving with kernel.
%  [smooth, timeAxis_mod]=smooth_adj(data,timeAxis)

function [smoothData, timeAxis_mod]=smooth_adj(data,timeAxis)
samplingInt=timeAxis(2)-timeAxis(1);
data=chebfilt(data,samplingInt,50,'high');
data(data<0)=0;
fpt=min(find(timeAxis>=-1));
lpt=min(find(timeAxis>=15));
data=data(fpt:lpt,:);
timeAxis_mod=timeAxis(fpt:lpt);

%% Deciding the parameters for the convolution
prompt={'Enter the kernel range in milliseconds '};
dlgTitle= 'Deciding the kernel range ';
lineNum=1;
def={'0'};
kr= inputdlg(prompt, dlgTitle, lineNum, def);
kr=cell2mat(kr); kr= str2double(kr);
if kr==0,
    smoothData=[];
else
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
            for k=1:size(data,2)
                smoothData(:,k)=conv(data(:,k),gKernel);
            end
            d=length(smoothData)-length(data);
            if rem(d,2)==0
                dd=d/2;
                smoothData([1:dd end-(dd-1):end],:)=[];
            else dd =floor(d/2);
                smoothData([1:dd end-dd:end],:)=[];
            end

        case 3
            hKernel=hamming(kr_pts);
            for k=1:size(data,2)
                smoothData(:,k)=conv(data(:,k),hKernel);
            end
            d=length(smoothData)-length(data);
            if rem(d,2)==0
                dd=d/2;
                smoothData([1:dd end-(dd-1):end],:)=[];
            else dd =floor(d/2);
                smoothData([1:dd end-dd:end],:)=[];
            end
        case 1
            rKernel=ones(kr_pts,1)/kr_pts;
            for k=1:size(data,2)
                smoothData(:,k)=conv(data(:,k),rKernel);
            end
            d=length(smoothData)-length(data);
            if rem(d,2)==0
                dd=d/2;
                smoothData([1:dd end-(dd-1):end],:)=[];
            else dd =floor(d/2);
                smoothData([1:dd end-dd:end],:)=[];
            end

        case 4
            eKernel=exppdf(0:kr_pts, kr_pts/6);
            for k=1:size(data,2)
                smoothData(:,k)=conv(data(:,k),eKernel);
            end
            d=length(smoothData)-length(data);
            smoothData(end-(d-1):end,:)=[];
    end
    sigmaData=std(data);
    sigmaSmooth=std(smoothData);
    maxMat_s=repmat(sigmaSmooth,size(smoothData,1),1);
    maxMat_d=repmat(sigmaData,size(data,1),1);
    smoothData=smoothData.*(maxMat_d./maxMat_s);  % Normalizing wrt to std
end


