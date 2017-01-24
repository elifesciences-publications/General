

saveDir = 'S:\Avinash\Ablations and behavior\GrpData';

fldNames = fieldnames(data_xls);
data_array = cell(numel(data_xls.bendAmp)+1,length(fieldnames(data_xls)));
for fld = 1:length(fldNames)
    fldName = fldNames{fld};
    fldName(1) = upper(fldName(1));
    data_array{1,fld} = fldName;
    vars = data_xls.(fldNames{fld});
    if iscell(vars(1))
        data_array(2:end,fld) = data_xls.(fldNames{fld});
    else
        data_array(2:end,fld) = num2cell(data_xls.(fldNames{fld}));
    end    
end

ts = datestr(now,30);
fName = ['Peak Info for Group Data_' ts];
xlswrite(fullfile(saveDir,fName),data_array)
