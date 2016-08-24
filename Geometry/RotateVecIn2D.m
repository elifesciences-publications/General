function v_rot = RotateVecIn2D(v, th)
%RotateVecIn2D Rotate a vec in 2D by specified angle
% v_rot = RotateVecIn2D(v,theta);
% 
% Inputs:
% v - Vector in 2D that is to be rotated
% theta - Angle in degrees by which the vector is to be rotated counter
%   clockwise. To rotate clockwise, specify negative angle.
% Outputs:
% v_rot - Vector resulting from rotation

if numel(v)>2
   warning('Vector is in > 2 dimensional space, only rotating in the 1st 2 dimensions!')
end

v_sub = v(1:2);
[theta,rho] = cart2pol(v_sub(1), v_sub(2));
theta = theta + th*pi/180;

[v_rot(1),v_rot(2)] = pol2cart(theta, rho);

v(1:2) = v_rot(1:2);
v_rot = v;


end

