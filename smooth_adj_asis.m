% Function smooth_adj_asis
% Smooth inputted data without filtering and/or rectification
% Syntax smoothData = smooth_adj_asis(data,samplingInt);
function smooth=smooth_adj_asis(data,samplingInt);

timeAxis=(0:length(data)-1)*samplingInt;

prompt={'Enter the kernel range in milliseconds '};
dlgTitle= 'Deciding the kernel range ';
lineNum=1;
def={'250'};
kr= inputdlg(prompt, dlgTitle, lineNum, def);
kr=cell2mat(kr); kr= str2double(kr);
kr=kr*1E-3;  % Since the input for kernel range is in milliseconds.
kw=kr/2;
kr_pts= round(kr/samplingInt);
kw_pts=round(kw/samplingInt);
display(kr_pts), display (kw_pts)

buttonName=questdlg('What type of kernel would you like? ', 'Choosing Smoothing Kernel',...
    'Gaussian', 'Hamming', 'Exponential','Hamming');
switch buttonName
    case 'Gaussian'
        gKernel=normpdf(-kw_pts:kw_pts, 0, kr_pts/6);
        for k=1:size(data,2)
            smooth(:,k)=conv(data(:,k),gKernel);
        end
        d=length(smooth)-length(data);
        if rem(d,2)==0
            dd=d/2;
            smooth([1:dd end-(dd-1):end],:)=[];
        else dd =floor(d/2);
            smooth([1:dd end-dd:end],:)=[];
        end

    case 'Hamming'
        hKernel=hamming(kr_pts);
        for k=1:size(data,2)
            smooth(:,k)=conv(data(:,k),hKernel);
        end
        d=length(smooth)-length(data);
        if rem(d,2)==0
            dd=d/2;
            smooth([1:dd end-(dd-1):end],:)=[];
        else dd =floor(d/2);
            smooth([1:dd end-dd:end],:)=[];
        end
    case 'Exponential'
        eKernel=exppdf(0:kr_pts, kr_pts/6);
        for k=1:size(data,2)
            smooth(:,k)=conv(data(:,k),eKernel);
        end
        d=length(smooth)-length(data);
        smooth(end-(d-1):end,:)=[];
end


maxValues=max(smooth);
maxMat=repmat(maxValues,size(smooth,1),1);
smooth=smooth./maxMat;


