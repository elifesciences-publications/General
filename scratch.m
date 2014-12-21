artlessSignal = zeros(size(dataChannels));
smSignal = artlessSignal;
for cn = 1:numel(ePhysChannelToAnalyze);    
    artlessSignal(cn,:) = DeartifactWithGauss(dataChannels(cn,:),samplingInt,artInds,20e-3,40e-3);
    artlessSignal(cn,:) = chebfilt(artlessSignal(cn,:),samplingInt,[hpFilt 1000]); 
    blah = artlessSignal(cn,:);
    threshLevel = mean(blah) + 10*std(blah);
    blah(blah > threshLevel)= threshLevel;
    blah(blah < -threshLevel) = -threshLevel; % Saturating at value of 10
    artlessSignal(cn,:) = blah;
    smSignal(cn,:) = SmoothVRSignals(artlessSignal(cn,:),samplingInt,hpFilt,lpFilt);
    smSignal(cn,:) = DeartifactWithGauss(smSignal(cn,:),samplingInt,stimInds,20e-3,30e-3);
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