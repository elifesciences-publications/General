% LOADDATA  Loads selected data into matlab workspace.

[file,path]=uigetfile('*.abf');
f=fullfile(path,file);
try
    [data, samplingInt, fileInfo]=abfloadap(f);
    samplingInt = samplingInt*1e-6; % Expresses sampling interval in seconds.
    timeAxis = (0:length(data)-1)*samplingInt; % Creates a time axis vector starting with time zero
    cd(path) % Change path to that which contains the file opened.
catch
    errordlg('Error in "LOADDATA.m". Try loading file using "import_atf.m"');
end