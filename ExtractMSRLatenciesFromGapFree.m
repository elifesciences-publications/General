
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

