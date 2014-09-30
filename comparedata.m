% COMPAREDATA  Loads multiple data files into matlab workspace
% COMPAREDATA loads data from selected abf files into matlab workspace as a
% data structure with field names corresponding to the names of the data
% files.
%  
% NB: The program calls PSRCOMPARE so the point of onset of first
% stimulus has time and data values of zero.
%
% Author: AP

%% Choosing file and processing data
answer='Yes';
nFiles=0;
while strcmpi(answer,'Yes');
    nFiles = nFiles + 1;
    if nFiles >1
        answer=questdlg('Would you like to analyze another file? ',...
            'Choosing another file','Yes','No','No');
        cd(path);
    end
    switch answer
        case 'Yes'
            load_data;
            f=findstr('.',file);
            file=file(1:f-1);
            file=num2str(file);
            file=['T' file];
            [data,timeAxis]=psrcompare(data,timeAxis);
            dataStruct.(file)= data;
            timeAxisStruct.(file)= timeAxis;
%             [smooth,smoothTimeAxis]=smooth_adj(data,timeAxis);
%             smoothStruct.(file)= smooth;
%             smoothTimeAxisStruct.(file)= smoothTimeAxis;
        case 'No'
            fNames=char(fieldnames(dataStruct));
    end
end
close all
