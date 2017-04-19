function SaveAllOpenFigs(saveDir)
%SaveAllOpenFigs Saves all open figures as .fig files in specified dir
% SaveAllOpenFigs(saveDir);

if exist(saveDir)~=7
    mkdir(saveDir)
end

h = get(0,'children');
disp(['Saving all open figures to'])
disp(saveDir)
for fig = 1:length(h)
    saveas(h(fig), fullfile(saveDir,['Fig_' sprintf('%.2d',h(fig))]))
end

end

