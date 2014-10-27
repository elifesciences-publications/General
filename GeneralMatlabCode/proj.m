function [v_proj] = proj(v,u)
% PROJ
% [v_proj] = proj(v,u)
% Generates a vector, v_proj that is obtained by orthogonally projecting
% the vector v onto the unit vector u
% If u is not a unit vector then it converts it into one
% Author: AP
if sqrt(sum(u.^2))>1
    u=unitvec(u);
end
v_proj = dot(v,u)*u;
if size (v_proj,2) > 1 
    v_proj = v_proj'
end