
%process_RAW_avi_pclamp_V6_01_23_2007

%THIS PROGRAM FIRST LOADS MULTICHANNEL ELECTRICAL DATA (EITHER pCLAMP .atf
%OR MATLAB. IF .atf IT SAVES THE DATA AS A MATLAB FILE. IT THEN REMOVES THE
%ARTEFACTS AND SAVES THE DE-ARTEFACTED CHANNEL.


%       import_atf  written by
%     © 2002 - Michele Giugliano, PhD (http://www.giugliano.info) (Bern, Friday March 8th, 2002 - 20:09)
%                               (bug-reports to michele@giugliano.info)

%% INITITALIZE

close all; clear all; clc
process_log = strvcat(['LOAD ELECTRICAL DATA', ' Date: ' date], ' ');

%% SET DIRECTORIES, FILTER SETTINGS, FRAME DURATION....
% prompt = {'Enter electrical data directory:','Enter AVI directory:', ...
%     'Enter Display Limits Directory', 'Enter Frame Duration', 'Enter Median Filter Size' };
% dlg_title = 'SET VALUES';
% num_lines = 1;
% def = {'c:/data/','c:/data/','c:/data/', '100', '3'};
%
% options.Resize='on';
% options.WindowStyle='normal';
% options.Interpreter='tex';
% answer = inputdlg(prompt,dlg_title,num_lines,def,options);
%
% dir_elec = answer{1};
% dir_avi  = answer{2};
% dir_elec = answer{3};
% frame_dur = str2num(answer{4});
% med_filt = str2num(answer{5});



dir_elec =          'C:\DATA\Motoneuron Project\2007 02 20  physiol';
dir_avi  =          'C:\DATA\Motoneuron Project\2007 02 20 optical\20 feb 07 optical.mdb';
dir_image_gains =   'C:\DATA\Motoneuron Project\2007 02 20 optical\20 feb 07 optical.mdb';
dir_roi =           'C:\DATA\Motoneuron Project\2007 02 20 optical\20 feb 07 optical.mdb';
dir_display_gains = 'C:\DATA\Motoneuron Project\2007 02 20 optical\20 feb 07 optical.mdb';
dir_save_lims     = 'C:\DATA\Motoneuron Project\2007 02 20 optical\20 feb 07 optical.mdb';
frame_dur = 100;
med_filt = 3;




%% LOAD ELECTRICAL DATA

str = strvcat('LOAD ATF', '------------------', 'LOAD MATLAB', '-------------------------------------', 'LOAD ABF',...
    '-------------------------', 'LOAD DE-ARTEFACTED MATLAB');
[s_ld,v] = listdlg('PromptString','LOAD ELECTRICAL DATA', 'SelectionMode','single','ListString',str,'listsize', [220 110]); %w h

if s_ld==1 %LOAD Pclamp ATF file
    cd(dir_elec);

    [filename_pclamp,dir_elec] = uigetfile('*.atf','Load the PClamp ATF File'); cd(dir_elec); open(filename_pclamp);
    process_log=strvcat(process_log, ' ', 'Load the ATF File: ', dir_elec, ['Loaded Filename: ' filename_pclamp]);
    [header, labels, comments, data] = import_atf(filename_pclamp);
    timebase=data(:,1);     %timebase is in seconds
    data(:,1)=[];  %delete time channel leaving only data channels
    interval = timebase(2)-timebase(1);
    interval = interval*1000; %because in the matlab data files the interval has been multiplied by 1000
    %
    % function [y,t] = plot_minmax(x,interval,jump)   %y is the reduced x data; t is the new timebase
    % %x is the input data file, jump is the block of data to be minimaxed,
    % %interval is the interval between the original data points
    % [y,t] = plot_minmax(data(:,1), interval, 500);
    % plot(t,y);

    %save matlab file

    filename_pclamp=strrep(filename_pclamp, '.atf', '_PCLAMP.mat');

    save(filename_pclamp, 'data', 'timebase', 'labels', 'header', 'comments');
    process_log = strvcat(process_log, ['Saved File: ' filename_pclamp]);


elseif s_ld ==3  %LOAD MATLAB FILE

    cd(dir_elec);
    [filename_pclamp,dir_elec] = uigetfile('*.mat','Load the PClamp Matlab File'); cd(dir_elec); load(filename_pclamp);
    % process_log=strvcat([process_log], ' ', 'Load the PClamp Matlab file File: ', [dir_pclamp], ['Loaded Filename: ' filename]);

    interval=(timebase(2)-timebase(1))*1000;

    num_channels=size(data);
    num_channels=num_channels(2);




    %% REORDER CHANNELS

    % data_size = size(data);
    % data_temp = zeros(data_size(1), data_size(2));
    % data_temp(:,1) = data(:,4);  %L2 RIGHT
    % data_temp(:,2) = data(:,3);  %L2 LEFT
    % data_temp(:,3) = data(:,5);  %S2 RIGHT
    % data_temp(:,4) = data(:,1);  %S2 LEFT
    % data_temp(:,5) = data(:,2);  %VF LEFT L6/S1
    % data_temp(:,6) = data(:,6);  %FRAMES
    % clear data
    % data = data_temp; clear data_temp


    process_log=strvcat(['Remove Artefacts', ' Date: ' date], ' ');

    %--------------------------------------------------
    %EXTRACT CHANNEL NAMES INTO STRUCTURE CHANNEL.NAMES
    %--------------------------------------------------
    locate_signals=strfind(header,'"Signals="');
    signal_names=header(locate_signals+10:end);
    locate_quotes=strfind(signal_names,'"');
    num_channels=length(locate_quotes)/2;

    count=0;
    for i=1:2:num_channels*2;
        count=count+1;
        paired_quotes(count,:)=[locate_quotes(i) locate_quotes(i+1)];
        start_channel_name_index(count) = paired_quotes(count,1)+1;
        stop_channel_name_index(count)  = paired_quotes(count,2)-1;
    end

    for i=1:num_channels
        channel(i).names = signal_names(start_channel_name_index(i):stop_channel_name_index(i));
    end


    %% ENTER CHANNEL NAMES

    channel(1).names = 'L6R';
    channel(2).names = 'L5R';
    channel(3).names = 'L4R';
    channel(4).names = 'VLR R';
    channel(5).names = 'stim';
    channel(6).names = 'Frames';

    %% REORDER CHANNEL NAMES


    % channel_temp(1).names  = channel(4).names ;  %L2 RIGHT
    % channel_temp(2).names  = channel(3).names ;  %L2 LEFT
    % channel_temp(3).names  = channel(5).names ;  %S2 RIGHT
    % channel_temp(4).names  = channel(1).names ;  %S2 LEFT
    % channel_temp(5).names  = channel(2).names ;  %VF LEFT L6/S1
    % channel_temp(6).names  =  channel(6).names;  %FRAMES

    % clear channel
    %
    % channel = channel_temp; clear channel_temp

elseif s_ld == 5 %load ABF

cd(dir_elec)

[abf_filename,dir_abf] = uigetfile('*.abf','Load the ABF File');
cd(dir_abf);
[data,interval,names,nSweeps] = abfload_NIH(abf_filename); %interval is is usec

process_log = strvcat(process_log, ' ', 'Load the ABF File: ', dir_abf, ['Loaded Filename: ' abf_filename]);

[data_length, num_sweeps_x_chnnels] = size(data);

interval = interval/1000;  %interval in mseconds

timebase = linspace(0,data_length*(interval/1000),data_length); %timebase in seconds
[num_names, name_length] = size(names);

for i=1:num_names
    channel(i).names = names(i,1:name_length);
end

filename_pclamp = abf_filename;
num_channels = num_names;
    
 
    
%% PLOT INDIVIDUAL CHANNELS


    set(figure(1), 'color', 'white', 'doublebuffer', 'on', 'position',  [100 100 1.5*560 1.5*420]);

    for i=1:num_channels
        subplot(num_channels, 1, i)   % subplot(row, column, nth plot)
        plot(timebase, data(:,i))
        text(.01, .9, [num2str(i) ' : ' channel(i).names], 'units', 'normalized');
    end

    %This section is necessary because sometimes there are extra unnecessary chanels.
    %--------------------------------------------------------------------------

    num_channels = inputdlg('SELECT NUMBER OF CHANNELS: 0 if NONE','CHANNELS',1, {num2str(num_channels)});
    num_channels= str2num(num_channels{1});

    data = data(:,1:num_channels);

    %% SAVE INTRACELLULAR CHANNEL FOR LATER USE
    str = strvcat('No Intracellular Channel', '------------------', 'Intracellular Channel');
    [s_ic,v] = listdlg('PromptString','IDENTIFY INTRACELLULAR CHANNEL', 'SelectionMode','single','ListString',str,'listsize', [220 60]);

    if s_ic == 3

        ic_chan = inputdlg('SELECT INTRACELLULAR CHANNEL','INTRACELLULAR CHANNEL',1, {'1'});
        ic_chan=str2num(ic_chan{1});

        ic_data=data(:,ic_chan);
    else
    end



    %% DIFFERENTIATE DATA FOR IDENTIFYING ARTEFACTS

    data_diff=diff(data);
    data_diff=vertcat(data_diff, data_diff(end,:)); %because diff reduced # data points by one

    %----------------------------------------------------------------------------------------------------------------------------------------------
    %----------------------------------------------------------------------------------------------------------------------------------------------
    %****************
    %REMOVE ARTEFACTS
    %****************

    chan=1:num_channels-1;

    chan = inputdlg('SELECT CHANNELS FOR ARTEFACT REMOVAL: 0 if NONE','CHANNELS',1, {num2str(chan)});
    chan = str2num(chan{1});

% save original electrical data - only dearifacted channels
data_orig = data(:,chan);

    if chan~=0

        num_art_channels = length(chan);
        data_art = data_diff(:,chan);

        %enter threshold
        thresh=.4;
        select=1;

        thresh = inputdlg('Enter THRESHOLD','Threshold',1, {num2str(thresh)});
        thresh=str2num(thresh{1});

        for i=1:num_art_channels, threshold(i) = thresh; end

        while select==1

            [r_chan,col_chan]=size(data_art);

            %calculate mean of initial part of record
            mean_control=mean(data_art(1:200,:));

            max_data = max(data_art);    min_data = min(data_art);

            con_to_max = abs( max_data - mean_control );
            con_to_min = abs( mean_control - min_data );


            %% IDENTIFY ARTEFACTS

            for i=1:num_art_channels

                if con_to_max(i) > con_to_min(i)

                    max_artefact_indicies(i).input = find( data_art(:,i) > threshold(i)* max_data(i) );
                    up(i)=1; %flag to indicate threshold positive
                elseif   con_to_max(i) < con_to_min(i)

                    max_artefact_indicies(i).input = find( data_art(:,i) < threshold(i)* min_data(i) );
                    up(i)=0; %flag to indicate threshold negative
                end
            end

            %               TEST------------------------------------------------------------------------------------------------------------------TEST

            %                     set(figure(2), 'color', 'white', 'doublebuffer', 'on', 'position',  [200 200 1.75*560  1.75*420]);
            %                     for i=1:num_art_channels
            %                     subplot(num_art_channels, 1, i)   % subplot(row, column, nth plot)
            %                     plot(1:length(timebase), data_art(:,i) )
            %                     hold on
            %                     plot(max_artefact_indicies(i).input, data_art( max_artefact_indicies(i).input,i), 'rs', 'markersize', 3)
            %                     x_axis=xlim; y_axis=ylim;
            %                     line([x_axis(1) x_axis(2)], [threshold(i)* min_data(i) threshold(i)* min_data(i)],  'linewidth', 0.5, 'color', 'red');
            %                     line([x_axis(1) x_axis(2)], [threshold(i)* max_data(i) threshold(i)* max_data(i)],  'linewidth', 0.5, 'color', 'red');
            %                     text(.01, .9, [num2str(i) ' : ' channel(i).names], 'units', 'normalized');
            %                     end

            %               TEST------------------------------------------------------------------------------------------------------------------TEST


            %FIND SINGLE ARTEFACT INDICIES
            for i=1:num_art_channels;
                mai_diff(i).input = diff( max_artefact_indicies(i).input);
                single_find(i).input = find(mai_diff(i).input >10);
                single_art_indicies(i).input = vertcat(max_artefact_indicies(i).input(single_find(i).input,:), max_artefact_indicies(i).input(end));
                %need the last index because single indicies misses one index
            end

            for i=1:num_art_channels;
                num_artefacts(i)=length(single_art_indicies(i).input);
            end


            %% PLOT SINGLE ARTEFACT INDICIES

            set(figure(3), 'color', 'white', 'doublebuffer', 'on', 'position',  [200 200 1.75*560  1.75*420]);
            for i=1:num_art_channels
                subplot(num_channels, 1, i)   % subplot(row, column, nth plot)
                plot(timebase, data_art(:,i) )
                hold on
                plot(timebase(    single_art_indicies(i).input ), data_art(  single_art_indicies(i).input,i), 'rs', 'markersize', 3)
                x_axis=xlim; y_axis=ylim;
                if i~=num_art_channels, axis off, else axis on, end
                if up(i)==1
                    line([x_axis(1) x_axis(2)], [threshold(i)* max_data(i) threshold(i)* max_data(i)],  'linewidth', 0.5, 'color', 'red');
                else
                    line([x_axis(1) x_axis(2)], [threshold(i)* min_data(i) threshold(i)* min_data(i)],  'linewidth', 0.5, 'color', 'red');
                end
                %         text(.01, .9, ['THRESHOLD: ' num2str(threshold(i))  '  # ARTEFACTS = ' num2str( num_artefacts(i)) ], 'units', 'normalized');

                title(['THRESHOLD: ' num2str(threshold(i))  '  # ARTEFACTS = ' num2str( num_artefacts(i)) ], 'units', 'normalized');
            end %end for num_art_channels
            %---------------------------------------------------------------------------------------------------------------------------------


            str=strvcat( 'Do NOT Change Threshold', '------------',  'Change Threshold');
            [s_ch_thresh,v] = listdlg('PromptString','Truncate', 'SelectionMode','single','ListString',str,'listsize', [180 50]); %w h

            if s_ch_thresh==3

                thresh_chan = inputdlg('SELECT CHANNELS TO CHANGE THRESHOLD','Threshold',1, {num2str(chan)});
                thresh_chan = str2num(thresh_chan{1});

                thresh_find = find(chan  == thresh_chan);


                for i = thresh_find
                    prompt = {'CHANGE THRESHOLD yes=1, no=0', ['ENTER THRESHOLD CH# ' num2str(i)] };
                    dlg_title = 'THRESHOLD';
                    num_lines = 1;
                    def = {'1', num2str(threshold(i))};
                    answer = inputdlg(prompt,dlg_title,num_lines,def);

                    select=str2num(answer{1});
                    threshold(i)=str2num(answer{2});
                end
            else select=0;
            end %end for if s_ch_tresh~=1

        end %for while select=1
        close(3)



        %% EXTEND ARTEFACT INDICIES TO ELIMINATE ARTEFACTS

        extend=50;s_extend=1;

        while s_extend==1
            extend = inputdlg('Enter Right Extension','Extender: Entry is Default',1, {num2str(extend)});
            extend=str2num(extend{1});

            if exist('artefact_indicies_extended')==1
                clear artefact_indicies_extended
            else
            end

            %EXTEND ARTEFACT INDICIES AROUND SINGLE MAX
            for i=1:num_art_channels;
                for j=1: num_artefacts(i)
                    artefact_indicies_extended(i).input(:,j)=  single_art_indicies(i).input(j)-15:single_art_indicies(i).input(j)+extend;
                end
            end


            %TEST------------------------------------------------------------------------------------------------------------------TEST

            % set(figure(4), 'color', 'white', 'doublebuffer', 'on', 'position',  [200 200 1.75*560  1.75*420]);
            % for i=1:num_channels
            %     for j=1: num_artefacts(i)
            %         subplot(num_channels, 1, i)   % subplot(row, column, nth plot)
            %         plot(timebase, data_art(:,i) )
            %         hold on
            %         plot(  timebase( artefact_indicies_extended(i).input(:,j )),    data_art( artefact_indicies_extended(i).input(:,j), i), 'rs', 'markersize', 3)
            %         x_axis=xlim; y_axis=ylim;
            %         line([x_axis(1) x_axis(2)], [thresh* min_data(i) thresh* min_data(i)],  'linewidth', 0.5, 'color', 'red');
            %         line([x_axis(1) x_axis(2)], [thresh* max_data(i) thresh* max_data(i)],  'linewidth', 0.5, 'color', 'red');
            %         text(.01, .9, [num2str(i) ' : ' channel(i).names], 'units', 'normalized');
            %     end
            % end

            %TEST------------------------------------------------------------------------------------------------------------------TEST

            %SET ARTEFACT TO ADJACENT MEAN DATA
            count=0;
            for i=chan;
                count=count+1;
                for j=1:num_artefacts(1)
                    data(artefact_indicies_extended(count).input(:,j),i)= mean(data(artefact_indicies_extended(count).input(1:6,j),i));
                end
            end

            %CALCULATE THE LOCATION OF THE STIMULUS TRAIN BAR

            min_data_last=min(data(750:end,end));
            max_data_last=max(data(750:end,end));
            diff_last=max_data_last-min_data_last;

            if min_data_last < 0
                y_bar=min_data_last-(0.1*diff_last);
            else
                y_bar=min_data_last-(0.1*diff_last);
            end
            y_bar_start=timebase(single_art_indicies(1).input(1));
            y_bar_end=timebase(single_art_indicies(1).input(end));


            %% PLOT DE-ARTEFACTED CHANNELS
            if s_ic==1   %NO IC CHANNEL

                close(1);
                set(figure(1), 'color', 'white', 'doublebuffer', 'on', 'position',  [50 100 560  420]);
                for i=1:num_channels
                    subplot(num_channels, 1, i)   % subplot(row, column, nth plot)
                    plot(timebase(750:end), data(750:end,i) )  %750 to end because the filter below causes an initial artefact
                    axis tight
                    %                 axis off
                    if i==num_channels
                        line([y_bar_start y_bar_end], [y_bar y_bar ],  'linewidth', 3, 'color', 'black'); %plot stimuli
                    end
                    text(.01, .9, [num2str(i) ' : ' channel(i).names], 'units', 'normalized');
                end


            elseif s_ic ==3 %IC CHANNEL
                str=strvcat('Plot All Channels','-------------', 'Plot Unprocessed IC Channel','-------------','Plot Both IC Channels' );
                [s_pic,v] = listdlg('PromptString','Change Settings', 'SelectionMode','single','ListString',str,'listsize', [200 90]); %w h

                if s_pic==1

                    %***************************
                    %PLOT DE-ARTEFACTED CHANNELS
                    %***************************
                    close(1);
                    set(figure(1), 'color', 'white', 'doublebuffer', 'on', 'position',  [50 100 560  420]);
                    for i=1:num_channels
                        if i==1
                            subplot(num_channels, 1, i)   % subplot(row, column, nth plot)
                            plot(timebase(750:end), data(750:end,i) )  %750 to end because the filter below causes an initial artefact
                            axis tight
                            title(filename_pclamp);
                            draw_cal_mv_sec
                            axis off
                        else
                            subplot(num_channels, 1, i)   % subplot(row, column, nth plot)
                            plot(timebase(750:end), data(750:end,i) )  %750 to end because the filter below causes an initial artefact
                            axis tight
                            axis off
                            if i==num_channels
                                line([y_bar_start y_bar_end], [y_bar y_bar ],  'linewidth', 3, 'color', 'black'); %plot stimuli
                            end
                            text(.01, .9, [num2str(i) ' : ' channel(i).names], 'units', 'normalized');
                        end
                    end

                elseif s_pic==3

                    %**********************************************
                    %PLOT DE-ARTEFACTED CHANNELS AND UNPROCESSED IC
                    %***********************************************

                    max_ic=max(data(:,ic_chan)); min_ic=min(data(:,ic_chan));

                    temp_data=data; temp_data(:,ic_chan)=ic_data; %ADD ORIGINAL IC CHANNEL TO DATA CHANNELS
                    close(1);
                    set(figure(1), 'color', 'white', 'doublebuffer', 'on', 'position',  [50 100 560  420]);
                    for i=1:num_channels;
                        if i==1
                            subplot(num_channels, 1, i)   % subplot(row, column, nth plot)
                            plot(timebase(750:end), temp_data(750:end,i) )  %750 to end because the filter below causes an initial artefact
                            axis([timebase(750) timebase(end) min_ic max_ic]);
                            title(filename);
                        else
                            subplot(num_channels, 1, i)   % subplot(row, column, nth plot)
                            plot(timebase(750:end), temp_data(750:end,i) )  %750 to end because the filter below causes an initial artefact
                            axis tight

                            text(.01, .9, [num2str(i) ' : ' channel(i).names], 'units', 'normalized');
                            if i==num_channels
                                line([y_bar_start y_bar_end], [y_bar y_bar ],  'linewidth', 3, 'color', 'black'); %plot stimuli
                            end
                        end %for if i==1
                    end

                elseif s_pic==5

                    %***********************************************
                    %PLOT DE-ARTEFACTED CHANNELS AND BOTH IC CHANNELS
                    %************************************************

                    max_ic=max(data(:,ic_chan)); min_ic=min(data(:,ic_chan));
                    temp_data=zeros(length(timebase),num_channels+1);
                    temp_data(:,2:num_channels+1)=data; temp_data(:,1)=ic_data; %ADD DE-ARTEFACTED IC CHANNEL TO ALL DE-ARTEFACTED CHANNELS
                    close(1);
                    set(figure(1), 'color', 'white', 'doublebuffer', 'on', 'position',  [50 100 560  420]);

                    for i=1:num_channels+1;

                        if i==1
                            subplot(num_channels+1, 1, i)   % subplot(row, column, nth plot)
                            plot(timebase(750:end), temp_data(750:end,i) )  %750 to end because the filter below causes an initial artefact
                            axis([timebase(750) timebase(end) min_ic max_ic]);
                            title(filename);
                            draw_cal_mv_sec
                            axis off
                        elseif i==2
                            subplot(num_channels+1, 1, i)   % subplot(row, column, nth plot)
                            plot(timebase(750:end), temp_data(750:end,i) )  %750 to end because the filter below causes an initial artefact
                            axis([timebase(750) timebase(end) min_ic max_ic]);
                            %                 title(filename);
                            %                 draw_cal_mv_sec
                            axis off

                        elseif i>2
                            subplot(num_channels+1, 1, i)   % subplot(row, column, nth plot)
                            plot(timebase(750:end), temp_data(750:end,i) )  %750 to end because the filter below causes an initial artefact
                            axis tight
                            axis off
                            if i>=2
                                text(.01, .9, [num2str(i-1) ' : ' channel(i-1).names], 'units', 'normalized');
                            end
                            if i==num_channels+1
                                line([y_bar_start y_bar_end], [y_bar y_bar ],  'linewidth', 3, 'color', 'black'); %plot stimuli
                            end
                        end
                    end


                end %for 'Plot DeArtifacted IC Channel','-------------', 'Plot Unprocessed IC Channel','-------------','Plot Both IC Channels' );
            end %if s_ic==1   %NO IC CHANNEL elseif  s_ic==3 IC CHANNEL

            str=strvcat('Change Artefact Removal Settings','-------------', 'FINISHED');
            [s_extend,v] = listdlg('PromptString','Change Settings', 'SelectionMode','single','ListString',str,'listsize', [200 45]); %w h

        end  %end for while s_extend==1

    else
    end %for if chan~=0

% 
%     %% SAVE DE-ARTEFACTED DATA
%     filename = filename_pclamp;
%     cd(dir_elec);
%     if chan~= 0
%         filename = strrep(filename, '_PCLAMP.mat', '_Processed_Data.mat');
%         if s_ld ~= 5
%         if exist('temp_data')==0
%             save(filename, 'data',  'timebase', 'num_channels', 'channel', 'labels', 'header', 'comments', 'single_art_indicies', 'process_log');
%         else
%             save(filename, 'data', 'timebase', 'temp_data','num_channels', 'channel', 'labels', 'header', 'comments', 'single_art_indicies', 'process_log'  );
%         end
%         else
%            save(filename, 'data', 'timebase','num_channels', 'channel', 'single_art_indicies', 'process_log' ); 
%         end
%     end

%% HIGH PASS FILTER NEURO DATA
    %
    str=strvcat('High Pass Filter Neuro Data 50Hz', '-----------------------------', 'Do NOT Filter Neuro Data');
    [s_filt,v_filt] = listdlg('PromptString','FILTER DATA', 'SelectionMode','single','ListString',str,'listsize', [190 50]); %w h

    if s_filt == 1
        filt_chan = inputdlg('SELECT CHANNELS TO FILTER','HIGH PASS FILTER',1, {num2str(chan)});
        filt_chan = str2num(filt_chan{1});

        data(:,filt_chan) = filter(Hi_Pass_Neuro_099_20_50_A20,data(:,filt_chan)); %Don't filter frame channel which is assumwed to be last
    else
    end


    close(1);
    set(figure(1), 'color', 'white', 'doublebuffer', 'on', 'position',  [50 100 560  420]);
    for i=1:num_channels
        subplot(num_channels, 1, i)   % subplot(row, column, nth plot)
        plot(timebase, data(:,i))   %750 to end because the filter below causes an initial artefact
        axis tight
        %                 axis off
        if i==num_channels

            if exist('y_bar_start') == 0
                y_bar_start=timebase(single_art_indicies(chan(1)).input(1));
                y_bar_end=timebase(single_art_indicies(chan(1)).input(end));
            end
            line([y_bar_start y_bar_end], [y_bar y_bar ],  'linewidth', 3, 'color', 'black'); %plot stimuli
        end
        text(.01, .9, [num2str(i) ' : ' channel(i).names], 'units', 'normalized');
    end


elseif s_ld == 7  %load processed data

    cd(dir_elec);
    [filename_pclamp,dir_elec] = uigetfile('*.mat','Load the De-Artefacted Matlab File'); cd(dir_elec); load(filename_pclamp);
    % process_log=strvcat([process_log], ' ', 'Load the PClamp Matlab file File: ', [dir_pclamp], ['Loaded Filename: ' filename]);

    interval=(timebase(2)-timebase(1))*1000;

    num_channels=size(data);
    num_channels=num_channels(2);





end %end for 'lOAD ATF', '------------------', 'LOAD MATLAB'

%----------------------
% INTEGRATE NEURO DATA
%---------------------
%
% int_time = inputdlg('Enter integrate time in ms','Integrate',1, {'100'});
% int_time=str2num(int_time{1});
%
% int_index=round(int_time/interval);
%
% data_rect=abs(data_high); %rectify filtered data
% data_int = zeros(size(data_high));
%
% for i=1:num_channels
%     [datarows(i) datacols(i)]=size(data_int(:,i));
% end
% %integrate
% for j=1:int_index:datarows(1)-int_index
%     data_int(j,:)=sum(data_rect(j:j+int_index,:));
%     int_temp = repmat(data_int(j,:),int_index,1);
%     data_int(j:(j+int_index-1),:)= int_temp;
% end


%plot integrated data
% set(figure(3), 'color', 'white', 'doublebuffer', 'on', 'position', [50 550 560 420]); %750 to end because the filter below causes an initial artefact
%
%
% min_data_last=min(data_int(750:end,end));
% if min_data_last < 0
%     y_bar=min_data_last+(0.1*min_data_last);
% else
%     y_bar=min_data_last-(0.1*min_data_last);
% end
%
%
% for i=1:num_channels
%     subplot(num_channels, 1, i)   % subplot(row, column, nth plot)
%     plot(timebase(750:end), data_int(750:end,i))
%     text(.01, .9, channel(i).names, 'units', 'normalized');
%     if i==num_channels & chan~=0
%         line([y_bar_start y_bar_end], [y_bar y_bar ],  'linewidth', 3, 'color', 'black'); %plot stimuli
%     end
%     axis tight
% end



%% LOAD AVI FILE

close all

cd(dir_avi);

[filename,dir_avi] = uigetfile('*.avi','Load the AVI File'); cd(dir_avi);
filename=strrep(filename, '.avi', '');
filename_avi=filename;
process_log=strvcat(process_log, ' ', 'Load the AVI File: ', dir_avi, ['Filename: ' filename]);

str=strvcat('Calcium Green / Fluo / Ca Orange ','-----------------', 'Inverse Pericam / Fura');
[s_dye,v] = listdlg('PromptString','Select Calcium Dye', 'SelectionMode','single','ListString',str,'listsize', [200 55]); %w h

% frame_dur = inputdlg('Enter Duration of a Single Frame in ms','Frame duration',1, { '242' }, 'on' );
% frame_dur = str2num(frame_dur{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.

frame_rate = round(1000/frame_dur);


%--------------
%LOAD COLORMAP
%--------------

cd('C:\Program Files\Matlab\PROGRAMS\image_processing\colormaps');
load ca_map; load gray_256

%----------------------
%READ AVI DATA INTO MOV
%----------------------

cd(dir_avi)
mov = aviread(filename);  %reads avi file
fileinfo = aviinfo(filename); %extracts information from file
num_frames = fileinfo.NumFrames;  %extracts number of frames in avi

mov_height=fileinfo.Height;
mov_width=fileinfo.Width;
mov_aspect=mov_height/mov_width;


%----------------------
%CHANGE MOVIE COLOR MAP
%----------------------
for i=1:num_frames
    mov(i).colormap=ca_map;  %NOTE ca_map IS THE SAME AS THE JET COLORMAP WITH WHITE AND BLACK AT MAX AND MIN
end
% movie(mov)
process_log=strvcat(process_log, 'Change movie colormap to ca_map');

%% PROCESS VIDEO

%GENERATE CONTROL AVERAGE  (ASSUMES FIRST 10 FRAMES ARE CONTROL)

con_frames=1:10;
if length(size(mov(1).cdata))==2
    for i=con_frames
        control_frames(:,:,i)=mov(i).cdata;
    end
elseif length(size(mov(i).cdata))==3

    for i=con_frames
        control_frames(:,:,:,i)=mov(i).cdata;
    end
end

if length(size(mov(1).cdata))==2
    control_average=mean(control_frames, 3);
elseif length(size(mov(1).cdata))==3
    control_average=mean(control_frames, 4);
end

control_average = uint8(control_average);
process_log=strvcat(process_log, ['Calculate Control average', '# of Frames = ', num2str(con_frames)]);


%-------------------------
%GENERATE DIFFERENCE MOVIE
%-------------------------

if s_dye==1

    for i=1:num_frames
        mov_diff(i).cdata= imsubtract(mov(i).cdata,control_average);
        mov_diff(i).colormap=mov(i).colormap;
    end

elseif s_dye==3

    %     white_frame(1:mov_height, 1:mov_width)=255;
    %     white_frame=uint8(white_frame);

    %     inv_control_average=imsubtract(white_frame,control_average);
    inv_control_average=imcomplement(control_average);
    for i=1:num_frames
        %         inv_mov(i).cdata=imsubtract(white_frame,mov(i).cdata);
        inv_mov(i).cdata=imcomplement(mov(i).cdata);
        mov_diff(i).cdata= imsubtract( inv_mov(i).cdata , inv_control_average );
        mov_diff(i).colormap=mov(i).colormap;
    end
end % for  if s_dye==1

process_log=strvcat(process_log, 'Calculate Difference Image Movie');



%---------------------------------------------------------------
%FIND MAXIMUM FOR EACH FRAME OF MEDIAN FILTERED DIFFERENCE MOVIE
%---------------------------------------------------------------
%compute median filter size=3
for i=num_frames:-1:1
    mov_med_filt(i).cdata= medfilt2(mov_diff(i).cdata, [3 3]);
    mov_med_filt(i).colormap=mov(i).colormap;
end

for i=1:num_frames
    max_movie(i)=max(mov_med_filt(i).cdata(:));
end
clear mov_med_filt;
%-----------------------------------------------------------------------------------------------------
%IDENTIFY INDICIES OF THE MAXIMUM FRAMES - max_movie_index contains the indicies of the maximum frames
%-----------------------------------------------------------------------------------------------------

max_movie_index=find(max_movie==max(max_movie));
process_log=strvcat(process_log, ['Frame(s) Containing Peak Signal = ', num2str(max_movie_index)]);

if length(max_movie_index) > 1
    max_movie_index=max_movie_index(end);
end

%---------------------------------------------------------------
%AVERAGE AROUND MAXIMUM FRAMES OF DIFFERENCE IMAGE(+/- 1 FRAMES)
%---------------------------------------------------------------
count=0;

if max_movie_index~=num_frames  %this is necessary if the maximum frame is the last in the movie

    if length(size(mov(1).cdata))==2
        for i=max_movie_index(1)-1:max_movie_index(1)+1
            count=count+1;
            peak_frames(:,:,count)=mov_diff(i).cdata;
        end
    elseif length(size(mov(i).cdata))==3

        for i=max_movie_index(1)-1:max_movie_index(1)+1
            count=count+1;
            peak_frames(:,:,:,count)=mov_diff(i).cdata;
        end
    end

    if length(size(mov(1).cdata))==2
        peak_average=mean(peak_frames, 3);
    elseif length(size(mov(1).cdata))==3
        peak_average=mean(peak_frames, 4);
    end

    peak_average = uint8(peak_average);

    max_peak_scale=max(peak_average(:));
    min_peak_scale=min(peak_average(:));

else
    if length(size(mov(1).cdata))==2
        peak_average=mean(peak_frames, 3);
    elseif length(size(mov(1).cdata))==3
        peak_average=mean(peak_frames, 4);
    end
    peak_average = uint8(peak_average);
    max_peak_scale=max(peak_average(:));
    min_peak_scale=min(peak_average(:));
end %max_movie_index~=num_frames


%-----------------------------------------------------------------------------
%FIND THE LOW AND HIGH VALUES OF THE MAXIMUM FRAME FOR THE SPECIFIED TOLERANCE -lowhigh contains these values
%-----------------------------------------------------------------------------
tol=[.00001 .99999];
lowhigh = stretchlim(peak_average, tol);
%   TOL = [LOW_FRACT HIGH_FRACT] specifies the fraction of the image to
%   saturate at low and high intensities.

%----------------------------------------------------------------
%RESCALE DIFFERENCE MOVIE TO MAXIMUM AND MINIMUM OF PEAK AVERAGE
%----------------------------------------------------------------

low_in=lowhigh(1); high_in=lowhigh(2);

for i=num_frames:-1:1
    mov_diff(i).cdata=imadjust(mov_diff(i).cdata, [low_in; high_in],[0; 1]);
end

%---------------------------------------------
%DISPLAY PEAK AVERAGE SCALED FOR SELECTING ROI
%---------------------------------------------

set(figure(1), 'color', 'white', 'doublebuffer', 'on', 'position',  [200 200 1.75*560  1.75*420]);
imagesc(peak_average,[min_peak_scale max_peak_scale]);
colormap(ca_map);
axis off
colorbar('horiz');

title('SELECT A SINGLE ROI OVER THE MOST ACTIVE REGION', 'fontsize', 12)
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);

%----------
%SELECT ROI
%----------
rect=getrect(1);    %[xmin ymin width height] Define ROI
rectangle('Position',round(rect),'edgecolor', 'w')

roi=round(rect);
close(1)
%-----------------------------------------------------------------------------------------------
%convert to row and colum coordinates rows (roi(2):roi(2)+roi(4))  cols (roi(1):roi(1)+roi(3))
%x and y are 0,0 in the top right hand corner width goes left to right height goes top to bottom
%------------------------------------------------------------------------------------------------

%------------------------------------------------------
%CALCULATE MEAN ROIs FOR EACH FRAME OF DIFFERENCE MOVIE
%------------------------------------------------------

for i=1:num_frames
    roi_data(:,:)=(mov_diff(i).cdata(roi(2):roi(2)+roi(4), roi(1):roi(1)+roi(3)));
    mean_rois(i)=mean(roi_data(:));
end

%----------------------------------
%PLOT MEAN ROI FOR DIFFERENCE MOVIE
%----------------------------------
set(figure(1), 'color', 'white', 'doublebuffer', 'on', 'position',  [200 200 1.75*560  1.75*420]);
plot(mean_rois)
xlabel('FRAMES', 'fontsize', 14);
y_axis=ylim;


%----------------------------------------------
%SELECT FRAMES ON ROI GRAPH FOR IMAGE AVERAGING
%----------------------------------------------

h_title=title('SELECT START AND END OF CONTROL FRAMES','color', 'red', 'fontsize', 16);

[x,y]=ginput(2);
control_start=round(x(1));
control_finish=round(x(2));
%

hold on
plot(control_start:control_finish, mean_rois(control_start:control_finish), 'color', 'black', 'linewidth', 2)

set(h_title, 'visible', 'off')
h_title2=title('SELECT START AND END OF ACTIVE FRAMES','color', 'red', 'fontsize', 16);
set(h_title2, 'visible', 'on')

[x,y]=ginput(2);
active_start=round(x(1));
active_finish=round(x(2));

hold on
plot(active_start:active_finish, mean_rois(active_start:active_finish), 'color', 'red', 'linewidth', 2)

set(h_title2, 'visible', 'off')
title_1=[filename, ': Control and Active Limits'];
h_fig1_title=title(title_1);
set(h_fig1_title, 'visible', 'on', 'color', 'black')


clear roi_data
clear mean_rois

%SAVE FIGURE AS EMF
% cd(dir_avi);
% emf_file=[filename, '_ROI_CONTROL_ACTIVE.emf'];
% print(gcf, '-dmeta', emf_file)

close(1)


%% CALCULATE CONTROL AND ACTIVE FRAMES FOR DISPLAY IMAGES

if s_dye==1

    %RAW CONTROL AVERAGE
    con_frames=(control_finish-control_start)+1;

    for i=1:con_frames
        control_frames(:,:,i)=mov(control_start-1+i).cdata;
    end

    control_average_double=mean(control_frames, 3);
    control_average = uint8(control_average_double);

    for i=num_frames:-1:1 %THIS REVERSE FILLING INITIALLY LEADS TO A MATRIX FULL OF ZEROS - AS IN PREALLOCATION
        average_frames_total(:,:,:,i)=mov(i).cdata;
    end

    average_total=mean(average_frames_total, 4);  clear average_frames_total;
    average_total = uint8(average_total);
    process_log=strvcat(process_log, ['Calculate average of all frames' num2str(num_frames)]);

    %RAW ACTIVE AVERAGE
    act_frames=(active_finish-active_start)+1;

    for i=1:act_frames
        active_frames(:,:,i)=mov(active_start-1+i).cdata;
    end

    active_average=mean(active_frames, 3);
    active_average = uint8(active_average);


elseif s_dye==3  %inverse pericam fura


    %RAW CONTROL AVERAGE
    con_frames=(control_finish-control_start)+1;

    for i=con_frames:-1:1
        inv_control_frames(:,:,i)=inv_mov(control_start-1+i).cdata;
    end
    inv_control_average_double=mean(inv_control_frames, 3);


    inv_control_average = uint8(inv_control_average_double);


    for i=num_frames:-1:1,
        average_frames_total(:,:,:,i)=mov(i).cdata;
    end

    average_total=mean(average_frames_total, 4);  clear average_frames_total;
    average_total = uint8(average_total);
    process_log=strvcat(process_log, ['Calculate average of all frames' num2str(num_frames)]);

    %RAW ACTIVE AVERAGE
    act_frames=(active_finish-active_start)+1;

    for i=1:act_frames
        inv_active_frames(:,:,i)=inv_mov(active_start-1+i).cdata;
    end

    inv_active_average=mean(inv_active_frames, 3);
    inv_active_average = uint8(inv_active_average);

end %for s_dye=1
%


%% MEDIAN FILTER AVERAGED IMAGES

% med_filt = inputdlg('Enter Median Filter Size for Averaged Difference Image. 0 = NO FILTER','Median Filter',1, { ' 3' }, 'on' );
% med_filt = str2num(med_filt{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.

if med_filt ~=0
    if s_dye==1 %ca green etc

        control_average_med_filt=medfilt2(control_average,[med_filt med_filt]);
        average_total_med_filt=medfilt2(average_total,[med_filt med_filt]);
        active_average_med_filt=medfilt2(active_average,[med_filt  med_filt]);

        %SUBTRACT CONTROL AVERAGE FROM ACTIVE AVERAGE-UNFILTERED
        active_average_diff=imsubtract(active_average,control_average);

        %SUBTRACT MED FILT CONTROL AVERAGE FROM MED FILT ACTIVE AVERAGE
        active_average_diff_med_filt=imsubtract(active_average_med_filt,control_average_med_filt);

    elseif s_dye==3 %inverse pericam

        inv_control_average_med_filt=medfilt2(inv_control_average,[med_filt med_filt]);
        average_total_med_filt=medfilt2(average_total,[med_filt med_filt]);
        inv_active_average_med_filt=medfilt2(inv_active_average,[med_filt  med_filt]);


        %SUBTRACT CONTROL AVERAGE FROM ACTIVE AVERAGE-UNFILTERED
        active_average_diff=imsubtract(inv_active_average,inv_control_average);

        %SUBTRACT MED FILT CONTROL AVERAGE FROM MED FILT ACTIVE AVERAGE
        active_average_diff_med_filt=imsubtract(inv_active_average_med_filt,inv_control_average_med_filt);

    end %for s_dye==1/3
end % for  med_filt ~=0


%---------------------------------------------------------------------------------------
%SMOOTH AVERAGED IMAGES
if s_dye==1 %ca green etc

    for i=act_frames

        temp_add = imadd(mov_diff(i-1).cdata, mov_diff(i).cdata,'uint8');
        temp_add_2 = imadd(temp_add,  mov_diff(i+1).cdata, 'uint8');

        mov_diff_smooth(i).cdata = imdivide(temp_add_2,3);
        smoothed_active_frames(:,:,i)= mov_diff_smooth(i).cdata;

        active_frames(:,:,i)=mov(active_start-1+i).cdata;
    end

    smoothed_active_average=mean(smoothed_active_frames, 3);
    smoothed_active_average = uint8(smoothed_active_average);

    %Median_filter Smoothed Active Frames

    smoothed_active_average_med = medfilt2(smoothed_active_average,[med_filt med_filt]);


elseif s_dye==3 %inverse pericam
    %
    %
    %
    %                 inv_control_average_med_filt=medfilt2(inv_control_average,[med_filt med_filt]);
    %                 average_total_med_filt=medfilt2(average_total,[med_filt med_filt]);
    %                 inv_active_average_med_filt=medfilt2(inv_active_average,[med_filt  med_filt]);
    %
    %
    %                 %SUBTRACT CONTROL AVERAGE FROM ACTIVE AVERAGE-UNFILTERED
    %                 active_average_diff=imsubtract(inv_active_average,inv_control_average);
    %
    %                 %SUBTRACT MED FILT CONTROL AVERAGE FROM MED FILT ACTIVE AVERAGE
    %                 active_average_diff_med_filt=imsubtract(inv_active_average_med_filt,inv_control_average_med_filt);

end %for s_dye==1/3




%% CHOOSE IMAGES TO DISPLAY -
% NOTE: LOAD DISPLAY GAINS IS FOR A SERIES OF DATA TO BE DISPLAYED AT THE SAME GAIN

str=strvcat('Load Image Gains','------------------------', 'Do NOT Load Image Gains');
[s_loadgain,v] = listdlg('PromptString','Load Display Gains', 'SelectionMode','single','ListString',str,'listsize', [250 50]); %w h


if s_loadgain ==1 %load gains

    cd(dir_image_gains)
    [image_gains,dir_image_gains] = uigetfile('*.mat','Load the Saved Image Gains'); cd(dir_image_gains); load(image_gains);
    process_log = strvcat(process_log, ' ', 'image_gains: ', dir_image_gains, num2str(image_gains));



    %CONTROL IMAGE

    str=strvcat('Display Control Frames UnFiltered','------------', 'Display  Control Frames Med Filtered','------------', 'Display All Frames Unfiltered','------------', 'Display All Frames Med filtered');
    [s_cfr,v_cfr] = listdlg('PromptString','DISPLAY CONTROL AVERAGE', 'SelectionMode','single','ListString',str,'listsize', [250 120]); %w h


    if s_cfr==1  %Display Control Frames UnFiltered'
        control_display =  control_average;
        title_3=[filename, ': AVERAGED CONTROL FRAMES UNFILTERED'];
    elseif s_cfr==3 %'Display  Control Frames Med Filtered'
        control_display =  control_average_med_filt;
        title_3=[filename, ': AVERAGED CONTROL FRAMES MED FILTERED'];
    elseif s_cfr==5 %'Display All Frames Unfiltered'
        title_3=[filename, ': AVERAGED CONTROL ALL FRAMES UNFILTERED'];
        control_display =  average_total;
    elseif s_cfr==7 %'Display All Frames Med filtered');
        title_3=[filename, ': AVERAGED CONTROL ALL FRAMES MED FILTERED'];
        control_display =  average_total_med_filt;
    end

    % CONTROL
    set(figure(2), 'color', 'white', 'doublebuffer', 'on', 'position', [100 200 1.5*560 1.5*420]);

    imshow(control_display,gray_256);
    h_axis_control = gca;
    axis off
    colorbar('horiz');

    title(title_3, 'fontsize', 14);
    set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);

    low_in  = image_gains(1,1);
    high_in = image_gains(1,2);

    control_display = imadjust(control_display, [low_in; high_in],[0; 1]);

    set(figure(2), 'color', 'white', 'doublebuffer', 'on', 'position', [100 200 1.5*560 1.5*420]);
    imshow(control_display,gray_256);
    h_axis_control=gca;
    axis off
    colorbar('horiz');

    title(title_3, 'fontsize', 14);
    set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);

    process_log=strvcat(process_log, ' ', 'Adjust Gain of Control Image ', num2str(image_gains(1,:)) );

    %DIFFERENCE IMAGE
    str=strvcat('Display Raw Difference', '------------','Display Median Filtered Difference','------------', 'Display Smoothed Difference', '------------','Display Smoothed Median Filtered Difference');
    [s_dfr,v_cfr] = listdlg('PromptString','DISPLAY ACTIVE AVERAGE', 'SelectionMode','single','ListString',str,'listsize', [250 100]); %w h

    %----------------------------------------

    if s_dfr==1  %'Display Raw Difference'
        active_display =  active_average_diff;
        title_7=[filename, ': ACTIVE-CONTROL AVG DIFF IMAGE '];
    elseif s_dfr==3 %'Display Median Filtered Difference'
        active_display =  active_average_diff_med_filt;
        title_7=[filename, ': ACTIVE-CONTROL AVG MEDIAN FILT DIFF IMAGE '];
    elseif s_dfr==5 %Display Smoothed Difference
        active_display =  smoothed_active_average;
        title_7=[filename, ': ACTIVE-CONTROL SMOOTHED '];
    elseif s_dfr==7 %Display Smoothed Median Filtered Difference'
        active_display=smoothed_active_average_med;
        title_7=[filename, ': ACTIVE-CONTROL SMOOTHED MEDIAN FILT DIFF IMAGE '];
    end

    % ACTIVE DIFFERENCE IMAGE
    set(figure(3), 'color', 'white', 'doublebuffer', 'on', 'position', [660 200 560 420]);

    imshow(active_display,ca_map);
    h_axis_control=gca;
    axis off
    colorbar('horiz');

    title(title_7, 'fontsize', 14);
    set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);


    close(3)

    clear low_in high_in

    low_in = image_gains(2,1);
    high_in = image_gains(2,2);

    active_display = imadjust(active_display, [low_in; high_in],[0; 1]);

    set(figure(3), 'color', 'white', 'doublebuffer', 'on', 'position', [660 200 1.5*560 1.5*420]);
    imshow(active_display,ca_map);
    h_axis_control=gca;
    axis off
    colorbar('horiz');

    title(title_7, 'fontsize', 14);
    set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);


