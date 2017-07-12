function crossInds = LevelCrossings(x,thr)
%LevelCrossings Given a timeseries signal and a threshold, returns the
%   indices where the signal crosses the threshold in both the directions.
% crossInds = LevelCrossings(x,thr);
% Inputs:
% x - Timeseries (vector) signal.
% thr - Threshold at which the crossings occur.
% Outputs:
% crossInds - A cell array of size [2 1]. Where the 1st cell of the array
%   has the indices where the signal crosses the threshold going up, and
%   the 2nd cell has the indices where the signal crosses the threshold
%   going down.
% 
% Avinash Pujala, JRC/HHMI, 2016

inds_up = find(x(1:end-1)< thr & x(2:end)>thr);
inds_down = find(x(1:end-1)> thr & x(2:end)<thr);
crossInds = cell(2,1);
crossInds{1} = inds_up;
crossInds{2} = inds_down;

end

