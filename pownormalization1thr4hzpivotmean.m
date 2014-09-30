
% Normalizes the power values within the data matrix = d, where d(:,1) =
% stim intensity as multiples of threshold and d(:,2) = stim freq. The
% normalization algorithm involves computing the mean of power values
% obtained by stimulating at 1x Thr and 4Hz (thus 1x Thr and 4Hz act as 
% pivot points) and then dividing the rest of the power values by this mean
% value. This minimizes the variability in power for the pivot variables.

dp = d(d(:,1)>=1 & d(:,1)<=2 & (d(:,2)==4 | d(:,2)==5),:);
% if isempty (dp)
%        dp = d(d(:,1)>=1 & d(:,1)<=2 & d(:,2)==5,:);  % (1x Thr & 5Hz is pivot if there is no 1x Thr & 4Hz)
% end

dm = mean(dp(:,3));
pn = d(:,3)/dm;