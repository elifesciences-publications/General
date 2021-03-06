function stats = ComputeSignalPairStats(normalizedSignalPairStrengthMatrix);
% ComputeSignalPairStats Computes the means and standard deviations for the
% normalized strengths of the individual signal pairs.
%   normalizedSignalPairStrengthMatrix - Matrix of normalized values for
%   individual signal pairs for all trials within and across expts.
%  stats = ComputeSignalPairStats(normalizedSignalPairStrengthMatrix);
%  Ouputs:
% stats: structure array with following fields
%        'groups','means', 'sigmas','anovaTable','kwStats'

vals = normalizedSignalPairStrengthMatrix;
f = [];
for row = 1:size(vals,1)
    if (any(vals(row,:)>10))
        vals(row,:)=nan;
        f(row) = row;
    end
end
f(f==0)=[];
vals(f,:)=[];

groups = {'Ipsi F-E','Bi F-F','Contra F-E','Bi E-E'};
% boxplot(vals)
means = mean(vals,1);
sigs = std(vals,[],1);
figure('Name','Bar plot')
bar(1:length(means),means,'k')
hold on
errorbar(1:length(means),means,zeros(size(means)),sigs,'r.')
set(gca,'tickdir','out','xtick',[1:length(means)])
box off
set(gca,'xticklabel',groups,'fontsize',14)
ylabel('Normalized XW power for VR pairs','fontsize',14)
ylim([-inf inf]), xlim([-inf inf])
[p,anovaTable, kwStats] = kruskalwallis(vals,groups);
c = multcompare(kwStats);

stats = struct;
stats.groups = groups;
stats.means = means;
stats.sigmas = sigs;
stats.anovaTable = anovaTable;
stats.kwStats = kwStats;

end

