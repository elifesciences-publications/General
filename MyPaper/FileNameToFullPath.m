 function fullPath = FileNameToFullPath( fileNameStr,baseDir )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Extract Year
if ~isempty(findstr('_',fileNameStr))
    yr = [num2str(20) [fileNameStr(4:5)]];
else
    yr = [num2str(20) [fileNameStr(2:3)]];
end
yr = num2str(yr);

%% Extract Day
if ~isempty(findstr('_',fileNameStr))
    last_ = max(findstr('_',fileNameStr));
    dy = [fileNameStr(last_-2:last_-1)];
else
    dy = [fileNameStr(end-4:end-3)];
end

%% Extract  Month
if ~isempty(findstr('_',fileNameStr))
    first_ = min(findstr('_',fileNameStr));
    mo = [fileNameStr(first_+1:first_+2)];
    blah = [yr '_' mo '_' dy];
    [~, mo] = month(blah);
else
    blah = fileNameStr;
    blah([1 end-2:end]) = []; % Eliminate T and file #
    blah([1:2 end-1:end]) = []; % Eliminate yr and day
    mo = blah; % The remaining is the month
    if numel(mo)<2
        mo = ['0' mo];
    end
    blah = [yr '_' mo '_' dy];
    [~, mo] = month(blah);
end

%% Find year folder and append base directory
cd(baseDir)
folders = ls;
for nFolder = 1:size(folders,1)
    currentFolder = folders(nFolder,:);
        if strncmpi(currentFolder,yr,4)
        dirAdd = folders(nFolder,:);
        spaces = findstr(dirAdd, ' ');
       dirAdd(max(setdiff(find(dirAdd),spaces))+1:spaces(end)) = []; % Remove extra spaces at the end
        fullDir = [baseDir '\' dirAdd];
    end
end

%% Find month folder and extend path
cd(fullDir)
folders = ls;
for nFolder = 1:size(folders,1)
    currentFolder = folders(nFolder,:);
        if strncmpi(currentFolder,mo,3)
        dirAdd = folders(nFolder,:);
        spaces = findstr(dirAdd, ' ');
       dirAdd(max(setdiff(find(dirAdd),spaces))+1:spaces(end)) = []; % Remove extra spaces at the end
       fullDir = [fullDir '\' dirAdd];
    end
end

%% Find day folder and extend path
cd(fullDir)
folders = ls;
for nFolder = 1:size(folders,1)
    currentFolder = folders(nFolder,:);
    blah = currentFolder;
    f = findstr(blah,yr);
    blah(f:end)=[];
        if findstr(blah,dy)
        dirAdd = folders(nFolder,:);
        spaces = findstr(dirAdd, ' ');
       dirAdd(max(setdiff(find(dirAdd),spaces))+1:spaces(end)) = []; % Remove extra spaces at the end
       fullDir = [fullDir '\' dirAdd];
    end
end

fullPath = fullDir;