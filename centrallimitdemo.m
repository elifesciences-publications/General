% CENTRALLIMITDEMO - Graphically illustrates central limit theorem in
% action
% First plots an exponential population distribution along with the
% distribution of a samples uniformly randomly pulled out of this 
% distribution. This sample distribution will, therefore, also have an
% exponential distribution. As space bar is pressed repeatedly, the
% randomly pulled samples from the original exponentially distributed
% population distribution are added and their distribution is plotted. The
% iteration number is plotted as the figure title. As more and more samples
% are added, the summed sample distribution can be seen to progressively
% become more gaussian as dictated by the central limit theorem.

%% Population distribution parameters
popSize = 2000;
minVal = 0;
maxVal = 1000;
popMean = 200;

%% Other parameters
sampSize = 1000;
numCycles = 200;
numBins = 20;

%% Generating population distribution
% pop = rand(1,popSize);
% pop = cos(2*pi*(linspace(0,1,popSize))*4);
pop = exprnd(popMean,1,popSize); % Exponential population distribution
pop = pop*((maxVal - minVal)/range(pop));
[popProbs, popVals] = hist(pop,numBins);
popProbs = popProbs/max(popProbs); % Normalized to max value

%% Sampling from population, adding samples and plotting their dist
samp = zeros(1,sampSize);
for k = 1:numCycles
r = ceil(rand(1,sampSize)*1000);
samp = samp + pop(r);
[sampProbs,sampVals] = hist(samp,numBins);
sampProbs = sampProbs/max(sampProbs);
plot(popVals,popProbs); hold on
ylim([0 1.1])
plot(popVals,sampProbs,'color',rand(1,3),'linewidth',2),title(num2str(k))
hold off
pause
end

