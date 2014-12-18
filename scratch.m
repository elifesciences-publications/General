periStimWin = 5*(pulseWidth)*samplingRate; % Usually, pulse width does not exceed 0.5 ms
stimAmp = zeros(2,length(stimInds));
for side = 1:nSides
    ss =['stim' num2str(side)];
    fprintf(['\n Estimating ' ss ' amplitudes \n'])
    for cs = 1:length(stimInds)
        fpt = round(max((stimInds(cs)-periStimWin),1));
        lpt = round(min((stimInds(cs)+periStimWin),length(data.t)));
        stimAmp(side,cs) = max(data.(ss)(fpt:lpt)) * stimIsolGain(side);
    end
    dS_med = median(diff(stimAmp(side,:)));
    dS_med(dS_med==0)=1;
    stimAmp(side,:) = round(stimAmp(side,:)/dS_med)*dS_med;
end
stimAmp = floor(stimAmp);
stimAmp(stimAmp>100) = 100; % Since the stim isolator we're using does not deliver > 100 V