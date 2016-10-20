
dims  = size(dataMat);
nIter = prod(dims(1:3))*prod(dims(5:end-1));
fData = nan(nIter, size(dataMat,4)+ndims(dataMat)-1);
grpNames = fieldnames(data);
remInd = find(strcmpi(grpNames,'ablationType'));
grpNames(remInd) =[];
stimNames = fieldnames(data.(grpNames{1}));
count = 0;
tic
rowInd_start = 1;
for d1 = 1:size(dataMat,1) % Ablated or not   
    for d2 = 1:size(dataMat,2) % Stim type - dark or vib
        for d3 = 1:size(dataMat,3) % Fish Num
           sessionNum = data.(grpNames{d1}).(stimNames{d2}){d3}.sessionNum;
            for d5 = 1:size(dataMat,5)
                blah = squeeze(dataMat(d1,d2,d3,:,d5,:))';
                blah(:,end)=[]; % Remove session num from here
                nanRows = find(sum(isnan(blah),2)== size(blah,2));
                blah(nanRows,:) = [];
                rowInd_end = rowInd_start + size(blah,1)-1;
                temp  = repmat([d1,d2,sessionNum,d3,d5],size(blah,1),1);
                bendVec = 1:size(blah,1);
                temp = cat(2,temp,bendVec(:),blah);                
                fData(rowInd_start:rowInd_end,:) = temp;
                rowInd_start = rowInd_end + 1;
                count  = count + 1;
                dispChunk = round(nIter/5);
                if mod(count,dispChunk)==0
                    perc = round(((count/nIter)*100)*100)/100;
                    disp([num2str(perc) ' %'])
                end
                
            end
        end
    end
end
toc

% Convert to cell array
disp('Creating cell array...')
tic
fData_cell = num2cell(fData,size(fData));
toc

fldNames = fieldnames(data.ctrl);
darkPos = find(strcmpi(fldNames,'dark'));
vibPos = find(strcmpi(fldNames,'vib'));
darkInds = find(fData(:,2)==darkPos);
vibInds = find(fData(:,2) == vibPos);

fData_cell(darkInds,2) = num2cell(repmat({'DarkFlash'},length(darkInds),1));
fData_cell(vibInds,2) = num2cell(repmat({'Vibration'},length(vibInds),1));
fishIdArray = cell(size(fData,1),1);
abTypeArray = fishIdArray;
for ii = 1:size(fData,1)
    id = [num2str(fData(ii,3)) '-' num2str(fData(ii,4))];
    fishIdArray{ii} = id;
    abTypeArray{ii} = data.ablationType;
end
fData_cell = [abTypeArray, fData_cell, fishIdArray];


%## Creating column name vector and cocatenating with data array
fldNames = []; count = 0;
while isempty(fldNames) && count < size(dataMat,5)
    count = count + 1;    
        fldNames = fieldnames(data.abl.vib{count});
end
sessInd = find(strcmpi(fldNames,'sessionNum'));
fldNames(sessInd) = [];
varNames_sub = cell(1,length(fldNames));
for fn = 1:length(fldNames)
    fldName = fldNames{fn};
    fldName(1) = upper(fldName(1));
    varNames_sub{fn} = fldName;
end

varNames_all = [{'AblationType','AblationBool','StimType',...
    'SessionNum','FishNumInGroup','TrialNum','BendNum'}, ...
    varNames_sub,'FishID'];

if size(varNames_all,2) ~= size(fData_cell)
    error('Column labels do not match the size of the data array!')
end

fData_cell = [varNames_all; fData_cell];
