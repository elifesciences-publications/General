
N  = nan(numel(data.swim.startInds),1);
for jj = 1:numel(data.swim.startInds)
    N(jj) = norm(data.smooth.burst(data.swim.startInds(jj):data.swim.endInds(jj),1));
end
