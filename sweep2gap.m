function blah = sweep2gap(data)

if ndims(data) <3;
    errordlg('Input variable must be at least 3 dimensional')
   return
end

blah = [];
for trials = 1:size(data,3)
    blah = [blah;data(:,:,trials)];
end

