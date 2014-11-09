
%%% samplingInt = ?

% kerLen = 100e-3; % Kernel length in seconds
% kernel = hamming(round(kerLen/samplingInt));
% rss = temp1;
% rss(rss<0) = 0;
% rss = conv2(rss,kernel(:),'same');
% ftp = find(time>=2);
% lpt = find(time>=5);
% shortTime = time(fpt:lpt);
% shortRSS = rss(fpt:lpt,:);
figure
sigNum = 1;
fileNum = 1;
% tr = [2 22];
winLength = 1000e-3; % In seconds
clear tvmf
tvmf = time_varying_meanfreq_f1ch12(fileNum,:);

%     tvmf(tvmf==0) = nan;
%     for kk = 1:length(tvmf);
%         if (kk<11)
%             tvmf(kk) = tvmf(kk);
%         elseif tvmf(kk)~=0
%             tvmf(kk) = tvmf(kk);%   
%         else
%             tvmf(kk) = mean([tvmf(kk-10:kk)]);
%         end
%     end
% fpt = find(time_reduced>= tr(1),1,'first');
% lpt = find(time_reduced>= tr(2),1,'first');
% t = time_reduced(fpt:lpt);
t = time_reduced(:);
s = sigMat(:,fileNum,sigNum);
ss  = abs(s);

tvmf_sub = tvmf(1:100:end);
tvmf_sub(tvmf_sub==0) = nan;
fTime = t(1:100:end);

% s = sigMat(fpt:lpt);
newSI = t(2)-t(1);
% kernel = hamming(round(winLength/newSI));
% kernel = kernel/sum(kernel(:)); % Prob normalization
kernel = ones(1,round(winLength/newSI));
kernel = kernel/length(kernel);
smf = conv2(tvmf(:),kernel(:),'same');
ss = conv2(ss(:),kernel(:),'same');
subplot(2,1,1), plot(t(:),s(:),'k')
hold on
plot(t(:),ss*3,'b','linewidth',2)
axis([-inf inf -inf inf])
ylabel('Amplitude(uV)')
subplot(2,1,2),
plot(t(:),tvmf(:),'k.-')
hold on
plot(t(:),ss*30,'b','linewidth',2)
plot(t(:),smf,'r','linewidth',2)

%% 

% eqtxt = '$$ {1\over n} \Sigma_{file = 1}^{n} |W_{file}(ch1,ch2)|$$';