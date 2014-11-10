

%% This pulls out the avg total power for all alternate channel pairs from the variable 'statMat' and expresses them as strength
if size(statMat,2)~= 17
    statMat = statMat';
elseif size(statMat,1) == size(statMat,2)
    statMat = statMat';
end
% row(1) = [size(fNames,1)* (numel(ch)-1)] + 2;
% row(2) = row(1)+((numel(ch)-1)*2)- 1 ;

row(1) = (size(fNames,1)*(numel(ch)-1)) + 2*(numel(ch)-1) + 2; 
row(2) = row(1)+((numel(ch)-1)*2)-1;
col = 13;
b = statMat(row(1):row(2),col);
b = cell2mat(b);
b = round(sqrt(b)');
% b = sqrt(b(1:2:end))'

row(1) = 2;
row(2) = row(1)+(nChannelPairs*nFiles)-1;
c = statMat(row(1):row(2),13);
c = sqrt(cell2mat(c));
d = reshape(c,nChannelPairs,nFiles)';
d_norm = d./mean(d(:,1));
b = [d_norm;b];
b = round(b*100)/100;
normalizedSignalPairXWPower = b;



