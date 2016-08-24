function theta_ref = ReflectAngleOnY(theta)
% ReflectAngleOnY - Given an angle or matrix of angles (in degrees), gives 
% values(s) after reflection on Y-axis

theta = theta*pi/180;
[x,y] = pol2cart(theta,ones(size(theta)));
theta_ref = angle(-x + 1i*y)*180/pi;
theta_ref(theta_ref<0) = theta_ref(theta_ref<0) + 360;
end

