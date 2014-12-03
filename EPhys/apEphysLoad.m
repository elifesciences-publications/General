function data = apEphysLoad(varargin)
% convert takashi/misha's 10chfilt file to nikita's 10ch format
% specify full filename or this will prompt you to pick a file
samplingRate = 6000; %

if nargin == 0
    [namestr, pathstr] = uigetfile('*.10chFlt');
    filename = fullfile(pathstr,namestr);
elseif nargin == 1
    filename = varargin{1};
    [pathstr, ~, ~] = fileparts(filename);
end


hA = fopen(filename);
fprintf('\nReading file...\n');
A = fread(hA,[10, inf],'single');
% fprintf('\nFinished reading file\n');
fclose(hA);

data.t=(0:length(A(1,:))-1)/samplingRate; %assuming sampling rate 6 KHz
data.ch1 = A(1,:);
data.ch2 = A(2,:);
data.camTrigger = A(3,:);
data.stim1 = A(6,:);
data.stim2 = A(5,:);
% data.epoch = A(7,:); % 1 for gain1 epoch, 2 for gain2 epoch
% data.stimID = A(8,:);
% data.vel = A(9,:);
% data.gain = A(10,:);
% data.patch1 = A(11,:);
% data.patch2 = A(12,:);
%data.patch3 = A(13,:);
%data.patch4 = A(14,:);
data.filename = filename;

fprintf('\nData stored in variable named "data"\n');

