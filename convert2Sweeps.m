
%% Get the file and open it in matlab
cd C:\Axon\Data
[filename,path,filterindex]=uigetfile('*.abf', 'Which file u wanna analyze homey? ');
f=fullfile(path,filename);
cd C:\Matlab\R2006b\work
[data,samplingInt]=abfload(f);

%% Discard first column if it is time vector
tOrNot=diff(data(:,1));
if (tOrNot(1)==tOrNot(2) && tOrNot(2)==tOrNot(3)) ;
    data(:,1)=[];
end

%% Define some variables
samplingInt=samplingInt*1E-6;
timeAxis=(0:length(data)-1)*samplingInt;
data=sum(data,2);
dt=diff(data);
ddt=diff(dt);
clear data_mod;
data_mod=cell(1,size(data,2));

kernelRange = 1;
gaussKernel=normpdf(-0.5*kernelRange/samplingInt:0.5*kernelRange/...
                          samplingInt,0, kernelRange/(6*samplingInt));
data_avg=sum(data,2);

%% Go through the data column-by-column 
for i=1:size(data,2)
clear transientPts missingPts fillPts
transientPts=find(abs(ddt(:,i))>(mean(ddt(:,i))+4*std(ddt(:,i))));
transientPts=transientPts+2;
d=diff(transientPts);
transientPts(find(d>1)+1)=[];
transientPts(transientPts<5)=[];
end