elseif s_loadgain == 3

    %CONTROL IMAGE

    str=strvcat('Display Control Frames UnFiltered','------------', 'Display  Control Frames Med Filtered','------------', 'Display All Frames Unfiltered','------------', 'Display All Frames Med filtered');
    [s_cfr,v_cfr] = listdlg('PromptString','DISPLAY CONTROL AVERAGE', 'SelectionMode','single','ListString',str,'listsize', [250 120]); %w h


    if s_cfr==1  %Display Control Frames UnFiltered'
        control_display =  control_average;
        title_3=[filename, ': AVERAGED CONTROL FRAMES UNFILTERED'];
    elseif s_cfr==3 %'Display  Control Frames Med Filtered'
        control_display =  control_average_med_filt;
        title_3=[filename, ': AVERAGED CONTROL FRAMES MED FILTERED'];
    elseif s_cfr==5 %'Display All Frames Unfiltered'
        title_3=[filename, ': AVERAGED CONTROL ALL FRAMES UNFILTERED'];
        control_display =  average_total;
    elseif s_cfr==7 %'Display All Frames Med filtered');
        title_3=[filename, ': AVERAGED CONTROL ALL FRAMES MED FILTERED'];
        control_display =  average_total_med_filt;
    end

    % CONTROL
    set(figure(2), 'color', 'white', 'doublebuffer', 'on', 'position', [100 200 1.5*560 1.5*420]);

    imshow(control_display,gray_256);
    h_axis_control=gca;
    axis off
    colorbar('horiz');

    title(title_3, 'fontsize', 14);
    set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);


    str=strvcat('Adjust Gain of Image','-------------------------', 'Do NOT Adjust Gain of Image');
    [s_r_gain,v] = listdlg('PromptString','Adjust Gain ', 'SelectionMode','single','ListString',str,'listsize', [250 50]); %w h

    if s_r_gain==1

        close(2)
        [control_display, gain] = adjust_image_gain(control_display,gray_256);
        control_gain = gain; clear gain
        set(figure(2), 'color', 'white', 'doublebuffer', 'on', 'position', [100 200 1.5*560 1.5*420]);
        imshow(control_display,gray_256);
        h_axis_control=gca;
        axis off
        colorbar('horiz');

        title(title_3, 'fontsize', 14);
        set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);

    else
    end    %for 'Adjust Gain of image'



    str=strvcat('Display Raw Difference', '------------','Display Median Filtered Difference','------------', 'Display Smoothed Difference', '------------','Display Smoothed Median Filtered Difference');
    [s_dfr,v_cfr] = listdlg('PromptString','DISPLAY ACTIVE AVERAGE', 'SelectionMode','single','ListString',str,'listsize', [250 100]); %w h

    %----------------------------------------

    if s_dfr==1  %'Display Raw Difference'
        active_display =  active_average_diff;
        title_7=[filename, ': ACTIVE-CONTROL AVG DIFF IMAGE '];
    elseif s_dfr==3 %'Display Median Filtered Difference'
        active_display =  active_average_diff_med_filt;
        title_7=[filename, ': ACTIVE-CONTROL AVG MEDIAN FILT DIFF IMAGE '];
    elseif s_dfr==5 %Display Smoothed Difference
        active_display =  smoothed_active_average;
        title_7=[filename, ': ACTIVE-CONTROL SMOOTHED '];
    elseif s_dfr==7 %Display Smoothed Median Filtered Difference'
        active_display=smoothed_active_average_med;
        title_7=[filename, ': ACTIVE-CONTROL SMOOTHED MEDIAN FILT DIFF IMAGE '];
    end

    % ACTIVE DIFFERENCE IMAGE
    set(figure(3), 'color', 'white', 'doublebuffer', 'on', 'position', [660 200 560 420]);

    imshow(active_display,ca_map);
    h_axis_control=gca;
    axis off
    colorbar('horiz');

    title(title_7, 'fontsize', 14);
    set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);

    str=strvcat('Adjust Gain of Image','-------------------------', 'Do NOT Adjust Gain of Image');
    [s_r_gain,v] = listdlg('PromptString','Adjust Gain ', 'SelectionMode','single','ListString',str,'listsize', [250 50]); %w h

    if s_r_gain==1
        close(3)
        [active_display, gain] = adjust_image_gain(active_display,ca_map);
        active_gain = gain; clear gain
        set(figure(3), 'color', 'white', 'doublebuffer', 'on', 'position', [660 200 1.5*560 1.5*420]);
        imshow(active_display,ca_map);
        h_axis_control=gca;
        axis off
        colorbar('horiz');

        title(title_7, 'fontsize', 14);
        set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);

    else        
    end    %for 'Adjust Gain of image'


    image_gains = vertcat(control_gain, active_gain); clear control_gain active_gain
    process_log=strvcat(process_log, ' ', 'Adjust Image Gains ', num2str(image_gains));

    filename_gains = [filename '_IMAGE_GAINS'];
    process_log = strvcat(process_log, ['Save File: ' 'filename_gains']);
    save(filename_gains, 'image_gains', 'process_log');


    if exist('roi_rows')==1; %condition that GRID ROIs selected
        save(filename_roi, 'roi','count_roi', 'num_rois', 'roi_rows', 'roi_cols', 'roi_width', 'roi_height', 'process_log');
    end


