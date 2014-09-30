% LOADFILES  Loads multiple data files into matlab workspace
% LOADFILES loads data from selected .abf files into matlab workspace as a
% data structure with field names set to the file names.
%
% NB: The program calls the routine "ARTIFACTALIGN.m" which sets the time and
% amplitude of each time trace at the occurrence of the first stimulus in
% a train to zero.
%
% Author: AP

%% Choosing the file to load
answer='Yes';
nFiles=0;
while strcmpi(answer,'Yes');
    nFiles = nFiles + 1;
    if nFiles > 1
        answer=questdlg('Would you like to analyze another file? ',...
            'Choosing another file','Yes','No','No');
        cd(path);
    end
    switch answer
        case 'Yes'
            loaddata;
            f=strfind(file,'.');
            file=file(1:f-1);
            file=num2str(file);
            file=['T' file];
            [data,timeAxis]=artifactalign(data,timeAxis);
            dataStruct.(file)= data;
            timeAxisStruct.(file)= timeAxis;
            %             [smooth,smoothTimeAxis]=smooth_adj(data,timeAxis);
            %             smoothStruct.(file)= smooth;
            %             smoothTimeAxisStruct.(file)= smoothTimeAxis;
        case 'No'
            fNames=fieldnames(dataStruct);
    end
end
fNames_char = char(fNames);
close all
