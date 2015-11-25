%% Converting raw cells traces to dF/F & filtering a bit
nBaselineFrames = round(min(10,data.baselinePeriod)/stack.interval);
baselineInds = [];
for shock = 1:numel(stack.inds.shock)
    baselineInds = [baselineInds, stack.inds.shock(shock)-nBaselineFrames:stack.inds.shock(shock)-1];
end
baselineInds(baselineInds <=0) = [];
baselineF = repmat(mean(data.cells.raw(:,baselineInds),2),1,size(data.cells.raw,2));
data.cells.dFF = (data.cells.raw - baselineF)./baselineF;

nyqFreq = 0.5*(1/stack.interval);
lpf = 0.9*nyqFreq;
kernelWidth = max(round(1/lpf),5); 
kernel = gausswin(kernelWidth); % Not using at the moment
kernel = kernel/sum(kernel);

lastPt = min(stack.N,size(data.cells.raw,2));
nCells = size(data.cells.raw,1);
data.cells.time = (0:size(data.cells.raw,2)-1)*stack.interval;

disp(['Smoothing cellular Ca++ responses with lowpass of  ' num2str(lpf)])
if strcmpi(smoothingType,'conv')
    data.cells.dFF = chebfilt(conv2(double(data.cells.dFF'),kernel(:)','same'),stack.interval,1/200,'high');
    data.cells.dFF = data.cells.dFF';
else
    data.cells.dFF = chebfilt(chebfilt(double(data.cells.dFF'),stack.interval,lpf,'low'),stack.interval,1/200,'high');
    data.cells.dFF = data.cells.dFF';
end