end % 'Load Image Gains','------------', 'Do NOT Load Image Gains'

%% SELECT ROIs AND CALCULATE DF/F FOR ROIS ON THE ORIGINAL MOVIE

%--------------------------
%SELECT or LOAD SAVED ROIs
%--------------------------------------------------------------------------------
str=strvcat('Select ROIs', '-------------', 'Select Fixed Dimension ROIs', '-------------', 'GRID','-------------',  'Load Saved ROIs');
[s_roi,v_roi] = listdlg('PromptString','Save Processed Data','SelectionMode','single','ListString',str, 'listsize', [210 120]);  %[width height]
%-----------------------------------------------------------------------------------------------------------------------------------------------

cmap = ca_map;

if s_roi==1  %Select ROIs
    str=strvcat('Set ROIS on CONTROL image','-------------',  'Set ROIS on DIFFERENCE image', '-------------', 'Set ROIs on PROCESSED Video Average');
    [s_roi_image,v] = listdlg('PromptString','Save Processed Data','SelectionMode','single','ListString',str, 'listsize', [280 80]);  %[width height]

    if s_roi_image==1 %Set ROIS on CONTROL image

        num_rois = inputdlg('Enter the number of ROIs to select','Select ROIs',1, {'[ 10 ]'});
        num_rois=str2num(num_rois{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.

        cmap_mult=floor(256/num_rois);
        count_roi=1;

        %SELECT ROIS AND PLOT ON CONTROL IMAGE

        while count_roi <= num_rois

            rect(count_roi,:) = getrect(2);    %[xmin ymin width height] Define ROI
            roi=round(rect);
            rectangle('Position',round(rect(count_roi,:)),'edgecolor', cmap(count_roi*cmap_mult,:), 'LineWidth',2);
            text(roi(count_roi,1)+roi(count_roi,3)+5, roi(count_roi,2)+5, num2str(count_roi), 'color', 'w', 'fontsize', 14);
            count_roi=count_roi+1;

        end %end for while sel_rect < num_rois


        %PLOT ROIS ON DIFFERENCE IMAGE
        figure(3)
        for i=1:num_rois
            %draw roi numbers
            text(roi(i,1)+roi(i,3)+5, roi(i,2)+5, num2str(i), 'color', 'w', 'fontsize', 14);
            %draw rois
            rectangle('Position',roi(i,:),'edgecolor', cmap(i*cmap_mult,:),'LineWidth',2 );
        end



    elseif s_roi_image==3 %Set ROIS on DIFFERENCE image

        num_rois = inputdlg('Enter the number of ROIs to select','Select ROIs',1, {'[ 10 ]'});
        num_rois=str2num(num_rois{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.

        cmap_mult=floor(256/num_rois);
        count_roi=1;

        %SELECT ROIS AND PLOT ON DIFFERENCE IMAGE

        while count_roi <= num_rois

            rect(count_roi,:) = getrect(3);    %[xmin ymin width height] Define ROI
            roi=round(rect);
            rectangle('Position',round(rect(count_roi,:)),'edgecolor', cmap(count_roi*cmap_mult,:), 'LineWidth',2);
            text(roi(count_roi,1)+roi(count_roi,3)+5, roi(count_roi,2)+5, num2str(count_roi), 'color', 'w', 'fontsize', 14);
            count_roi=count_roi+1;

        end %end for while sel_rect < num_rois

        %PLOT ROIS ON CONTROL IMAGE
        figure(2)
        for i=1:num_rois
            %draw roi numbers
            text(roi(i,1)+roi(i,3)+5, roi(i,2)+5, num2str(i), 'color', 'w', 'fontsize', 14);
            %draw rois
            rectangle('Position',roi(i,:),'edgecolor', cmap(i*cmap_mult,:),'LineWidth',2 );
        end

    elseif s_roi_image==5  %Set ROIs on PROCESSED Video Average

        %DISPLAY AVERAGE
        set(figure(2), 'color', 'white', 'doublebuffer', 'on', 'position',  [660 200 560  420]);

        max_scale=max(average_total(:));
        min_scale=min(average_total(:));

        imagesc(average_total,[min_scale max_scale]);
        colormap(ca_map);
        h_axis_diff=gca;
        axis off
        title_7=[filename, ': AVERAGE OF ALL FRAMES '];
        title(title_7, 'fontsize', 14);
        colorbar('horiz');
        set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);

        num_rois = inputdlg('Enter the number of ROIs to select','Select ROIs',1, {'[ 10 ]'});
        num_rois=str2num(num_rois{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.

        %         cd c:\data\2_photon_data\colormaps
        %         load ca_map
        cmap=jet;
        cmap_mult=floor(256/num_rois);

        count_roi=1;

        while count_roi <= num_rois

            rect(count_roi,:) = getrect(2);    %[xmin ymin width height] Define ROI
            roi=round(rect);
            rectangle('Position',round(rect(count_roi,:)),'edgecolor', cmap(count_roi*cmap_mult,:), 'LineWidth',2);
            text(roi(count_roi,1)+roi(count_roi,3)+5, roi(count_roi,2)+5, num2str(count_roi), 'color', 'w', 'fontsize', 14);
            count_roi=count_roi+1;

        end %end for while sel_rect < num_rois
    end %END FOR Set ROIS on CONTROL image', 'Set ROIS on DIFFERENCE image', 'Set ROIs on PROCESSED Video Average'



elseif s_roi==3  %Select Fixed Dimension ROIs

    str=strvcat('Set ROIS on CONTROL image', '-------------', 'Set ROIS on DIFFERENCE image','-------------',  'Set ROIs on PROCESSED Video Average');
    [s_roi_image,v] = listdlg('PromptString','Save Processed Data','SelectionMode','single','ListString',str, 'listsize', [280 80]);  %[width height]

    cmap=jet;

    if s_roi_image==1 %Set ROIS on CONTROL image

        %SELECT ROIS AND PLOT ON CONTROL IMAGE

        num_rois = inputdlg('Use the RECTANGLE to Define the Area For ROIs and enter the number of ROIs to select','Select ROIs',1, {'[ 5 ]'});
        num_rois=str2num(num_rois{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.

        limit_rect=round(getrect(2)); %[xmin ymin width height] Define ROI
        roi_height=round(limit_rect(4)/num_rois);
        roi_width=limit_rect(3);

        cmap_mult=floor(256/num_rois);

        count_roi=1;

        %SET AND PLOT FIXED DIMENSION ROIS ON CONTROL IMAGE
        figure(2)
        while count_roi <= num_rois

            rectangle('Position', [limit_rect(1) limit_rect(2)+((roi_height)*(count_roi-1)) roi_width roi_height],'edgecolor', cmap(count_roi*cmap_mult,:), 'LineWidth',2);
            roi(count_roi,:)=[limit_rect(1) limit_rect(2)+((roi_height)*(count_roi-1)) roi_width roi_height];
            text(roi(count_roi,1)+roi(count_roi,3)+5, roi(count_roi,2)+5, num2str(count_roi), 'color', 'w', 'fontsize', 14);
            count_roi=count_roi+1;

        end %end for while sel_rect < num_rois


        % PLOT FIXED DIMENSION ROIS ON DIFFERENCE IMAGE
        figure(3)
        for i=1:num_rois
            %draw roi numbers
            text(roi(i,1)+roi(i,3)+5, roi(i,2)+5, num2str(i), 'color', 'w', 'fontsize', 14);
            %draw rois
            rectangle('Position',roi(i,:),'edgecolor', cmap(i*cmap_mult,:),'LineWidth',2 );
        end


    elseif s_roi_image==3 %Set ROIS on DIFFERENCE image

        num_rois = inputdlg('Use the RECTANGLE to Define the Area For ROIs and enter the number of ROIs to select','Select ROIs',1, {'[ 5 ]'});
        num_rois=str2num(num_rois{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.

        limit_rect=round(getrect(3)); %[xmin ymin width height] Define ROI
        roi_height=round(limit_rect(4)/num_rois);
        roi_width=limit_rect(3);

        cmap_mult=floor(256/num_rois);

        count_roi=1;

        %SET AND PLOT FIXED DIMENSION ROIS ON DIFFERENCE IMAGE
        figure(3)
        while count_roi <= num_rois

            rectangle('Position', [limit_rect(1) limit_rect(2)+((roi_height)*(count_roi-1)) roi_width roi_height],'edgecolor', cmap(count_roi*cmap_mult,:), 'LineWidth',2);
            roi(count_roi,:)=[limit_rect(1) limit_rect(2)+((roi_height)*(count_roi-1)) roi_width roi_height];
            text(roi(count_roi,1)+roi(count_roi,3)+5, roi(count_roi,2)+5, num2str(count_roi), 'color', 'w', 'fontsize', 14);
            count_roi=count_roi+1;

        end %end for while sel_rect < num_rois


        % PLOT FIXED DIMENSION ROIS ON CONTROL IMAGE
        figure(2)
        for i=1:num_rois
            %draw roi numbers
            text(roi(i,1)+roi(i,3)+5, roi(i,2)+5, num2str(i), 'color', 'w', 'fontsize', 14);
            %draw rois
            rectangle('Position',roi(i,:),'edgecolor', cmap(i*cmap_mult,:),'LineWidth',2 );
        end


    elseif s_roi_image==5  %Set ROIs on PROCESSED Video Average


        %DISPLAY AVERAGE
        set(figure(2), 'color', 'white', 'doublebuffer', 'on', 'position',  [660 200 560  420]);

        max_scale=max(average_total(:));
        min_scale=min(average_total(:));

        imagesc(average_total,[min_scale max_scale]);
        colormap(ca_map);
        h_axis_diff=gca;
        axis off
        title_7=[filename, ': AVERAGE OF ALL FRAMES '];
        title(title_7, 'fontsize', 14);
        colorbar('horiz');
        set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);




        num_rois = inputdlg('Use the RECTANGLE to Define the Area For ROIs and enter the number of ROIs to select','Select ROIs',1, {'[ 5 ]'});
        num_rois=str2num(num_rois{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.

        limit_rect=round(getrect(2)); %[xmin ymin width height] Define ROI
        roi_height=round(limit_rect(4)/num_rois);
        roi_width=limit_rect(3);

        cmap_mult=floor(256/num_rois);

        count_roi=1;

        %SET AND PLOT FIXED DIMENSION ROIS ON DIFFERENCE IMAGE
        figure(3)
        while count_roi <= num_rois

            rectangle('Position', [limit_rect(1) limit_rect(2)+((roi_height)*(count_roi-1)) roi_width roi_height],'edgecolor', cmap(count_roi*cmap_mult,:), 'LineWidth',2);
            roi(count_roi,:)=[limit_rect(1) limit_rect(2)+((roi_height)*(count_roi-1)) roi_width roi_height];
            text(roi(count_roi,1)+roi(count_roi,3)+5, roi(count_roi,2)+5, num2str(count_roi), 'color', 'w', 'fontsize', 14);
            count_roi=count_roi+1;

        end %end for while sel_rect < num_rois

    end %END FOR Set ROIS on CONTROL image', 'Set ROIS on DIFFERENCE image', 'Set ROIs on PROCESSED Video Average'

    %$$$$$$$$$$$$$$$$$$$$%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$4$$$$$$$$$$
    %--------------------
elseif s_roi==5 %GRID
    %--------------------
    %$$$$$$$$$$$$$$$$$$$$%$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

    str=strvcat('Set ROIS on CONTROL image', '-------------', 'Set ROIS on DIFFERENCE image');
    [s_roi_image,v] = listdlg('PromptString','Save Processed Data','SelectionMode','single','ListString',str, 'listsize', [280 80]);  %[width height]

    cmap=jet;

    if s_roi_image==1 %Set ROIS AND PLOT ON CONTROL IMAGE
        %====================================== xxxxxxx =====

        %------------
        %SELECT ROIS
        %------------

        %% SET GRID ON CONTROL

        num_rois = inputdlg('DRAG the RECTANGLE to Define the Area For ROIs and enter the number of ROWS AND COLUMNS to select','Select ROIs',1, {'[ 6 6 ]'});
        num_rois=str2num(num_rois{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.

        roi_rows=num_rois(1); roi_cols=num_rois(2); num_rois=roi_rows*roi_cols;


        %limit_rect(1)=xmin  limit_rect(2)=ymin  limit_rect(3)=width
        %limit_rect(4)=height
        limit_rect=round(getrect(2)); %[xmin ymin width height] Define ROI
        roi_height=round(limit_rect(4)/roi_rows);
        roi_width=round(limit_rect(3)/roi_cols);
        rectangle('Position', [limit_rect(1) limit_rect(2) limit_rect(3) limit_rect(4)], 'edgecolor', 'black')

        cmap_mult=floor(256/num_rois);


        %SET AND PLOT GRID ROIS ON CONTROL IMAGE
        %========================= xxxxxxx ======
        figure(2)
        count_roi=1;
        for i=1:roi_rows
            for j=1:roi_cols

                rectangle('Position', [limit_rect(1)+((roi_width)*j-1)-roi_width limit_rect(2)+((roi_height)*i-1)-roi_height roi_width roi_height],'edgecolor', 'white', 'LineWidth',1);
                roi(count_roi,:)= [limit_rect(1)+((roi_width)*j-1)-roi_width limit_rect(2)+((roi_height)*i-1)-roi_height roi_width roi_height];
                %                 text(roi(i,j,1), roi(count_roi,2), num2str(count_roi), 'color', 'w', 'fontsize', 8);
                count_roi=count_roi+1;
            end
        end
        %%


        %% SET GRID ON DIFFERENCE

        % PLOT GRID ROIS ON DIFFERENCE IMAGE
        %================= xxxxxxxxxx =======

        figure(3)
        for i=1:num_rois
            rectangle('Position',roi(i,:),'edgecolor', 'red','LineWidth',1 );
        end
        hold on
        %PLOT COLUMN IDS
        for i=1:roi_cols
            text(roi(i,1)+round(roi_width/2), roi(1,2)-round(roi_height/2), num2str(i), 'color', 'r', 'fontsize', 12);
        end
        %PLOT ROW IDS
        count=1;
        for i=1:roi_cols:num_rois
            text(roi(1,1)-round(roi_width/2), roi(i,2)+round(roi_height/2), num2str(count), 'color', 'r', 'fontsize', 12);
            count=count+1;
        end


    elseif s_roi_image==3 %Set ROIS on DIFFERENCE image
        %==================================================
        num_rois = inputdlg('DRAG THE RECTANGLE to Define the Area For ROIs and enter the number of ROWS AND COLUMNS to select','Select ROIs',1, {'[ 6 6 ]'});
        num_rois=str2num(num_rois{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.

        roi_rows=num_rois(1); roi_cols=num_rois(2); num_rois=roi_rows*roi_cols;


        %limit_rect(1)=xmin  limit_rect(2)=ymin  limit_rect(3)=width
        %limit_rect(4)=height
        limit_rect=round(getrect(3)); %[xmin ymin width height] Define ROI
        roi_height=round(limit_rect(4)/roi_rows);
        roi_width=round(limit_rect(3)/roi_cols);

        cmap_mult=floor(256/num_rois);


        %SET AND PLOT GRID ROIS ON DIFFERENCE IMAGE

        figure(3)
        count_roi=1;
        for i=1:roi_rows
            for j=1:roi_cols
                rectangle('Position', [limit_rect(1)+((roi_width)*j-1)-roi_width limit_rect(2)+((roi_height)*i-1)-roi_height roi_width roi_height],'edgecolor', cmap(count_roi*cmap_mult,:), 'LineWidth',1);
                roi(count_roi,:)=[limit_rect(1)+((roi_width)*j-1)-roi_width limit_rect(2)+((roi_height)*i-1)-roi_height roi_width roi_height];
                %            text(roi(count_roi,1), roi(count_roi,2), num2str(count_roi), 'color', 'w', 'fontsize', 8);
                count_roi=count_roi+1;

            end
        end


        % PLOT GRID ROIS ON CONTROL IMAGE
        figure(2)
        for i=1:num_rois
            rectangle('Position',roi(i,:),'edgecolor', 'red','LineWidth',1 );
        end
        hold on
        %PLOT COLUMN IDS
        for i=1:roi_cols
            text(roi(i,1)+round(roi_width/2), roi(1,2)-round(roi_height/2), num2str(i), 'color', 'r', 'fontsize', 12);
        end
        %PLOT ROW IDS
        count=1
        for i=1:roi_cols:num_rois
            text(roi(1,1)-round(roi_width/2), roi(i,2)+round(roi_height/2), num2str(count), 'color', 'r', 'fontsize', 12);
            count=count+1;
        end

        %% SELECT SUBSET OF GRID


        %% Select Subset of Grid
        str=strvcat('Select Subset of Grid', '--------------', 'Finished');
        [s_sub,v] = listdlg('PromptString','Select ROI Type','SelectionMode','single','ListString',str, 'listsize', [175 50]);  %[width height]

        if s_sub==1


            set(figure(77), 'color', 'white', 'doublebuffer', 'on', 'position',  [660 200 560  420]);

            %     imagesc(active_average_diff_med_filt_sub,[min_active_scale max_active_scale]);
            imagesc(active_average_diff,[min_active_scale max_active_scale]);
            colormap(ca_map);
            h_axis_diff=gca;
            axis off
            title_7=[filename, ': ACTIVE-CONTROL AVG MEDIAN(3) FILT DIFF IMAGE '];
            title(title_7, 'fontsize', 14);
            colorbar('horiz');
            set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);

            for i=1:num_rois
                rectangle('Position',roi(i,:),'edgecolor',  cmap(i*cmap_mult,:),'LineWidth',1 );
                text(roi(i,1), roi(i,2), num2str(i), 'color', cmap(i*cmap_mult,:), 'fontsize', 8);
            end

            button=1;
            count=1;
            while button~=3
                [x, y, button]=ginput(1);
                x_sel(count)=round(x);
                y_sel(count)=round(y);

                for j=1:num_rois
                    if  ( ( roi(j,1) <  x_sel(count) &&  x_sel(count) < roi(j,1)+roi_width ) ) &&  ( ( roi(j,2) <  y_sel(count) & y_sel(count) < roi(j,2)+roi_height ) )==1
                        rectangle('Position',roi(j,:),'facecolor', cmap(j*cmap_mult,:),'edgecolor', cmap(j*cmap_mult,:) );
                    else
                    end
                end

                count=count+1;
            end
        else
        end %end for 'Select Subset of Grid', '--------------', 'Finished' %%

    end %for Set ROIS on CONTROL image', 'Set ROIS on DIFFERENCE image', 'Set ROIs on PROCESSED Video Average


elseif s_roi==7  %LOAD SAVED ROIS

    cd(dir_roi)
    [filename_roi,dir_roi] = uigetfile('*.mat','Load the Saved ROIs'); cd(dir_roi); load(filename_roi);
    process_log=strvcat(process_log, ' ', 'Load the Saved ROIs: ', dir_roi, ['Filename: ' filename_roi]);
    cmap=colormap(ca_map);
    cmap_mult=floor(256/num_rois);

    %draw rois ON CONTROL IMAGE AND ACTIVE DIFFERENCE IMAGE

    str=strvcat('Standard or Fixed Dimension ROIs', '--------------', 'GRID ROIs');
    [s_roi_type,v] = listdlg('PromptString','Select ROI Type','SelectionMode','single','ListString',str, 'listsize', [200 50]);  %[width height]


    %CONTROL
    figure(2)


    if s_roi_type~=3  %GRID NOT SELECTED

        figure(2)  %CONTROL

        for i=1:num_rois
            h_control_roi(i)  =   rectangle('Position',roi(i,:),'edgecolor', cmap(i*cmap_mult,:), 'LineWidth',2);
            h_control_text(i) =   text(roi(i,1)+roi(i,3)+5, roi(i,2)+5, num2str(i), 'color', 'w', 'fontsize', 14);
        end


        figure(3)  %DIFFERENCE

        for i=1:num_rois
            h_diff_roi(i)  = rectangle('Position',roi(i,:),'edgecolor', cmap(i*cmap_mult,:), 'LineWidth',1);
            h_diff_text(i) = text(roi(i,1)+roi(i,3)+5, roi(i,2)+5, num2str(i), 'color', 'w', 'fontsize', 14);
        end

    elseif s_roi_type==3 %GRID SELECTED

        %CONTROL
        figure(2)
        for i=1:num_rois
            rectangle('Position',roi(i,:),'edgecolor', 'w','LineWidth',1 );
        end
        hold on
        %PLOT COLUMN IDS
        for i=1:roi_cols
            text(roi(i,1)+round(roi_width/2), roi(1,2)-round(roi_height/2), num2str(i), 'color', 'r', 'fontsize', 12);
        end
        %PLOT ROW IDS
        count=1
        for i=1:roi_cols:num_rois
            text(roi(1,1)-round(roi_width/2), roi(i,2)+round(roi_height/2), num2str(count), 'color', 'r', 'fontsize', 12);
            count=count+1;
        end
        %DIFFERENCE
        figure(3)
        for i=1:num_rois
            rectangle('Position',roi(i,:),'edgecolor', 'w','LineWidth',1 );
        end
        hold on
        %PLOT COLUMN IDS
        for i=1:roi_cols
            text(roi(i,1)+round(roi_width/2), roi(1,2)-round(roi_height/2), num2str(i), 'color', 'r', 'fontsize', 12);
        end
        %PLOT ROW IDS
        count=1
        for i=1:roi_cols:num_rois
            text(roi(1,1)-round(roi_width/2), roi(i,2)+round(roi_height/2), num2str(count), 'color', 'r', 'fontsize', 12);
            count=count+1;
        end

    end %for  %GRID NOT SELECTED

    %% ADJUST ROIS

    str=strvcat('Adjust ROI Position', '-----------------------', 'Do NOT Adjust ROI Position');
    [s_adjroi,v] = listdlg('PromptString','ADJUST ROI','SelectionMode','single','ListString',str, 'listsize', [180 50]);  %[width height]



    while s_adjroi == 1

        prompt = {'Enter Pixels to Move UP (-) or DOWN (+)','Enter Pixels to Move RIGHT (+) or LEFT (-)'};
        dlg_title = 'INPUT FOR ADJUSTING ROIS';
        num_lines= 1;
        def     = {num2str(0), num2str(0)};
        answer  = inputdlg(prompt,dlg_title,num_lines,def);

        adj_ud = str2num(answer{1});  adj_lr = str2num(answer{2});

        % rectangle [x,y,width,height]

        roi(:, 1) =   roi(:, 1)  + adj_lr;  %adjust left right position
        roi(:, 2) =   roi(:, 2)  + adj_ud;  %adjust up down position

        delete(h_control_roi);
        delete(h_diff_roi);
        delete(h_diff_text);
        delete(h_control_text);


        figure(2) %CONTROL IMAGE
        for i=1:num_rois
            h_control_roi(i)  =  rectangle('Position',roi(i,:),'edgecolor', cmap(i*cmap_mult,:), 'LineWidth',1);
            h_control_text(i) =  text(roi(i,1)+roi(i,3)+5, roi(i,2)+5, num2str(i), 'color', 'w', 'fontsize', 14);
        end

        figure(3) %DIFFERENCE IMAGE

        for i=1:num_rois
            h_diff_roi(i)  =  rectangle('Position',roi(i,:),'edgecolor',  cmap(i*cmap_mult,:), 'LineWidth',1);
            h_diff_text(i) =  text(roi(i,1)+roi(i,3)+5, roi(i,2)+5, num2str(i), 'color', 'w', 'fontsize', 14);
        end

        str=strvcat('Adjust ROI Position', '-----------------------', 'Finished');
        [s_adjroi,v] = listdlg('PromptString','ADJUST ROI','SelectionMode','single','ListString',str, 'listsize', [180 50]);

    end %ADJUST ROI POSITION', '-----------------------', 'DO NOT ADJUST ROI POSITION

end %'Select ROIs', 'Select Fixed Dimension ROIs', 'Load Saved ROIs'




%% SAVE ROIS
cd(dir_avi);

%     filename=strrep(filename, '.avi', '');
filename_roi=[filename '_ROIs'];
process_log=strvcat(process_log, ['Save File: ' 'filename']);
save(filename_roi, 'roi', 'count_roi', 'num_rois', 'process_log');
if exist('roi_rows')==1; %condition that GRID ROIs selected
    save(filename_roi, 'roi','count_roi', 'num_rois', 'roi_rows', 'roi_cols', 'roi_width', 'roi_height', 'process_log');
end


%% SAVE ROI FIGURES AS EMF and FIG
cd(dir_avi);
emf_file=[filename, '_CONTROL_AVERAGE.emf'];
print(2, '-dmeta', emf_file)
fig_file=[filename, '_CONTROL_AVERAGE.fig'];
saveas(2, fig_file, 'fig')

emf_file=[filename, '_ACTIVE_AVERAGE.emf'];
print(3, '-dmeta', emf_file)
fig_file=[filename, '_ACTIVE_AVERAGE.fig'];
saveas(3, fig_file, 'fig')

close all


cd_save_figs = dir_avi;

%% CALCULATE ROIS

str=strvcat('Standard or Fixed Dimension ROIs', '--------------', 'GRID ROIs');
[s_roi_type,v] = listdlg('PromptString','Select ROI Type','SelectionMode','single','ListString',str, 'listsize', [200 50]);  %[width height]

if s_roi_type==1  %Standard or Fixed Dimension ROIs'


    str=strvcat('Calculate ROIs on Median Filtered Raw Video', '----------------------', 'Calculate ROIs on Raw Video');
    [s_croi,v] = listdlg('PromptString','CALCULATE ROIS ', 'SelectionMode','single','ListString',str,'listsize', [250 55]); %w h

    if s_croi == 3  %CALCULATE ROIS ON RAW VIDEO

        %-----------------------
        %CALCULATE MEAN FOR ROIs
        %-----------------------
        for j=1:num_rois
            for i=num_frames:-1:1
                roi_data(j).input(:,:)=(mov(i).cdata(roi(j,2):roi(j,2)+roi(j,4), roi(j,1):roi(j,1)+roi(j,3)));
                mean_rois(i,j)=mean(roi_data(j).input(:));
            end  % for  i=1:num_frames
        end  % for for j=1:count_roi

    elseif s_croi == 1  %CALCULATE ROIS ON MEDIAN FILTERED VIDEO


        for i=num_frames:-1:1
            mov_med_filt(i).cdata= medfilt2(mov(i).cdata, [med_filt med_filt]);
            mov_med_filt(i).colormap=mov(i).colormap;
        end

        for j=1:num_rois
            for i=1:num_frames
                roi_data(j).input(:,:)=(mov_med_filt(i).cdata(roi(j,2):roi(j,2)+roi(j,4), roi(j,1):roi(j,1)+roi(j,3)));
                mean_rois(i,j)=mean(roi_data(j).input(:));
            end  % for  i=1:num_frames
        end  % for for j=1:count_roi
    end  %CALCULATE ROIS ON RAW VIDEO', 'CALCULATE ROIS ON MEDIAN FILTERED VIDEO'


    %---------------------------------------
    %NORMALIZE SMOOTH AND PLOT MEAN ROI DATA
    %---------------------------------------

    mean_rois_smooth = smooth_2(mean_rois,3); %3 point moving average

    for i=1:num_rois
        max_mean_rois_smooth(i)=max(mean_rois_smooth(:,i));
        min_mean_rois_smooth(i)=min(mean_rois_smooth(:,i));
    end

    [r_norm, c_norm]=size(mean_rois_smooth);        % determine number of rows (movie) and columns (movie) i.e rowm, colm

    max_matrix=repmat(max_mean_rois_smooth,r_norm,1); %expand column maxima into a matrix
    min_matrix=repmat(min_mean_rois_smooth,r_norm,1);   %expand column minima into a matrix

    mean_rois_smooth_norm=(mean_rois_smooth-min_matrix)./((max_matrix-min_matrix));
    process_log=strvcat(process_log, 'Normalize Each Data Channel');

    %     set(figure(5), 'color', 'white', 'doublebuffer', 'on', 'position',  [200 200 560  420]);
    %     for i=1:num_rois
    %         plot(mean_rois_smooth_norm(:,i), 'color', cmap(i*cmap_mult,:), 'linewidth', 2)
    %         hold on
    %     end
    %     cd(dir_avi);
    %     emf_file=[filename, '_SMOOTHED_NORM_MED_DF_OVER_F.emf'];
    %     saveas(5, filename, 'emf')



    clear max_matrix; clear min_matrix;

    %-----------------------
    %CALCULATE DF/F FOR ROIS
    %-----------------------
    clear control_roi
    for i=1:num_rois
        control_roi(:,i)=mean(mean_rois(control_start:control_finish,i));
        df_over_f(:,i)=(mean_rois(:,i)/control_roi(i))*100;
    end

    %-----------------------------------
    %CALCULATE MAXIMUM OF THE DF/F DATA
    %-----------------------------------

    max_df_over_f=max(df_over_f(:));
    min_df_over_f=min(df_over_f(:));
    df_over_f_y_extent=max_df_over_f-min_df_over_f;

    %------------------
    %PLOT DF/F SUBPLOTS
    %------------------

    timebase_roi=1:1:num_frames;
    %     set(figure(6), 'color', 'white', 'doublebuffer', 'on', 'position',  [780 200 560 420]);
    %
    %     for i=1:num_rois
    %         subplot(num_rois, 1, i)   % subplot(row, column, nth plot)
    %         plot(df_over_f(:,i), 'color', cmap(i*cmap_mult,:), 'linewidth', 2)
    %         title_10=['ROI: ' num2str(i)];
    %         text(.005, .8, title_10, 'units', 'normalized','color', cmap(i*cmap_mult,:));
    %         if i==1
    %             title_df=[filename, ': DF/F for ROIs'];
    %             title(title_df, 'fontsize', 14);
    %         end
    %         xlim([timebase_roi(1) timebase_roi(end)]);
    %         ylim([min_df_over_f max_df_over_f]);
    %         axis off
    %     end
    %     draw_cal_df_over_d
    %
    %     cd(dir_avi);
    %     emf_file=[filename, '_DF_OVER_F.emf'];
    %     print(6, '-dmeta', emf_file)



    %-----------------------------------
    %CALCULATE DF/F FOR SMOOTHED ROIS
    %-----------------------------------
    clear control_roi
    for i=1:num_rois
        control_roi_smooth(:,i) = mean(mean_rois_smooth(control_start:control_finish,i));
        df_over_f_smooth(:,i)   = (mean_rois_smooth(:,i)/control_roi_smooth(i))*100;
    end

    %--------------------------------------------
    %CALCULATE MAXIMUM OF THE SMOOTHED DF/F DATA
    %--------------------------------------------

    max_df_over_f_smooth=max(df_over_f_smooth(:));
    min_df_over_f_smooth=min(df_over_f_smooth(:));
    df_over_f_y_extent_smooth=max_df_over_f_smooth-min_df_over_f_smooth;


    %---------------------------
    %PLOT SMOOTHED DF/F SUBPLOTS
    %---------------------------

    timebase_roi=1:1:num_frames;
    %     set(figure(7), 'color', 'white', 'doublebuffer', 'on', 'position',  [780 200 560 420]);
    %
    %     for i=1:num_rois
    %         subplot(num_rois, 1, i)   % subplot(row, column, nth plot)
    %         plot(df_over_f_smooth(:,i), 'color', cmap(i*cmap_mult,:), 'linewidth', 2)
    %         title_10=['ROI: ' num2str(i)];
    %         text(.005, .8, title_10, 'units', 'normalized','color', cmap(i*cmap_mult,:));
    %         if i==1
    %             title_df=[filename, ': SMOOTHED DF/F for ROIs'];
    %             title(title_df, 'fontsize', 14);
    %         end
    %         xlim([timebase_roi(1) timebase_roi(end)]);
    %         ylim([min_df_over_f_smooth max_df_over_f_smooth]);
    %         axis off
    %     end
    %     draw_cal_df_over_d
    %
    %     cd(dir_avi);
    %     emf_file=[filename, '_SMOOTHED_DF_OVER_F.emf'];
    %     print(7, '-dmeta', emf_file)



end %for ('Standard or Fixed Dimension ROIs', '--------------', 'GRID ROIs')


%% MAKE MOVIES

str=strvcat('Do NOT Make Movies','----------------------', 'Make Movies');
[s_m,v] = listdlg('PromptString','MAKE MOVIES ', 'SelectionMode','single','ListString',str,'listsize', [150 50]); %w h
% Median Filter Difference Movie and SAVE



if s_m ~= 1  %MAKE MOVIES

    med_filt_vid = inputdlg('Enter Median Filter Size for Difference Movie. 0 = no filtering','Median filter',1, { ' 3' }, 'on' );
    med_filt_vid = str2num(med_filt_vid{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.

    if med_filt_vid~=0
        for i=num_frames:-1:1
            mov_diff_med_filt(i).cdata= medfilt2(mov_diff(i).cdata,[ med_filt_vid   med_filt_vid ] );
            mov_diff_med_filt(i).colormap=mov(i).colormap;
        end
    end

    if exist('mov_diff_med_filt') == 0
        mov_diff_med_filt=mov_diff;
    end

    process_log=strvcat(process_log, 'Calculate MEDIAN FILTERED (3) Difference Image Movie ');

    %DISPLAY PEAK MOVIE HISTOGRAM

    peak_index=active_start+round(act_frames/2);

    peak_mov_diff_med_filt = mov_diff_med_filt(peak_index).cdata;
    peak_mov_diff_med_filt = uint8(peak_mov_diff_med_filt);

    set(figure(8), 'color', 'white', 'doublebuffer', 'on', 'position',  [20 100 560 420]);
    imhist(peak_mov_diff_med_filt, ca_map);
    set(figure(9), 'color', 'white', 'doublebuffer', 'on', 'position',  [800 100 560 420]);
    imshow(peak_mov_diff_med_filt, ca_map);

    str=strvcat('Adjust Gain of Median Filtered Movie','-----------------------------------', 'Do NOT Adjust Gain of Median Filtered Movie');
    [s_m_gain,v] = listdlg('PromptString','CALCULATE ROIS ', 'SelectionMode','single','ListString',str,'listsize', [250 50]); %w h

    if s_m_gain==1

        %function [y]=adjust_movie_gain(x,n,p, map)  %x is image to be adjusted , n= number of frames; p = peak signal index, map is the colormap
        [mov_diff_med_filt] = adjust_movie_gain(mov_diff_med_filt, num_frames,peak_index, ca_map);
        % adjust_movie_gain
    else
    end


    %% SMOOTH MOVIE
    %INITIALIZE FIRST AND LAST FRAMES
    mov_smooth(1).cdata=mov_diff_med_filt(1).cdata
    mov_smooth(1).colormap=mov(1).colormap;
    mov_smooth(num_frames).cdata=mov_diff_med_filt(num_frames).cdata
    mov_smooth(num_frames).colormap=mov(1).colormap;

    % % %compute 3 point moving average and rescale movie
    for i=num_frames-1:-1:2

        temp_add = imadd(mov_diff_med_filt(i-1).cdata, mov_diff_med_filt(i).cdata,'uint8');
        temp_add_2 = imadd(temp_add,  mov_diff_med_filt(i+1).cdata, 'uint8');
        mov_smooth(i).cdata=imdivide(temp_add_2,3);
        mov_smooth(i).colormap=mov(1).colormap;
        % imshow(mov_smooth(2).cdata, ca_map)
    end

    %REPLACE LAST FRAME WITH PENULTIMATE FRAME
    mov_smooth(num_frames).cdata=mov_smooth(num_frames-1).cdata;
    mov_smooth(num_frames).colormap=mov(1).colormap;



    %DISPLAY PEAK MOVIE HISTOGRAM

    peak_mov_smooth=mov_smooth(peak_index).cdata;
    peak_mov_smooth = uint8(peak_mov_smooth);

    set(figure(8), 'color', 'white', 'doublebuffer', 'on', 'position',  [20 100 560 420]);
    imhist(peak_mov_smooth, ca_map);
    set(figure(9), 'color', 'white', 'doublebuffer', 'on', 'position',  [800 100 560 420]);
    imshow(peak_mov_smooth, ca_map);


    str=strvcat('Adjust Gain of Smoothed Movie','--------------', 'Do NOT Adjust Gain of Median Filtered Movie');
    [s_ms_gain,v] = listdlg('PromptString','CALCULATE ROIS ', 'SelectionMode','single','ListString',str,'listsize', [250 65]); %w h

    if s_ms_gain==1

        [mov_smooth]=adjust_movie_gain(mov_smooth, num_frames,peak_index, ca_map);

    else
    end % for ('Adjust Gain of Smoothed Movie','--------------', 'Do NOT Adjust Gain of Median filtered Movie');

    %RENAME MOVIES

    %Replace First Frame with Second Frame
    mov_smooth(1).cdata=mov_smooth(2).cdata;
    mov_smooth(1).colormap=mov(1).colormap;



    %% SAVE MOVIES

    %------------------------
    %SAVE MEDIAN FILTERED MOVIE
    % %--------------------------
    cd(dir_avi)
    filename_mov=[filename, '', ' _MOV_DIFF_MED'];
    save_movie = inputdlg('Enter Filename for Median Filtered Movie','Save Movie',1, {filename_mov});
    save_movie=(save_movie{1});

    fps=12
    movie2avi(mov_diff_med_filt, save_movie, 'compression', 'none', 'fps', frame_rate);


    %--------------------------------------------------------------------------
    % SAVE MEDIAN FILTERED SMOOTHED MOVIE


    cd(dir_avi)
    filename_mov=[filename, '', '_MOV_DIFF_MED_SMOOTH'];
    save_movie = inputdlg('Enter Filename for Median Filtered SMOOTHED Movie','Save Movie',1, {filename_mov});
    save_movie=(save_movie{1});

    movie2avi(mov_smooth, save_movie, 'compression', 'none', 'fps', frame_rate);


    % %------------------------------------------------------------------------
    % MEDIAN FILTER RAW MOVIE AND SAVE
    % %---------------------------------
    med_filt_raw = inputdlg('Enter Median Filter Size for RAW Movie. 0 = NO FILTER','Median filter',1, { ' 3' }, 'on' );
    med_filt_raw = str2num(med_filt_raw{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.

    if med_filt_raw ~=0
        for i=num_frames:-1:1
            mov_raw(i).cdata= medfilt2(mov(i).cdata,[ med_filt_raw   med_filt_raw ] );
            mov_raw(i).colormap=gray;
        end
        process_log=strvcat(process_log, 'Calculate MEDIAN FILTERED (3) RAW Movie ');
    else
        mov_raw.cdata = mov.cdata
        mov_raw(i).colormap = gray;
    end

    cd(dir_avi)

    filename_mov_raw=[filename, '', ' _MOV_RAW_MED'];

    save_movie_raw = inputdlg('Enter Filename for RAW Movie','Save RAW Movie',1, {filename_mov_raw});
    save_movie_raw=(save_movie_raw{1});

    movie2avi(mov_raw, save_movie_raw, 'compression', 'none', 'fps', frame_rate);

    %STORE MOVIES IN MOV.STORE
    mov_store(1).input=mov_diff_med_filt;
    mov_store(2).input=mov_smooth;
    mov_store(3).input=mov_raw;

else
end  %for make movies



%% PLOT ELECTRCIAL DATA

set(figure(8), 'color', 'white', 'doublebuffer', 'on', 'position',  [100 100 1.5*560 1.5*420]);

for i=1:num_channels
    subplot(num_channels, 1, i)   % subplot(row, column, nth plot)
    plot(timebase, data(:,i))
    text(.01, .9, [num2str(i) ' : ' channel(i).names], 'units', 'normalized');
end


num_channels = inputdlg('SELECT NUMBER OF CHANNELS: 0 if NONE','CHANNELS',1, {num2str(num_channels)});
num_channels = str2num(num_channels{1});

data=data(:,1:num_channels);

%% CHOOSE PCLAMP CHANNELS TO DISPLAY
disp_ch = inputdlg('Enter PClamp Channel Numbers to Display with the ROIs','Select Channels',1, {'[ 1 2 3 4 5 ]'});
disp_ch = str2num(disp_ch{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.

frame_ch = inputdlg('Identify Frame Channel: 0 if NO Frame Channel','Frame Channel',1, {'[ 6 ]'});
frame_ch =  str2num(frame_ch{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.

num_display_chan=length(disp_ch);


%FIND FIRST AND LAST ARTEFACT INDICES FOR DISPLAYED CHANNELS
if chan~=0
    first_artefact_index = single_art_indicies(1).input(1);
    last_artefact_index  = single_art_indicies(1).input(end);
end

diff_data=diff(data);
%-------------------------------
%IDENTIFY MAXIMA OF FRAME CHANNEL
%-------------------------------
if frame_ch~=0

    max_frames = max(diff_data(:,frame_ch));
    max_frame_indicies = find(diff_data(:,frame_ch)> 0.5 * max_frames);


    %-------------------------------
    %FRAMES START AND STOP INDICIES
    %------------------------------
    frame_start_index = max_frame_indicies(1);
    frame_end_index   = max_frame_indicies(end);
    frame_number      = length(max_frame_indicies);
    frame_rate        = (num_frames/(timebase(frame_end_index)-timebase(frame_start_index)));

    %-------------------------------------------------------------------------
    %CALCULATE MAXIMUM AND MINIMUM OF DISPLAYED DATA CHANNELS OVER FRAME RANGE
    %--------------------------------------------------------------------------

    max_display_data = max(data(frame_start_index:frame_end_index,disp_ch));
    min_display_data = min(data(frame_start_index:frame_end_index,disp_ch));
    data_y_extent    = max_display_data-min_display_data;

else  %No Frame Channel

    frame_ch = inputdlg('Identify Frame Channel: ','Frame Channel',1, {'[ 6 ]'});
    frame_ch = str2num(frame_ch{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.


    str = strvcat('SCALE  Frame Channel', 'Do NOT Scale Frame Channel');
    [s_fr_scale,v] = listdlg('PromptString','Clip Frame Channel','SelectionMode','single','ListString',str,'listsize', [170 70] );

    if s_fr_scale==1

        figure(20)
        plot(data(:,frame_ch));

        title('Select Y Values to Rescale Display. Select upper value first then lower value','fontsize', 14)
        [x,y]=ginput(2);
        y_fr_max=(y(1));
        y_fr_min=(y(2));
    else
    end

    figure(20)
    plot(data(:,frame_ch));
    if exist('y_fr_max')==1
        ylim([y_fr_min  y_fr_max]);
    else
    end
    title('Select Start and End of Frames', 'fontsize', 14)
    [x,y]=ginput(2);

    frame_start_index=round(x(1));
    frame_end_index=round(x(2));

    max_display_data = max(data(frame_start_index:frame_end_index,disp_ch));
    min_display_data = min(data(frame_start_index:frame_end_index,disp_ch));
    data_y_extent    = max_display_data-min_display_data;

    close(20)
end %end for if frame_ch~=0

%% SAVE ORIGINAL ELECTRICAL DATA FOR WAV SOUND FILE

if s_m ~= 1  %make movies
set(figure(34), 'color', 'white', 'doublebuffer', 'on', 'position',  [100 100 1.5*560 1.5*420]);

for i=1:length(chan)
    subplot(length(chan), 1, i)   % subplot(row, column, nth plot)
    plot(timebase, data_orig(:,1))
end

save_channel = inputdlg('Enter Channel to Save for Sound File','Save Channel',1, {num2str(chan)});
save_channel =str2num(save_channel{1});

save_movies = horzcat(filename_avi, '_MOVIES')

sound_file = data_orig(frame_start_index:frame_end_index,save_channel);
save(save_movies,'cmap', 'mov_store','sound_file', 'interval' );

else
end



%RESET INDICIES OF DISPLAY NAMES
% count=0;
% for d = 1:num_display_chan;
%     channel_display(d).names = channel(disp_ch(d)).names;
% end

channel_display = channel;

% max_display_data = max(data(frame_start_index:frame_end_index,disp_ch));
% min_display_data = min(data(frame_start_index:frame_end_index,disp_ch));
% data_y_extent    = max_display_data-min_display_data;

str = strvcat('Plot Unsmoothed or Median Filtered Optical', '--------------------------', 'Plot Moving Average Smoothed Optical');
[s_plot_roi,v] = listdlg('PromptString','PLOT ROIS', 'SelectionMode','single','ListString',str,'listsize', [249 55]); %w h

if s_plot_roi==1, plot_roi=df_over_f; else plot_roi=df_over_f_smooth; end


%% PLOT ROI AND SELECTED DE-ARTEFACTED PCLAMP FILES
close(8)
set(figure(11), 'color', 'white', 'doublebuffer', 'on', 'position',  [200 200 1.75*560  1.75*420]);
for i=1:num_display_chan+num_rois
    subplot(num_display_chan+num_rois, 1, i)   % subplot(row, column, nth plot)

    %PLOT ROIs
    if i<=num_rois
        plot(timebase_roi, plot_roi(:,i), 'color', cmap(i*cmap_mult,:), 'linewidth', 2)
        title_10=['ROI: ' num2str(i)];
        text(.05, .8, title_10, 'units', 'normalized','color', cmap(i*cmap_mult,:));
        xlim([timebase_roi(1) timebase_roi(end)]);
        ylim([min_df_over_f max_df_over_f]);

        if i==num_rois    %DRAW LINES CORRESPONDING TO ACTIVE AND CONTROL FRAMES AND DF/F Y CALIBRATION

            line([control_start control_finish], [min_df_over_f + df_over_f_y_extent*.01  min_df_over_f + df_over_f_y_extent*.01], 'linewidth', 2, 'color', 'black');
            line([active_start active_finish], [min_df_over_f + df_over_f_y_extent*.01 min_df_over_f + df_over_f_y_extent*.01], 'linewidth', 2, 'color', 'red');

            draw_y_cal_df_over_d

        end
        %         axis off
        count_ch=0;

        %PLOT PCLAMP FILES
    elseif i > num_rois && i < (num_display_chan+num_rois )
        count_ch=count_ch+1;
        plot(timebase, data(:,disp_ch(i-num_rois)))
        text(.01, .9, [num2str(i) ' : ' channel_display(i-num_rois).names], 'units', 'normalized');
        xlim([timebase(frame_start_index) timebase(frame_end_index)]);
        ylim([min_display_data(count_ch) max_display_data(count_ch)]);
        %         axis off
        %         axis tight


        if i==num_rois+1   %PLOT LINE DEFINING EXTENT OF STIMULATION
            %             line([first_artefact_index  last_artefact_index], [max_display_data(count_ch)-data_y_extent(count_ch)*0.01  max_display_data(count_ch)- data_y_extent(count_ch)*0.01], 'linewidth', 2, 'color', 'blue');
        end

    elseif i==num_display_chan+num_rois
        count_ch=count_ch+1;
        plot(timebase, data(:,disp_ch(i-num_rois)))
        text(.01, .9, [num2str(i) ' : ' channel_display(count_ch).names], 'units', 'normalized');
        xlabel('TIME (sec)', 'fontsize', 14);
        axis on
        xlim([timebase(frame_start_index) timebase(frame_end_index)]);
        ylim([min_display_data(count_ch) max_display_data(count_ch)]);
        %         axis tight
        if chan~=0
            line([timebase(first_artefact_index)  timebase(last_artefact_index)], [max_display_data(count_ch)-0.05*data_y_extent(count_ch)  max_display_data(count_ch)-0.05*data_y_extent(count_ch)], 'linewidth', 3, 'color', 'black');
        end
        %         axis on
    end
end
draw_cal_pclamp


str = strvcat('DO NOT SAVE Y-axis LIMITS', '----------------------------------', 'SAVE Y-axis LIMITS');
[s_savlim,v] = listdlg('PromptString','SAVE Y-AXIS LIMITS', 'SelectionMode','single','ListString',str,'listsize', [249 55]); %w h

if s_savlim == 3
    filename = strvcat([filename_avi  '_DISPLAY_LIMITS']);

    save_limits = inputdlg('Enter Filename','Save Data',1, {filename});
    save_limits = (save_limits{1});

    save(save_limits, 'max_display_data', 'min_display_data', 'min_df_over_f', 'max_df_over_f');
else
end



%% LOAD SAVED LIMITS

if s_savlim == 1
    str = strvcat('Load Saved Y-axis LIMITS', '----------------------------------', 'Do NOT Load Saved Y-axis LIMITS');
    [s_lim,v] = listdlg('PromptString','LOAD Y-AXIS LIMITS', 'SelectionMode','single','ListString',str,'listsize', [249 55]); %w h


    if s_lim == 1
        close(11)
        clear max_display_data min_display_data min_df_over_f max_df_over_f
        cd(dir_save_lims)

        [save_limits,dir_save_lims] = uigetfile('*.mat','Load the Saved Y-AXIS LIMITS'); cd(dir_save_lims); load(save_limits);
        process_log = strvcat(process_log, ' ', 'Y-AXIS LIMITS: ', dir_avi, ['Filename: ' 'save_limits']);
    else
    end
else
end %s_savlim ~= 3

%% PLOT ROI AND SELECTED DE-ARTEFACTED PCLAMP FILES ----- NON-SUBPLOT

% configure axes  - note that axes are constructed from the bottom up!

%The next operation is necessary because the neuro plots are now made from the bottom up so that the last plotted channel for the
% subplot IS THE FIRST PLOTTED CHANNEL




max_display_data = fliplr( max_display_data );
min_display_data = fliplr( min_display_data );
data_y_extent    = fliplr( data_y_extent );
disp_ch          = fliplr( disp_ch );  %disp_ch is the channel numbers to be displayed
plot_roi         = fliplr( plot_roi );


max_ch_num = length(channel_display);

last_neuro = data(:,disp_ch(1));

num_plots = num_display_chan + num_rois;


%% PLOT ROI ELECTRICAL

set(figure(12), 'color', 'white', 'doublebuffer', 'on', 'position',  [200 200 1.75*560  1.75*420]);

% num_plots=9
plot_height = .9/num_plots;
plot_width = 0.85;
plot_x = .05;
plot_y_init = 0.05;

h_axis(1) = axes('position', [plot_x plot_y_init  plot_width plot_height  ]); %[left, bottom, width, height];
plot(timebase,last_neuro)
text(.01, .9, [num2str(i) ' : ' channel_display(disp_ch(1)).names], 'units', 'normalized');
xlabel('Time (sec)', 'fontsize', 14);
axis tight
xlim([timebase(frame_start_index) timebase(frame_end_index)]);
ylim([min_display_data(1) max_display_data(1)]);

if chan~=0
    line([timebase(first_artefact_index)  timebase(last_artefact_index)], [max_display_data(1)-0.05*data_y_extent(1)  max_display_data(1)-0.05*data_y_extent(1)], 'linewidth', 3, 'color', 'black');
end
% axis off
draw_cal_pclamp

% plot remaining neuro channels
for i= 1:num_display_chan-1

    h_axis(i+1) = axes('position', [plot_x (plot_y_init + (i* plot_height)) plot_width plot_height ]);

    plot(timebase, data(:,disp_ch(i+1)))
    text(.01, .9, [num2str(max_ch_num-i) ' : ' channel_display(disp_ch(i+1)).names], 'units', 'normalized');
    xlim([timebase(frame_start_index) timebase(frame_end_index)]);
    ylim([min_display_data(i+1) max_display_data(i+1)]);
    %         axis off
    %     axis off
    box on
end

% Plot ROIs
for i= 1:num_rois

    h_axis(i+num_display_chan) = axes('position', [plot_x (plot_y_init + ((i+num_display_chan-1)* plot_height)) plot_width plot_height ]);


    plot(timebase_roi, plot_roi(:,i), 'color', cmap((num_rois+1-i)*cmap_mult,:), 'linewidth', 2)
    title_10=['ROI: ' num2str(num_rois+1-i)];
    text(.05, .8, title_10, 'units', 'normalized','color', cmap((num_rois+1-i)*cmap_mult,:));
    xlim([timebase_roi(1) timebase_roi(end)]);
    ylim([min_df_over_f max_df_over_f]);

    %     axis off

    if i==num_rois    %DRAW LINES CORRESPONDING TO ACTIVE AND CONTROL FRAMES AND DF/F Y CALIBRATION

        line([control_start control_finish], [min_df_over_f + df_over_f_y_extent*.01  min_df_over_f + df_over_f_y_extent*.01], 'linewidth', 2, 'color', 'black');
        line([active_start active_finish], [min_df_over_f + df_over_f_y_extent*.01 min_df_over_f + df_over_f_y_extent*.01], 'linewidth', 2, 'color', 'red');



        filename = strrep(filename, '_DISPLAY_LIMITS', '');
        fig_name = horzcat(filename, ' ROI ELECTRICAL');
        title(fig_name);
        draw_y_cal_df_over_d
    end
end



fig_name_axis_on = horzcat(fig_name, ' AXIS ON');

cd(cd_save_figs);
saveas(12, fig_name_axis_on, 'fig')



%% SAVE EMF WITHOUT AXES

set(figure(13), 'color', 'white', 'doublebuffer', 'on', 'position',  [200 200 1.75*560  1.75*420]);



% num_plots=9
plot_height = .9/num_plots;
plot_width = 0.85;
plot_x = .05;
plot_y_init = 0.05;

h_axis(1) = axes('position', [plot_x plot_y_init  plot_width plot_height  ]); %[left, bottom, width, height];
plot(timebase,last_neuro)
text(.01, .9, [num2str(i) ' : ' channel_display(disp_ch(1)).names], 'units', 'normalized');
xlabel('Time (sec)', 'fontsize', 14);
axis tight
xlim([timebase(frame_start_index) timebase(frame_end_index)]);
ylim([min_display_data(1) max_display_data(1)]);

if chan~=0
    line([timebase(first_artefact_index)  timebase(last_artefact_index)], [max_display_data(1)-0.05*data_y_extent(1)  max_display_data(1)-0.05*data_y_extent(1)], 'linewidth', 3, 'color', 'black');
end
axis on
draw_cal_pclamp

% plot remaining neuro channels
for i= 1:num_display_chan-1

    h_axis(i+1) = axes('position', [plot_x (plot_y_init + (i* plot_height)) plot_width plot_height ]);

    plot(timebase, data(:,disp_ch(i+1)))
    text(.01, .9, [num2str(max_ch_num-i) ' : ' channel_display(disp_ch(i+1)).names], 'units', 'normalized');
    xlim([timebase(frame_start_index) timebase(frame_end_index)]);
    ylim([min_display_data(i+1) max_display_data(i+1)]);
    axis off
    box on
end

% Plot ROIs
for i= 1:num_rois

    h_axis(i+num_display_chan) = axes('position', [plot_x (plot_y_init + ((i+num_display_chan-1)* plot_height)) plot_width plot_height ]);


    plot(timebase_roi, plot_roi(:,i), 'color', cmap((num_rois+1-i)*cmap_mult,:), 'linewidth', 2)
    title_10=['ROI: ' num2str(num_rois+1-i)];
    text(.05, .8, title_10, 'units', 'normalized','color', cmap((num_rois+1-i)*cmap_mult,:));
    xlim([timebase_roi(1) timebase_roi(end)]);
    ylim([min_df_over_f max_df_over_f]);
    axis off

    if i==num_rois    %DRAW LINES CORRESPONDING TO ACTIVE AND CONTROL FRAMES AND DF/F Y CALIBRATION

        line([control_start control_finish], [min_df_over_f + df_over_f_y_extent*.01  min_df_over_f + df_over_f_y_extent*.01], 'linewidth', 2, 'color', 'black');
        line([active_start active_finish], [min_df_over_f + df_over_f_y_extent*.01 min_df_over_f + df_over_f_y_extent*.01], 'linewidth', 2, 'color', 'red');
        title(fig_name);
        draw_y_cal_df_over_d
    end
end


% save emf figure
cd(cd_save_figs);

saveas(13, fig_name, 'emf')
saveas(13, fig_name, 'fig')

%% SAVE PROCESSED DATA NO MOVIES

cd(cd_save_figs)

filename = strvcat([filename_avi  '_AVI_PCLAMP_PROCESSED']);

% save_file = inputdlg('Enter Filename','Save Data',1, {filename});
% save_file=(save_file{1});


prompt = {'Enter Filename'};
dlg_title = 'Save Data';
num_lines = 1;
def = {filename};

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';


answer = inputdlg(prompt,dlg_title,num_lines,def,options);
save_file = answer{1};

if exist('temp_data')==1
    save(save_file, 'num_frames', 'timebase_roi','df_over_f', 'cmap','cmap_mult','timebase', 'data', 'temp_data', 'channel_display', 'interval','num_display_chan', 'num_rois', 'roi', 'count_roi',...
        'min_df_over_f', 'max_df_over_f', 'control_start', 'control_finish', 'df_over_f_y_extent', 'df_over_f_y_extent', 'active_start', 'active_finish',...
        'disp_ch', 'frame_start_index', 'frame_end_index', 'min_display_data', 'max_display_data', 'first_artefact_index', 'last_artefact_index', 'data_y_extent',...
        'control_average', 'process_log');
else
    save(save_file, 'num_frames', 'timebase_roi','df_over_f', 'cmap','cmap_mult','timebase', 'data', 'channel_display', 'interval','num_display_chan', 'num_rois', 'roi', 'count_roi',...
        'min_df_over_f', 'max_df_over_f', 'control_start', 'control_finish', 'df_over_f_y_extent', 'df_over_f_y_extent', 'active_start', 'active_finish',...
        'disp_ch', 'frame_start_index', 'frame_end_index', 'min_display_data', 'max_display_data', 'first_artefact_index', 'last_artefact_index', 'data_y_extent',...
        'control_average', 'process_log');
end



























%% CHANGE X-AXIS LIMITS
%
%
% str=strvcat('Do NOT change X-Axis limits', '-------------------------', 'CHANGE X-Axis limits');
% [s_x,v] = listdlg('PromptString','CHANGE X-AXIS', 'SelectionMode','single','ListString',str,'listsize', [180 50]); %w h
%
% if s_x == 3
%
%     new_x = inputdlg('Enter New Min and Max X-limits','Change X-axis',1, {'[ 0.5  30 ]'});
%     new_x = str2num(new_x{1});  %converts user input cell array to a number. Note index of the cell (interval) is 1.
%
%     x_start = new_x(1); %note times are in seconds
%     x_end   = new_x(2);
%
%     %convert to indicies
%     x_start_index = round( (x_start/interval)*1000 );
%     x_end_index   = round( (x_end/interval)*1000 );
%
%     clear frame_start_index frame_end_index
%     frame_start = find(max_frame_indicies >= x_start_index, 1, 'first');
%     frame_end   = find(max_frame_indicies >= x_end_index, 1, 'first');
%
%     frame_start_index = max_frame_indicies(frame_start);
%     frame_end_index   = max_frame_indicies(frame_end);
%
%
%
%     set(figure(13), 'color', 'white', 'doublebuffer', 'on', 'position',  [200 200 1.75*560  1.75*420]);
%
%     % num_plots=9
%     plot_height = .9/num_plots;
%     plot_width = 0.85;
%     plot_x = .05;
%     plot_y_init = 0.05;
%
%     h_axis(1) = axes('position', [plot_x plot_y_init  plot_width plot_height  ]); %[left, bottom, width, height];
%     plot(timebase,last_neuro)
%     text(.01, .9, [num2str(i) ' : ' channel_display(max_ch_num).names], 'units', 'normalized');
%     xlabel('Time (sec)', 'fontsize', 14);
%     axis tight
%     xlim([timebase(frame_start_index) timebase(frame_end_index)]);
%     ylim([min_display_data(1) max_display_data(1)]);
%
%     if chan~=0
%         line([timebase(first_artefact_index)  timebase(last_artefact_index)], [max_display_data(1)-0.05*data_y_extent(1)  max_display_data(1)-0.05*data_y_extent(1)], 'linewidth', 3, 'color', 'black');
%     end
%     axis on
%     draw_cal_pclamp
%
%     % plot remaining neuro channels
%     for i= 1:num_display_chan-1
%
%         h_axis(i+1) = axes('position', [plot_x (plot_y_init + (i* plot_height)) plot_width plot_height ]);
%
%         plot(timebase, data(:,disp_ch(i+1)))
%         text(.01, .9, [num2str(max_ch_num-i) ' : ' channel_display(max_ch_num-i).names], 'units', 'normalized');
%         xlim([timebase(frame_start_index) timebase(frame_end_index)]);
%         ylim([min_display_data(i+1) max_display_data(i+1)]);
%         axis on
%
%     end
%
%     % Plot ROIs
%     for i= 1:num_rois
%
%         h_axis(i+num_display_chan) = axes('position', [plot_x (plot_y_init + ((i+num_display_chan-1)* plot_height)) plot_width plot_height ]);
%
%
%         plot(timebase_roi, plot_roi(:,i), 'color', cmap((num_rois+1-i)*cmap_mult,:), 'linewidth', 2)
%         title_10=['ROI: ' num2str(num_rois+1-i)];
%         text(.05, .8, title_10, 'units', 'normalized','color', cmap((num_rois+1-i)*cmap_mult,:));
%         xlim([timebase_roi(frame_start) timebase_roi(frame_end)]);
%         ylim([min_df_over_f max_df_over_f]);
%         axis on
%
%         if i==num_rois    %DRAW LINES CORRESPONDING TO ACTIVE AND CONTROL FRAMES AND DF/F Y CALIBRATION
%
%             line([control_start control_finish], [min_df_over_f + df_over_f_y_extent*.01  min_df_over_f + df_over_f_y_extent*.01], 'linewidth', 2, 'color', 'black');
%             line([active_start active_finish], [min_df_over_f + df_over_f_y_extent*.01 min_df_over_f + df_over_f_y_extent*.01], 'linewidth', 2, 'color', 'red');
%
%             draw_y_cal_df_over_d
%         end
%     end
%
%     cd(dir_avi);
%
%     fig_file = strrep(filename, '_DISPLAY_LIMITS', '_ROI_ELECTRICAL.fig');
%     saveas(13, fig_file, 'fig')
%
%
% else  %Dont Change X axis
%
%     cd(dir_avi);
%
%     fig_file = strrep(filename, '_DISPLAY_LIMITS', '_ROI_ELECTRICAL.fig');
%     saveas(12, fig_file, 'fig')
%
%
%
% end %'CHANGE X-Axis limits'













%save data for use in make_movie_on_cord_intracellular
%
% %*******************
% %SAVE PROCESSED DATA
% %*******************
% cd(dir_avi)
% %    cd .. %change directory to parent
% %    parent_dir=cd; %save parent directory name in parent_dir
% %    target_dr=strvcat([parent_dir '\processed_data\matlab']); %create directory name corresponding to target directory
% %
% %    cd(target_dr);
% %
%
% filename=strvcat([filename_avi  '_AVI_PCLAMP_PROCESSED']);
%
% save_file = inputdlg('Enter Filename','Save Data',1, {filename});
% save_file=(save_file{1});
%
%
% if exist('temp_data')==1
%     save(save_file, 'num_frames', 'timebase_roi','df_over_f', 'cmap','cmap_mult','timebase', 'data', 'temp_data', 'channel_display', 'interval','num_display_chan', 'num_rois', 'roi', 'count_roi',...
%         'min_df_over_f', 'max_df_over_f', 'control_start', 'control_finish', 'df_over_f_y_extent', 'df_over_f_y_extent', 'active_start', 'active_finish',...
%         'disp_ch', 'frame_start_index', 'frame_end_index', 'min_display_data', 'max_display_data', 'first_artefact_index', 'last_artefact_index', 'data_y_extent',...
%         'control_average', 'process_log', 'mov_store' );
% else
%     save(save_file, 'num_frames', 'timebase_roi','df_over_f', 'cmap','cmap_mult','timebase', 'data', 'channel_display', 'interval','num_display_chan', 'num_rois', 'roi', 'count_roi',...
%         'min_df_over_f', 'max_df_over_f', 'control_start', 'control_finish', 'df_over_f_y_extent', 'df_over_f_y_extent', 'active_start', 'active_finish',...
%         'disp_ch', 'frame_start_index', 'frame_end_index', 'min_display_data', 'max_display_data', 'first_artefact_index', 'last_artefact_index', 'data_y_extent',...
%         'control_average', 'process_log', 'mov_store' );
% end
