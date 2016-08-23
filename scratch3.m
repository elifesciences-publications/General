
%%
clear
disp('Finding and opening procData matfile...')
procData = OpenMatFile()
procData.Properties.Writable = true;
tic
disp('Reading relevant data for subsequent midline tracking...')
IM_proc_crop = procData.IM_proc_crop;
fishPos = procData.fishPos;
hOr_crop = procData.hOr_crop;
toc


