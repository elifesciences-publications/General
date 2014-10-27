%%% Just some code to concatenate the different files loaded by mfload.


fNames = char(fieldnames(dataStruct));
nFiles = size(fNames,1);
mat = [];
for jj = 1:nFiles
    mat = [mat; dataStruct.(fNames(jj,:))];
end
if any(diff(samplingInts))
    errordlg('Sampling Intervals for All Files Not Equal')
break;
end
dt = samplingInts(1);
tt = (0:length(mat)-1)*dt;
mat = [tt(:) mat];
