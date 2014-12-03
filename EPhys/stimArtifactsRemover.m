samplingInterval = samplingInt; % Sampling interval in seconds.
stimDuration =0.2; % stimulus duration in ms.
stimDuration_samples=round(stimDuration/samplingInterval); % approx. # of sample pts. within stimDuration
mat=[];

for j=1:size(data,2); % Loop as many times as there are columns in the data variable.
    trace=data(:,j);
[maxtab, mintab]=peakdet(trace,20*std(trace)); % Identify peaks and valleys that are at least
                                               % as many standard
                                               % deviations away from the
                                               % mean of the data as
                                               % determined by the
                                               % multiplicand before the
                                               % std
%% Equalize the lengths of maxtab and mintab
                                               
if length(maxtab)>length(mintab)
    maxtab(1,:)=[];
elseif length(maxtab)<length(mintab)
    mintab(1,:)=[];
end

for j=1:length(maxtab)
       if  (maxtab(j,1)-ceil(stimDuration_samples/2))<0 |...
            (mintab(j,1)-ceil(stimDuration_samples/2))<0
        blah=0;
    else
        trace(mintab(j,1)-stimDuration_samples/2:mintab(j,1)+stimDuration_samples)=...
            mean(trace)+std(trace)*((rand<0.5)*2-1)*...
            [rand(1,length(mintab(j,1)-stimDuration_samples/2:mintab(j,1)+stimDuration_samples))];
        trace(maxtab(j,1)-stimDuration_samples/2:maxtab(j,1)+stimDuration_samples)=...
            mean(trace)+std(trace)*((rand<0.5)*2-1)*...
            [rand(1,length(maxtab(j,1)-stimDuration_samples/2:maxtab(j,1)+stimDuration_samples))]; 
    end
end
mat=[mat trace];
end