function data = mkEphysLoad(varargin)
% convert takashi/misha's 10chfilt file to nikita's 10ch format
% specify full filename or this will prompt you to pick a file
if nargin == 0
    [namestr, pathstr] = uigetfile('*.16ch');
    filename = fullfile(pathstr,namestr);
elseif nargin == 1
    filename = varargin{1};
    [pathstr, ~, ~] = fileparts(filename);
end


hA = fopen(filename);
fprintf('\nReading file\n');
A = fread(hA,[16, inf],'single');
fprintf('\nFinished reading file\n');
fclose(hA);

data.t=(1:length(A(1,:)))/6000; %assuming sampling rate 6 KHz
data.ch1 = A(1,:);
data.ch2 = A(2,:);
data.camTrigger = A(3,:);
data.leftStim = A(5,:);
data.rightStim = A(6,:);
data.epoch = A(7,:); % 1 for gain1 epoch, 2 for gain2 epoch
data.stimID = A(8,:);
data.vel = A(9,:);
data.gain = A(10,:);
data.patch1 = A(11,:);
data.patch2 = A(12,:);
data.patch3 = A(13,:);
data.patch4 = A(14,:);
data.filename = filename;
