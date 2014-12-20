%% Smoothing and segmenting data by trials

artlessSignal = zeros(size(dataChannels));
smSignal = artlessSignal;
for cn = 1:numel(ePhysChannelToAnalyze); 
     artlessSignal(cn,:) = DeartifactWithGauss(dataChannels(cn,:),samplingInt,artInds,20e-3,20e-3); % 45e-3 seems to work best!
    artlessSignal(cn,:) = DeartifactWithGaussInterp(artlessSignal(cn,:),samplingInt,artInds,20e-3,20e-3); % 45e-3 seems to work best!
    
    artlessSignal(cn,:) = chebfilt(artlessSignal(cn,:),samplingInt,[hpFilt 1000]); 
    blah = artlessSignal(cn,:);
    threshLevel = mean(blah) + 10*std(blah);
    blah(blah > threshLevel)= threshLevel;
    blah(blah < -threshLevel) = -threshLevel; % Saturating at value of 10
    artlessSignal(cn,:) = blah;
    smSignal(cn,:) = SmoothVRSignals(artlessSignal(cn,:),samplingInt,hpFilt,lpFilt);
    smSignal(cn,:) = DeartifactWithGaussInterp(smSignal(cn,:),samplingInt,stimInds,20e-3,30e-3);
    blah = smSignal(cn,:);
    threshLevel = mean(blah) + 50*std(blah);
     blah(blah > threshLevel)= threshLevel;
    blah(blah < -threshLevel) = -threshLevel; % Saturating at value of 10
   smSignal(cn,:) = chebfilt(blah,samplingInt,1,'high');
  end
smSignal = smSignal';
preStimPts  = round(preStimPeriod*samplingRate);
postStimPts = round(postStimPeriod*samplingRate);

fprintf('\n Deartifacting & smoothing signals \n')

% artlessSignal = BlankArtifact(artlessSignal,samplingInt,stimInds,5e-3, 10e-3);
% 
% smSignal = SmoothVRSignals(artlessSignal,samplingInt,hpFilt,lpFilt);

% smDiffSignal= SmoothDiffVRSignals(artlessSignal,samplingInt,hpFilt,lpFilt);