% crossDataComparison
%   Loads data from several abf files into the matlab workspace for
%   comparison and analysis.
%   Simply type crossDataComparison at the command prompt.

%% Declare some structure variables
% dataStruct=[];timeAxisStruct=[];
% smoothStruct=[];smoothTimeAxisStruct=[];

%% Choosing file and processing data
answer='Yes';
nFiles=0;
while strcmp(answer,'Yes');
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
            [data,timeAxis]=PSRCompare(data,samplingInt);
            dataStruct.(file)= data;
            timeAxisStruct.(file)= timeAxis;
            [smooth,smoothTimeAxis]=smooth_adj(data,timeAxis);
            smoothStruct.(file)= smooth;
            smoothTimeAxisStruct.(file)= smoothTimeAxis;
        case 'No'
            fNames=char(fieldnames(dataStruct));
    end
end