
% Wavelet demo
freqRange = [20 70];
freqScale = 'lin';
sigmaXY = 1;
dt = 1/1000;
t = 0:dt:1;
A = 1; 
% x = A*chirp(t,25,1,55,'q',[],'convex') + rand(size(x));
x = A*(Standardize(1*sin(2*pi*53*t) + 2*sin(2*pi*31*t))-0.5);

% sigmaXY = var(x);
% x = A*sin(2*pi*23*t);


[W,freq] = ComputeXWT(x,x,t,'freqRange',freqRange,'freqScale',freqScale,'sigmaXY',sigmaXY);

figure('Name','W')
ax =[];
ax(1) = subplot(2,1,1);
if strcmpi(freqScale,'log')
    imagesc(t,log2(freq),abs(W))
    yt = get(gca,'ytick');
    yt(mod(yt,1)~=0) = [];
    ytl = 2.^yt;
    box off
    set(gca,'tickdir','out','ydir','normal','ytick',yt,'yticklabel',ytl)
else    
    imagesc(t,freq,abs(W))
    yt = get(gca,'ytick');
    box off
    set(gca,'tickdir','out','ydir','normal','clim',[0 A^2])
end

ax(2) = subplot(2,1,2);
plot(t,x);
box off
linkaxes(ax,'x');
ylim([-inf inf])



