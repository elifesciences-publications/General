function varargout = FitCircle(cInds,varargin)
%FitCircle Given a set of indices of roughly circular shape, returns
%   indices of a circle that fits the shape
% 
% circleInds = FitCircle(circleLikeInds,nIter,tolerance)
% Inputs:
% cirleLikeInds - x,y indices of a circle like shape (such as the edge indices for an arena in which a 
%    fish swims in during behavior expts)
% nIter - Number of iterations, through which the program must go in order to converge onto a circle 
% tolerance - Error tolerance (default: 0.5). Iterations stop when
%   difference in error for previous and currrent iterations falls below
%   the tolerance
% 
% Avinash Pujala, HHMI, 2016


tol = 0.5; % Tolerance for percentage error improvement between one iteratio and the next
shift = [mean(cInds(:,1)), mean(cInds(:,2))];
x = cInds(:,1)-shift(1);
y = cInds(:,2)-shift(2);

if nargin ==1
    nIter = 1;
elseif nargin ==2
    nIter = varargin{1};
elseif nargin ==3;
    nIter = varargin{1};
    tol = varargin{2};
end
%## Iteratively find a circle that fits indices well

for iter = 1:nIter  
    [theta,rho] = cart2pol(x,y);
    rho_fit = mean(rho)*ones(size(rho));
    error = sqrt(sum((rho-rho_fit).^2))/numel(rho);   
    disp(['Iter# ' num2str(iter) ', Error = ' num2str(error*100) '%'])
    [x_fit,y_fit] = pol2cart(theta,rho_fit);
    if iter > 1 && ((error_prev-error)*100) < tol
        disp(['Error within tolerance of ' num2str(tol) ' %, quitting!'])
        break
    end
    offset = [mean(x)-mean(x_fit), mean(y)-mean(y_fit)];
    shift = shift + offset;
    x = x - offset(1);
    y = y - offset(2);
    error_prev = error;    
end
%## Fill in missing points in the circle and uniformly downsample
[theta,rho] = cart2pol(x_fit,y_fit);
tt = linspace(-pi,pi,numel(theta));
rr = interp1(theta,rho,tt,'spline');

[x_fit,y_fit]= pol2cart(tt,rr);
figure
plot(x_fit,y_fit,'r.'), hold on
plot(x,y,'b.'),axis image
legend('Fit','Original','Location','best')
xlim([-inf inf])
title(['Iter# ' num2str(iter) ', Error = ' num2str(error*100) '%'])
varargout{1} = [x_fit(:)+shift(1), y_fit(:)+shift(2)];
end

