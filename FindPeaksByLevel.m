function varargout = FindPeaksByLevel(x,level)
% FindPeaksByLevel - FindPeaks within a signal that exceed a certain level
% 
% [pks,pkInds] = FindPeaksByLevel(x);

pkInds = findpeaks_hht(x);
pks = x(pkInds);

pkInds( pks < level) = [];
pks(pks < level) = [];

varargout{1} = pks;
varargout{2} = pkInds;

end

