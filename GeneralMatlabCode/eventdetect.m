function eventTimes = eventdetect(data,timeAxis);
lenData = length(data);
nPieces = 10;
fraction = floor(lenData/10);
temp = data(:,3);
blah = timeAxis;
spontTimes =[];
for piece = 1:nPieces-1;
    clf
    plot(blah(1:fraction),temp(1:fraction))
    [x,y,button] = ginput();
    spontTimes = [spontTimes; x(:)];
    blah(1:fraction) = [];
    temp(1:fraction) = [];
end
plot(blah(1:end),temp(1:end));
[x,y] = ginput();
spontTimes = [spontTimes; x(:)];
eventTimes = spontTimes;
