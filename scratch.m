[stim.inds, stim.times, stim.amps] = deal(cell(sum(data.stimIsolGain~=0),1));
for stimChan = 1:nStimChan
    if data.stimIsolGain(stimChan)
        disp(['Getting stimulus info from channel ' num2str(stimChan) '...'] )
        stim.inds{stimChan} = FindStimPulses(data.(['stim' num2str(stimChan)]),20,30,0.8*minExpectedStimInt);
        disp(['Found ' num2str(numel(stim.inds{stimChan})) ' stimuli'])
        temp = data.(['stim' num2str(stimChan)]);
        stim.amps{stimChan} = temp(stim.inds{stimChan});
        stim.inds{stimChan} = stim.inds{stimChan}-1;  % Onset occurs at least 1 sample pt before peak
        stim.times{stimChan} = data.t(stim.inds{stimChan});
    end  
end
