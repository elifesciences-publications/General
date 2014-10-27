
%% Creating variables

t = 0:0.001:1;
y = sin(2*pi*t*5);

%% Plotting on CPU
tic;
plot(t,y)
close
cpuTime = toc;

%% Plotting on GPU

tg = gpuArray(t);
yg = sin(2*pi*tg*5);
tic;
plot(tg,yg)
close
gpuTime = toc;

speedup = cpuTime/gpuTime