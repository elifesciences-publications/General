% smoothdata 
% Smooths data by convolving with a chosen kernel function of a
% chosen width. Outputs the central portion of the smoothed data with
% length equal to that of data.
% sData = smoothData(data,timeAxis);    
function sData = smoothData(data,timeAxis)
samplingInt=timeAxis(2)-timeAxis(1);
prompt={'Enter the kernel range in milliseconds '};
dlgTitle= 'Deciding the kernel range ';
lineNum=1;
def={'250'};
kr= inputdlg(prompt, dlgTitle, lineNum, def);
kr=cell2mat(kr); kr= str2double(kr);
if kr==0,
    sData=[];
else
    kr=kr*1E-3;  % Since the input for kernel range is in milliseconds.
    kw=kr/2;
    kr_pts= round(kr/samplingInt);
    kw_pts=round(kw/samplingInt);
    % display(kr_pts), display (kw_pts)
    strList={'Boxcar','Gaussian','Hamming','Exponential'};
    [selection, ok]=listdlg('PromptString', 'Choosing Smoothing Kernel',...
        'SelectionMode','single','ListString',strList);
    
    switch selection
        case 1
            rKernel=ones(kr_pts,1)/kr_pts;
            for k=1:size(data,2)
                sData(:,k)=conv(data(:,k),rKernel);
            end
            d=length(sData)-length(data);
            if rem(d,2)==0
                dd=d/2;
                sData([1:dd end-(dd-1):end],:)=[];
            else dd =floor(d/2);
                sData([1:dd end-dd:end],:)=[];
            end
            
        case 2
            gKernel=normpdf(-kw_pts:kw_pts, 0, kr_pts/6);
            for k=1:size(data,2)
                sData(:,k)=conv(data(:,k),gKernel);
            end
            d=length(sData)-length(data);
            if rem(d,2)==0
                dd=d/2;
                sData([1:dd end-(dd-1):end],:)=[];
            else dd =floor(d/2);
                sData([1:dd end-dd:end],:)=[];
            end
            
        case 3
            hKernel=hamming(kr_pts);
            for k=1:size(data,2)
                sData(:,k)=conv(data(:,k),hKernel);
            end
            d=length(sData)-length(data);
            if rem(d,2)==0
                dd=d/2;
                sData([1:dd end-(dd-1):end],:)=[];
            else dd =floor(d/2);
                sData([1:dd end-dd:end],:)=[];
            end
            
        case 4
            eKernel=exppdf(0:kr_pts, kr_pts/6);
            for k=1:size(data,2)
                sData(:,k)=conv(data(:,k),eKernel);
            end
            d=length(sData)-length(data);
            sData(end-(d-1):end,:)=[];
    end
end