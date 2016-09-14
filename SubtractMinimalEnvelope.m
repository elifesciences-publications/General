function varargout = SubtractMinimalEnvelope(x)
%SubtractMinimalEnvelope- Finds the minima in a signal, cubic interpolates
%                    between these points and subtracts this from the
%                    original signal
% 
% y = SubtractMinimalEnvelope(x);
% [y,minimaEnvelope,minimaInds] = SubtractMinimalEnvelope(x);
% Outputs:
% minimaEnvelope - the interpolated minima envelope
% minimaInds - indices of the minima found in the original signal

minimaInds = GetPks(-x);
x = x(:)';
s = interp1([0 minimaInds(:)' length(x)+1],[x(1) x(minimaInds(:)) x(end)],1:length(x),'cubic');
y = x - s;

varargout{1} = y;
varargout{2} = s;
varargout{3} = minimaInds;
end

