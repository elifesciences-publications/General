nConditions = numel(unique(stimAmp(1,:))) * numel(unique(stimAmp(2,:)));
stim1Conditions = unique(stimAmp(1,:));
stim2Conditions = unique(stimAmp(2,:));
trialMat = cell(numel(stim1Conditions),numel(stim2Conditions));
for one = 1:numel(stim1Conditions);
       for two = 1:numel(stim2Conditions)
       trialInds = find(stimAmp(1,:)==stim1Conditions(one) &  stimAmp(2,:) == stimConditions(two));
       trialMat{one,two} = trialSegmentedData(trialInds); 
       end
end