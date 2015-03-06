function y = GetMaximalEnvelope(x)
%GetMaximalEnvelope - Get the envelope of the maxima in a signal
%   Detailed explanation goes here

pks = findpeaks_hht(x);

pks = pks(:)';
x = x(:)';
y = interp1([0 pks pks(end)+1], [x(1) x(pks) x(end)],1:length(x));



end

