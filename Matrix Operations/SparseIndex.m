function elems = SparseIndex(M,rInds,cInds)
% SparseIndex - Given a matrix and row and col indices, returns entries
%   from the matrix that correspond to one-to-one matched row and col indices 
% elements = SparseIndex(M,rInds,cInds)

if nargin < 3
    error('At least 3 inputs required')
end

if numel(rInds)~=numel(cInds)
    error('Number of row and column indices must match')
end

elems = nan(length(rInds),1);
for e = 1:length(rInds)
    elems(e) = M(rInds(e), cInds(e));
end

end

