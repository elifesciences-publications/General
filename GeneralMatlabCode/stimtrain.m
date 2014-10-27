% STIMTRAIN  Generates stim train
% AP - May 23, 2012

%% OPTIONS
stim_train_type = 'uniform'; % ('variable' - IPIs can be variable; 'uniform' - IPIs regularly spaced; default:'uniform')
%%
clear isi nArts
nArts = 101; % # of stim artifacts
artTrough = 0;
artCrest = 300;
plotWidth = 1.5;
isi = [125]; % In milliseconds
%%
isi = isi/1000; % Conversion to seconds
blah = eval(['data' num2str(fileNum);]);
artAmp = prod(blah,2); % Stim artifacts amplified by multiplication
tStimArts = stimartdetect(artAmp,time);


switch lower(stim_train_type)
    case 'uniform'
        % -------- Uniform Stim Train ------------
        if isempty(isi)
            isi = mode(diff(tStimArts));
        end
        
        stimFreq = 1/isi; stimFreq = round(stimFreq*100)/100;
        stimDur = round((nArts-1)/stimFreq);
        
        tStimArts = tStimArts(1); % First artifact
        tStimArts = ([0:nArts-1]*isi) + tStimArts;
        tStimArts = tStimArts(:)-min(time);
        stimArts = round(tStimArts/samplingInt);
        
    case 'variable'
        % ---------------- Variable Stim Train -----------
        if isempty(isi)
            isi = mean(diff(tStimArts));
        end
        
        stimFreq = 1/isi; stimFreq = round(stimFreq*100)/100;
        stimDur = round(tStimArts(end)-tStimArts(1));
       
        
        tStimArts = tStimArts(:)-min(time);
        stimArts = round(tStimArts/samplingInt);
end

xvec = ones(length(time),1)*nan;
xvec(stimArts)= tStimArts;
xvec(stimArts+1) = tStimArts;

yvec = ones(length(time),1)*nan;
yvec(stimArts)= artTrough;
yvec(stimArts+1) = artCrest;

% figure(100), plot(xvec + min(time),yvec,'r','linewidth',plotWidth)
% set(gca,'ytick',[],'ycolor','w','xtick',[],'xcolor','w'), box off
% xlim([timeRange])
