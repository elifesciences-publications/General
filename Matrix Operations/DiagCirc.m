function D = DiagCirc(M)
% DiagCirc - Given a matrix returns all the diagonals of the matrix
%   resulting from circular warping of the matrix such that all diagonals
%   have the same length
% D = DiagCirc(M)

if ndims(M)>2
    error('At the moment, this function only works for 2D matrices!')
end
if any(size(M)==1)
    error('Input is a vector, this function is meaningless for it!')
end
n = max(size(M));
blah = diag(M);
nRows = numel(blah);
D = nan(nRows,n);
D(:,1) = diag(M);
ctr = 1;
for d = 1:n-1
    ctr = ctr + 1;
    blah = diag(M,d);    
    if numel(blah)< nRows
        D(:,ctr) = [diag(M,d); diag(M,d-n)];
    else
        D(:,ctr) = diag(M,d);
    end    
end
end