%% Segmenting Data by Trials
%### Still not generalized to multiple stim channels
disp('Segmenting data by trials...')
stim = data.stim;
dt = 1/data.samplingRate;
data.raw = [];
for ch = 1:numel(data.ePhysChannelToAnalyze)
    data.raw(ch,:) = data.(['ch' num2str(data.ePhysChannelToAnalyze(ch))]);
end
stimInds = unique(stim.inds);
[blah,incompleteSegInds] = SegmentDataByEvents(data.raw,dt,stimInds,data.preStimPeriod,data.postStimPeriod);
if isempty(incompleteSegInds)
    incompleteSegInds = nan;
end
trialSegData = struct('raw',blah);
% stim.inds(incompleteSegInds)  = []; % Ignoring incomplete segments
% stim.times(incompleteSegInds)  = [];
% stim.amp(:,incompleteSegInds) = [];

blah = SegmentDataByEvents(data.artless,dt,stimInds,data.preStimPeriod,data.postStimPeriod);
[trialSegData(:).artless] = deal(blah{:});

smooth.sine = SegmentDataByEvents(data.smooth.burst,dt,stimInds,data.preStimPeriod,data.postStimPeriod);
smooth.swim = SegmentDataByEvents(data.smooth.swim,dt,stimInds,data.preStimPeriod,data.postStimPeriod);
swimRate_ts = SegmentDataByEvents(data.swim.rate,dt, stimInds, data.preStimPeriod, data.postStimPeriod);
blah = SegmentDataByEvents(data.swim.bool,dt, stimInds, data.preStimPeriod, data.postStimPeriod);
blah2 = SegmentDataByEvents(data.swim.boolOn,dt,stimInds,data.preStimPeriod,data.postStimPeriod);
for trial = 1:numel(stimInds)
    trialSegData(trial).smooth.burst = smooth.sine{trial};
    trialSegData(trial).smooth.swim = smooth.swim{trial};
    trialSegData(trial).swim.rate = swimRate_ts{trial};
    trialSegData(trial).stim.ind = stimInds(trial);
    trialSegData(trial).stim.grp = find(unique(stim.amps(stim.activeCh,:))==stim.amps(stim.activeCh,trial));
    trialSegData(trial).stim.time = stim.times(trial);
    trialSegData(trial).stim.amps = stim.amps(stim.activeCh(1),trial);
    trialSegData(trial).swim.bool = blah{trial};
    trialSegData(trial).swim.boolOn = blah2{trial};
    if (trial <= max(incompleteSegInds)) && (trial == incompleteSegInds(trial))
        preStimPts_this = find(data.t==stim.times(trial))-1;
        trialSegData(trial).time = ((0:length(trialSegData(trial).raw)-1) - preStimPts_this)*dt;
    end
end
preStimPts  = round(data.preStimPeriod*data.samplingRate);
completeSegInds = setdiff((1:numel(stimInds)),incompleteSegInds);
trialSegData(completeSegInds(1)).time = ((0:length(trialSegData(completeSegInds(1)).raw)-1) - preStimPts)*dt;
data.incompleteSegInds = incompleteSegInds;
disp('Segmented data into trials!')