rng('default')
finalNumSweeps = 10;
numSweeps = size(oldsweeps,1);
lenSweep = size(oldsweeps,2);
sweepRange = range(oldsweeps);
% minSweeps = min(oldsweeps);
% maxSweeps = max(oldsweeps);
muSweep = mean(oldsweeps);
sigSweep = std(oldsweeps);
% noise = rand(1,lenSweep).*sweepRange;
% sr = round(lenSweep/10);
% noise = noise(1:sr:end);
% newSweep = minSweeps + noise;

newsweeps = oldsweeps;
m1 = mean(mean(oldsweeps));
for ss = 1:(finalNumSweeps-numSweeps) 
noise  = randn(1,lenSweep).*(2* sigSweep);
newSweep = muSweep + noise;
% newSweep = sqrt(muSweep.* noise);
% m1 = mean(newSweep);
newSweep = chebfilt(newSweep,1/newSamplingFrequency,0.2,'low');
 m2 = mean(newSweep);
newSweep = newSweep * (m1/m2);
newSweep(newSweep<0)=0;
newSweep(1:zerotill)=0;
newsweeps = [newsweeps; newSweep];
end

mu_newsweeps = mean(newsweeps);
sig_newsweeps = std(newsweeps);

% tt = time_adjusted(1:sr:end);

