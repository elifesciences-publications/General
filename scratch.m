
crests = findpeaks_hht(blah);
troughs = findpeaks_hht(-blah);
x = union(crests,troughs);
x = [1; x(:); length(blah)];
y = blah(x);
yy = interp1(x(:),y(:),1:length(blah),'cubic');


