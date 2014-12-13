%% Trial cell array from all unique stim conditions
fprintf('\n Creating trial array from all unique stimulus conditions \n')
nConditions = numel(unique(stimAmp(1,:))) * numel(unique(stimAmp(2,:)));
stim1Conditions = unique(stimAmp(1,:));
stim2Conditions = unique(stimAmp(2,:));
trialMat = cell(numel(stim1Conditions),numel(stim2Conditions));
trialMat_smooth = trialMat;
burstTrainMat = trialMat;
stimIndMat = trialMat;
onMat = cell(numel(stim1Conditions),numel(stim2Conditions),numel(ePhysChannelToAnalyze));
freqMat = onMat;
nTrialMat = zeros(numel(stim1Conditions),numel(stim2Conditions));
% stimMat= trialMat;
% shockStackIndMat = trialMat;  % Creating this in AnalyzeLSData2 instead
for one = 1:numel(stim1Conditions);
    for two = 1:numel(stim2Conditions)
        trialInds = find(stimAmp(1,:)==stim1Conditions(one) &  stimAmp(2,:) == stim2Conditions(two));
        trialMat{one,two} = trialSegmentedData(trialInds);
        trialMat_smooth{one,two} = trialSegData_smooth(trialInds);
        burstTrainMat{one,two} = trialSegBurstTrain(trialInds);
        stimIndMat{one,two} = [one, two];
        nTrialMat(one,two) = numel(trialInds);
        for cc = 1:numel(ePhysChannelToAnalyze)
            onMat{one,two,cc} = swimOnset(trialInds,cc);
            freqMat{one,two,cc} = swimFreq(trialInds,cc);
        end
        %  shockStackIndMat{one,two} = shockStackInds(trialInds);        
    end
end

statMat=[];
sa(:,1) = unique(stimAmp(cc,:))';
[freqMat_mat, sfMat,nfMat,onMat_mat,soMat,noMat] = deal(zeros(size(freqMat)));
for cc = 1:numel(ePhysChannelToAnalyze)
[freqMat_mat(:,:,cc), sfMat(:,:,cc), nfMat(:,:,cc)] = Cell2Mat_AP(freqMat(:,:,cc));
[onMat_mat(:,:,cc),soMat(:,:,cc),noMat(:,:,cc)] = Cell2Mat_AP(onMat(:,:,cc));
onMat_mat(onMat_mat(:,:,cc)==0)=inf;
onMat_mat(:,:,cc) = onMat_mat(:,:,cc) *1000; % Convert from sec to msec
soMat(:,:,cc) = soMat(:,:,cc)*1000;
blah = freqMat_mat(:,:,cc); 
fv(:,cc) = blah(:);
blah= sfMat(:,:,cc);
sfv(:,cc) = blah(:);
blah = onMat_mat(:,:,cc);
ov(:,cc) = blah(:);
blah = soMat(:,:,cc);
sov(:,cc) = blah(:);
blah = nfMat(:,:,cc);
nfv(:,cc) = blah(:);
statMat = [statMat, sa(:,cc), fv(:,cc),sfv(:,cc), ov(:,cc), sov(:,cc), nfv(:,cc)];
end
statMat = [statMat, nTrialMat(:)];

% if any(size(freqMat_mat,cc)==1) % If row or col vec
%     f = find(size(freqMat_mat,cc)~=1);
%     blah = unique(stimAmp(f,:));
%     statMat = [blah(:),freqMat_mat(:), sfMat(:), onMat_mat(:), soMat(:), nfMat(:), nTrialMat(:)];
% end