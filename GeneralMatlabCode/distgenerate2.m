clear ord
% prompt={'Enter the mean','Enter the std', 'Number of pts'};
% name='Parameters for distribution';
% numlines=1;
% defaultanswer={'1000','100','10'};
% answer=inputdlg(prompt,name,numlines,defaultanswer);
% mu = str2num(answer{1,1});
% sigma = str2num(answer{2,1});
% nPts = str2num(answer{3,1});

temp(:,3) = temp(:,2)*sqrt(3);
nPts = 15;
distMat = zeros(length(temp),nPts);
for jj = 1:length(temp)
mu = temp(jj,1);
sigma = temp(jj,3);


dist = normrnd(mu,sigma,1,nPts);
ord = sort(dist);
sigmaf = std(ord);
diffSig = sigmaf - sigma;

while (abs(diffSig)>=0.001)
    ord(nPts) = ord(nPts)- (diffSig/10);
    ord(1) = ord(2)+(diffSig/10);
    sigmaf = std(ord);
    diffSig = sigmaf - sigma;
end
muf = mean(ord);
diffMu = muf -mu;
ord = ord - diffMu;
muf = mean(ord);
perm = randperm(nPts);
dist = ord(perm);
[mu muf; sigma sigmaf]

distMat(jj,:) = dist; 
end