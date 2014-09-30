% Simulate position vs. time data for a rolling ball
close all; clear all;
% randn('state',0); % Reset the random number generator
x = 1:9;  % define the intervals for taking measurments
vox = 0.5;    % initial velocity in the x direction
t = x/vox;    % compute t for ideal case
t = t+.5*randn([size(x) 1]); % add some noise
plot(x,t,'o') % plot the data and add labels
ylabel('time (sec)')
xlabel('position (m)')
title('Time vs. position for a rolling ball')
axis([0 9 0 20])
hold on  % keep the first graph up while we plot the fitted line

% Fit a line thru the data and plot the result over the data plot
temp = polyfit(x,t,1); % least squares fitting to a line
a2 = temp(2) % y-intercept of the fitted line
a1 = temp(1) % slope of fitted lines
fit = a2+a1*x;
plot(x,fit)
axis([0 9 0 20])
hold on