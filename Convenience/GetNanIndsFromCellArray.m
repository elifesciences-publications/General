function nanInds = GetNanIndsFromCellArray(inputArray)
% GetNandsFromCellArray - Given a 1D cell array, returns indices of cells
%   with NaNs
% nanInds = GetNanIndsFromCellArray(inputArray);
% 
% Avinash Pujala, JRC/HHMI, 2016

nanInds = false(length(inputArray),1);
for jj = 1:length(inputArray)
    var = inputArray{jj};
    if any(isnan(var)) || strcmpi(var,'nan')
        nanInds(jj) = true;
    end
end

