
function y = GetSplineEnvelope(x)
x   = transpose(x(:));
s1 = getspline(x);
s2 = -getspline(-x);
y = (s1+s2)/2;






function s = getspline(x)

N = length(x);
p = findpeaks_hht(x);
s = spline([0 p N+1],[0 x(p) 0],1:N);
