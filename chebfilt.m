function y = chebfilt(x,samplingInt,varargin)
% CHEBFILT  Filters data using a 2nd order chebyshev filter.
%   output = chebfilt(input,samplingInt,[low high]); returns data bandpassed
%            within specified values.
%   output = chebfilt(input,samplingInt,low,'low'); -- Lowpasses
%   output = chebfilt(input,samplingInt, high,'high'); -- Highpasses
%   output = chebfilt(input,samplingInt,[low high],'stop'); -- Stopbands

N = 2; % Order of the filter
R = 0.2; % Decibels of peak-to-peak ripple in pasband (Default = 0.5)
sf= 1/samplingInt;

if  nargin<4, varargin{2}='blah';
end
clear u l b a
switch varargin{2}
    case 'high'
    operation='Highpassed';
    lower=varargin{1}(1);
    l=(2*lower)/sf;
    [b,a]=cheby1(N,R,l,'high');
%     [b,a]=butter(2,l,'high');
case 'low'
    operation = 'Lowpassed';
    upper=varargin{1}(1);
    u=(2*upper)/sf;
      [b,a]=cheby1(N,R,u,'low');
%      [b,a] = butter(2,u,'low');
case 'stop'
    operation = 'Bandstopped';
    lower=varargin{1}(1);
    upper=varargin{1}(2);
    l=(2*lower)/sf;
    u=(2*upper)/sf;
    [b,a]= cheby1(N,R,[l u],'stop');
case 'blah' 
    operation='Bandpassed';
    lower=varargin{1}(1);
    upper=varargin{1}(2);
    l=(2*lower)/sf;
    u=(2*upper)/sf;
    [b,a]=cheby1(N,R,[l u]);
end
y=filtfilt(b,a,x);
disp(operation)
