%% Converting raw cells traces to dF/F & filtering a bit
tic
nBaselineFrames = round(min(10,data.baselinePeriod)/stack.interval);
baselineInds = [];
for shock = 1:numel(stack.inds.shock())
    trlBaselineInds = stack.inds.shock(shock)-nBaselineFrames:stack.inds.shock(shock)-1;
    if any(trlBaselineInds < 0) || any(trlBaselineInds > numel(stack.inds.start))
        disp(['Skipped trial # ' num2str(shock) ' in computing dF/F'])
    else
        baselineInds = [baselineInds, trlBaselineInds];
    end
end
baselineInds(baselineInds <=0) = [];
baselineInds(baselineInds > size(data.cells.raw,2)) = [];
baselineF = repmat(mean(data.cells.raw(:,baselineInds),2),1,size(data.cells.raw,2));
data.cells.dFF = (data.cells.raw - baselineF)./baselineF;

nyqFreq = 0.5*(1/stack.interval);
lpf = 0.9*nyqFreq;
kernelWidth = max(round(1/lpf),5);
kernel = gausswin(kernelWidth); % Not using at the moment
kernel = kernel/sum(kernel);

lastPt = min(stack.N,size(data.cells.raw,2));
nCells = size(data.cells.raw,1);
data.cells.time = data.t(stack.inds.start)+1;
extraStacks = size(data.cells.raw,2)- length(data.cells.time);
if extraStacks > 0     
    data.cells.raw(:,1:length(data.cells.time)) = [];
elseif extraStacks < 1
    data.cells.time = data.cells.time(1:size(data.cells.raw,2));
end


disp(['Smoothing cellular Ca++ responses with lowpass of  ' num2str(lpf)])
if strcmpi(smoothingType,'conv')
    data.cells.dFF = chebfilt(conv2(double(data.cells.dFF'),kernel(:)','same'),stack.interval,1/200,'high');
    data.cells.dFF = data.cells.dFF';
else
    data.cells.dFF = chebfilt(chebfilt(double(data.cells.dFF'),stack.interval,lpf,'low'),stack.interval,1/200,'high');
    data.cells.dFF = data.cells.dFF';
end

toc