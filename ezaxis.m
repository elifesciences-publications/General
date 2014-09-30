function ezaxis(theFcn, theInvFcn, theAxis)

% ezaxis -- Map ticks on an axis.
%  ezaxis(theFcn, 'theInvFcn', 'theAxis') uses 'theFcn'
%   and 'theInvFcn' functions to map 'theAxis' ('x', 'y',
%   or 'z'; default = 'y').  Either function may be a
%   function name, to be evaluated by "feval", or a
%   Matlab expression of "t", where "t" represents
%   tick locations.
%  ezaxis('demo') demonstrates itself with y = exp(x),
%   then "ezaxis exp log y".  The figure is automatically
%   updated when resized.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 21-Oct-1999 23:41:27.
% Updated    27-Oct-1999 08:41:57.

if nargin < 1, help(mfilename), theFcn = 'demo'; end
if nargin < 2, theInvFcn = ''; end
if nargin < 3, theAxis = 'y'; end

if isequal(theFcn, 'demo')
	delete(get(gcf, 'Children'))
	if (0)
		theFcn = 'exp';
		theInvFcn = 'log';
	else
		theFcn = 'merc';
		theInvFcn = 'invmerc';
	end
	theAxis = 'y';
	x = linspace(40, 80, 41);
	y = feval(theFcn, x);
	subplot(1, 2, 1)
	plot(x, y), title('y = merc(x)')
	xlabel('Degrees'), ylabel('Mercator Units')
	set(gca, 'HandleVisibility', 'off')
	subplot(1, 2, 2)
	theCommand = 'ezaxis   merc   invmerc   y';
	plot(x, y), title(theCommand)
	xlabel('x'), ylabel('Degrees')
	feval(mfilename, theFcn, theInvFcn, theAxis)
	set(gca, 'GridLineStyle', ':')
	grid on
	set(gcf, 'ResizeFcn', theCommand)
	figure(gcf)
	set(gcf, 'Name', 'ezaxis demo')
	return
end

orig = gca;

thePosition = get(orig, 'Position');
theLim = get(orig, [theAxis 'Lim']);

alphabet = char([abs('A'):abs('Z') abs('a'):abs('z') abs('_')]);

isExpression = 0;
for i = 1:length(theInvFcn)
	if any(theInvFcn(i) == alphabet)
	else
		isExpression = 1;
		break
	end
end

for i = 1:length(theLim)
	t = theLim(i);
	if isExpression
		theLim(i) = eval(theInvFcn);
	else
		theLim(i) = feval(theInvFcn, t);
	end
end

temp = axes('Position', thePosition, 'Visible', 'off');
set(temp, [theAxis 'Lim'], theLim)

theTick = get(temp, [theAxis 'Tick']);
theTickLabels = get(temp, [theAxis 'TickLabel']);

delete(temp)

isExpression = 0;
for i = 1:length(theFcn)
	if any(theFcn(i) == alphabet)
	else
		isExpression = 1;
		break
	end
end

for i = 1:length(theTick)
	t = theTick(i);
	if isExpression
		theTick(i) = eval(theFcn);
	else
		theTick(i) = feval(theFcn, t);
	end
end

set(orig, [theAxis 'Tick'], theTick, [theAxis 'TickLabel'], theTickLabels)


function y = merc(latitude)

% merc -- Mercator projection.
%  merc(latitude) returns the Mercator projection
%   for the latitude, given in degrees.

RCF = 180/pi;

y = log(tan(0.25*pi+0.5*latitude/RCF));


function latitude = invmerc(y)

% invmerc -- Inverse Mercator projection.
%  invmerc(y) returns the latitude, in degrees,
%   corresponding to the Mercator coordinate y.

RCF = 180/pi;
latitude = (pi/2 - 2*atan(exp(-y)))*RCF;
