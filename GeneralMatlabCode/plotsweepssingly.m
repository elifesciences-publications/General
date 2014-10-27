% PLOTSWEEPSSINGLY - Helper m-file for GAP2SWEEP. Takes the data generated
% by gap2sweep and plots a chosen channel sweep-by-sweep.
% plotsweepssingly(channels,sweepTime)
function plotsweepssingly(channels,timeAxis)
%% Adjustable plotting parameters
lw = 2; % linewidth
%% Selecting a channel
prompt={'Select channel to plot'};
name='Plotting as sweeps one by one';
numLines =1;
default ={'1'};
answer=inputdlg(prompt,name,numLines,default);

%% Plotting all sweeps of the channel one-by-one
ch=str2double(answer{1});
figure('Name', ['Channel ' num2str(ch)])

for k=1:size(channels,2)
    r=rand(1,3);
    if k==1
        plot(timeAxis*1000,channels(:,k,ch),'k','linewidth',lw)
        title('Select Y-axis lim');
        [abs,ord]=ginput(2);
        yMin=min(ord);
        yMax=max(ord);
        plot(timeAxis*1000,channels(:,k,ch),'k')
        title('Select the time end point');
        [abs,ord]=ginput(1);
        xMax=max(abs);
    end
    plot(timeAxis*1000,channels(:,k,ch),'color',r,'linewidth',lw)
    xlabel('Time (ms)')
    xlim([-inf xMax])
    ylim([yMin yMax])
    title(['Sweep # ' num2str(k)])
    hold on
    if k==1
        str=num2str(k);
        legend(str)
    elseif k>1 & k<6
        str=[str;num2str(k)];
        tempStr={str};
        legend(tempStr)
    end
    pause
end
