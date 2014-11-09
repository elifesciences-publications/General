function [pks,locs] = RemovePeaksWithinRefractoryPeriod(pks,locs,Pd)
% Start with the larger peaks to make sure we don't accidentally keep a
% small peak and remove a large peak in its neighborhood. 

if isempty(pks) || Pd==1,
    return
end

% Order peaks from large to small
[pks, idx] = sort(pks,'descend');
locs = locs(idx);

idelete = ones(size(locs))<0;
for i = 1:length(locs),
    if ~idelete(i),
        % If the peak is not in the neighborhood of a larger peak, find
        % secondary peaks to eliminate.
        idelete = idelete | (locs>=locs(i)-Pd)&(locs<=locs(i)+Pd); 
        idelete(i) = 0; % Keep current peak
    end
end
pks(idelete) = [];
locs(idelete) = [];
