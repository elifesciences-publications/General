
function dataStruct_mod = slowartifactremove(dataStruct,samplingInt)
fNames  = fieldnames(dataStruct);
fNames_char = char(fNames);


%% Filtering/Convolving Parameters
lpf = 0.2;
kl = 5; % kernel length in seconds

%% Structure to Array Conversion
dataCell = struct2cell(dataStruct);
dataArray = {};
dataArray(1,1,:) = dataCell(:,1,1);
dataArray = cell2mat(dataArray); % z dim is trial #


%% METHOD 1 - Averaging the Raw Signals,Filtering, Subtracting

dd = zeros(size(dataArray));
for jj = 1:size(dataArray,3);
    dd(:,:,jj) = detrend(dataArray(:,:,jj),'constant'); % z dim is trial #
end
dd_avg = mean(dd,3);
dd_low = chebfilt(dd_avg,samplingInt,lpf,'low');
dd_low = repmat(dd_low,[1,1,size(dataArray,3)]);
dataArray_mod = dataArray - dd_low;

%% Array to Structure Conversion
dataStruct_mod = dataStruct;
for kk = 1:size(fNames_char,1)
dataStruct_mod.(fNames{kk,:}) = dataArray_mod(:,:,kk);
end

%% METHOD 2 - Scaling, Subtracting




