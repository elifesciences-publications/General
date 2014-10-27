function [varargout] = stft( varargin )
% STFT - Short Time Fourier Transform of a Signal
%   [S,F,T,P] = stft(X,win,foverlap,F,Fs)
% Outputs: S = Spectrogram, F = Frequencies at which Spectogram is computed
%          T = Time Vector, P = Periodogram

% Inputs: X = Timeseries Signal         
%         win = Time window within which Fourier Transform is performed.
%         win can be a scalar in which case it specifies the window
%         length in units of time. In such a case, the window function used by default is
%         a Hamming window. If 'win' is a vector it specifies the windowing function

%         foverlap = Fraction of overlap between adjacent short-time
%         windows. For example, foverlap = 0.9 indicates 90% overlap
%         between adjacent windows

%         F = Frequencies at which to compute the spectrogram. Does this
%         using the Goertzel algorithm. See 'spectrogram.m' for additional
%         details.

%         Fs = Sampling Frequency

%         If win = [], then the program automatically computes the win
%         length by finding the dominant frequency in the entirety of the
%         signal using FFT. 
% Author: AP 07-Apr-2014
X = varargin{1};
win = varargin{2};
foverlap = varargin{3};
F = varargin{4};
Fs = varargin{5};
if isempty(win)
[fourierPower,fourierFreq] = my_fft(X,1/Fs);
fpt = find(fourierFreq>= 0.05,1,'first');
fourierFreq = fourierFreq(fpt:end); %%% Ignoring very slow frequencies
fourierPower = fourierPower(fpt:end); 
fourierPower = zscore(fourierPower); %%% Amplitude normalization
[maxtab,mintab] = peakdet(fourierPower,3);
peakTimes = maxtab(:,1);
peakValues = maxtab(:,2);
fpt = find(peakValues(:) == max(peakValues(:)),1,'first');
dominantFreqIndex = peakTimes(fpt);
dominantFreq = fourierFreq(dominantFreqIndex);
win = 5*ceil(1/dominantFreq);
win = round(win/(1/Fs));
end
foverlap = round(foverlap*win);
[S,F,T,P] = spectrogram(X(:),win,foverlap,F(:),Fs);
sigmaX = std(X);
P = P./sigmaX;
varargout{1} = S;
varargout{2} = F;
varargout{3} = T;
varargout{4} = P;
end

