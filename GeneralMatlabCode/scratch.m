stimConditions = unique(amplitudes.right);
for jj = 1:numel(stimConditions)
    indices = find(amplitudes.right == stimConditions(jj));
    startTimes = onsets.right(indices)-0.5;
    endTimes = startTimes + traceLength;
    startPts = round(startTimes/samplingInt);
    endPts = round(endTimes/samplingInt);
    for kk = 1:numel(startPts)
        traces.left{jj}(kk,:) = signal.left(startPts(kk):endPts(kk));
    end
end
episodicTime = ([startPts(kk):endPts(kk)]-startPts(kk))*samplingInt;
episodicTime = episodicTime-0.5; % So that stim onset corresponds to time = 0