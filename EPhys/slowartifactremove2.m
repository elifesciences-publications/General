
function sigMat_mod = slowartifactremove(sigMat,samplingInt)
%%%     size(sigMat) = (n,t,c);
%%%     n = # of data points


%% Filtering/Convolving Parameters
lpf = 0.3;
% kl = 5; % kernel length in seconds

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
for kk = 1:size(fNames,1)
dataStruct_mod.(fNames) = dataArray_mod(:,:,kk);
end

%% METHOD 2 - Scaling, Subtracting




