

filterindex=1;
while filterindex;
test3;
fst=transientPts(1)*samplingInt;
lst=transientPts(end)*samplingInt;
baseline=mean(data(transientPts(1)-100:transientPts(1),:));
filename=filename(1:4);
allData.(filename)=struct('data',data, 'data_mod',data_mod,...
    'timeAxis',timeAxis, 'samplingInt',samplingInt, 'fst', fst,...
    'lst', lst,'baseline', baseline);
% data=setfield(filename,data);
% data_mod=struct(filename,data_mod);
% timeAxis=struct(filename,timeAxis);
% samplingInt=struct(filename,samplingInt);
% transientPts=struct(filename,transientPts);
% fst=struct(filename,transientPts(1)*samplingInt);
% lst=struct(filename,transientPts(end)*samplingInt);
% blah=mean(data(transientPts(1)-100:transientPts(1),:));
% baseline=struct(filename,blah);
end

allData = struct('data',data, 'data_mod',data_mod, 'timeAxis',timeAxis,...
    'samplingInt', samplingInt, 'transientPts', transientPts,'fst',fst,...
    'lst', lst, 'baseline', baseline);
