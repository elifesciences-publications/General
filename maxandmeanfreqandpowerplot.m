Wxy_abs = abs(Wxy);
% Axy_abs = angle(Wxy);
maxmat = max(Wxy_abs);
maxmat = repmat(maxmat,size(Wxy,1),1);
Wxy_roi = Wxy_abs;
Wxy_roi(Wxy_roi==0)=-1;
diffmat = Wxy_roi-maxmat;
diffmat(diffmat==0)=1; 
diffmat(diffmat<0)=0;
fmat = repmat(freq(:),1,size(Wxy,2)); 
mfmat = diffmat.*fmat;
mfvec = sum(mfmat);
mfvec(mfvec==0)=0;
figure
title('Max and mean freq over time')
% plot(time_reduced(1:10:end)+firstTime,mfvec(1:10:end),'-k.','markersize',20),box off,
% plot(tempTime(1:10:end),mfvec(1:10:end),'-k.','markersize',20),box off,
ylabel('Freq'),xlabel('Time')
hold on
summat = repmat(sum(Wxy_abs),size(Wxy_abs,1),1);
Wxy_pval = Wxy_abs./summat; 
fmat = repmat(freq(:),1,size(Wxy_abs,2)); 
pfmat = fmat.*Wxy_pval;pfvec = sum(pfmat); 
pfvec(pfvec==0)=nan;
plot(time_reduced(1:10:end)+firstTime,pfvec(1:10:end),'.r-','markersize',20)
%plot(tempTime(1:10:end),pfvec(1:10:end),'.r-','markersize',20)
set(gca,'tickdir','out'),shg


powvec = max(Wxy_abs); powvec = powvec./max(powvec(:));

%  plot(time_reduced(1:5:end)+firstTime,powvec(1:5:end),'ob-','markersize',2)



axy = angle(max(Wxy)); f = find(axy<0); axy(f) = axy(f)+2*pi; 
axy = axy/(1*pi); % Normalize 2*pi to 1;
plot(time_reduced(1:10:end) + firstTime, axy(1:10:end),'g.')

legend('Max freq','Mean freq','Power')
