function varargout = GetCubic(x)
%GetCubic- Finds the maxima and minima in a signal, cubic interpolates
%                    between each set of points and subtracts this from the
%                    original signal
% 
% y = GetCubic(x);
% [y,s,pks_max,pks_min] = GetCubic(x);
% Outputs:
% s - Mean of the interpolated maximal and minimal envelope
% y - Residual of the orginal signal and the s
% pks_max - Crest indices
% pks_min - Trough indices

pks_min = GetPks(-x);
pks_max = GetPks(x);
x = x(:)';
s1 = interp1([0 pks_min(:)' length(x)+1],[x(1) x(pks_min(:)) x(end)],1:length(x),'cubic');
s2 = interp1([0 pks_max(:)' length(x)+1],[x(1) x(pks_max(:)) x(end)],1:length(x),'cubic');
y = x - (s1+s2)/2;

varargout{1} = y;
varargout{2} = (s1+s2)/2;
varargout{3} = pks_max;
varargout{4} = pks_min;
end

