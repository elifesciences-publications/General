function [vec, mag] =unitvec(x)
% UNITVEC
% [unitVector, magnitude]  = unitvec(x)
% Takes a vector as input obtains its magnitude and normalizes it by the
% magnitude.
% The outputs are the normalized vector and magnitude of the input vector.
% Author: AP
mag=norm(x);
vec= x./mag; 
if size(vec,2)>1
    vec = vec';
end