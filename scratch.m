% stimConditions = unique(amplitudes.right);
% for jj = 1:numel(stimConditions)
%     indices = find(amplitudes.right == stimConditions(jj));
%     startTimes = onsets.right(indices)-0.5;
%     endTimes = startTimes + traceLength;
%     startPts = round(startTimes/samplingInt);
%     endPts = round(endTimes/samplingInt);
%     for kk = 1:numel(startPts)
%         traces.left{jj}(kk,:) = signal.left(startPts(kk):endPts(kk));
%     end
% end
% episodicTime = ([startPts(kk):endPts(kk)]-startPts(kk))*samplingInt;
% episodicTime = episodicTime-0.5; % So that stim onset corresponds to time = 0

clear all, close all
mfload

out = concatenatesignals();
conTime = out(:,1);
conSignal = [out(:,2) out(:,5)];
kernel = hamming(round(1e-3/samplingInts(1))); 
kernel = kernel/sum(kernel);
blah = conv2(conSignal,kernel(:),'same');

gap2sweep

mOnsets = mOnsets-5;
mOnsets(mOnsets(:,2)<3,:)=[];
mOnsets(mOnsets(:,1)<4,:)=[];