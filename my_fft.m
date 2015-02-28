
function [y,f]=my_fft(x,samplingInt);
% MY_FFT Computes the fft of a timeseries signal
%   [pow,freq] = my_fft(timeseries,samplingInt); Takes a timeseries
%   signal(or a matrix of timeseries signals) and its sampling interval 
%   as input and outputs the power and corresponding frequency values 
%   obtained after performing a fft.
if size(x,1)< size(x,2)
    x = x';
end
Fs= 1/samplingInt;
h=hamming(length(x));
h = repmat(h(:),[1 size(x,2) size(x,3)]);
x=h.*x; % Time series multiplied by hamming function of equal length,
        % presumably to minimize edge effects.
nfft=2^nextpow2(length(x)); % FFT is faster if length of output vector is an
                            % power of 2.
y=fft(x,nfft)/length(x); % Why normalize???
f=0.5*Fs*linspace(0,1,nfft/2);
y=2*abs(y(1:nfft/2,:,:)); % Why scale with 2 ????

