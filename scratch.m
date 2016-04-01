
% %% Estimating turns with respect to prev swim direction vectors
% turnAngleThr = 5;
%
% clear i
% tracexy_motion = tracexy(motionFrames,:);
% motionVecs = diff(tracexy_motion);
% motionVecs = motionVecs(:,1) + motionVecs(:,2)*i;
% dTh = angle(motionVecs(1:end-1).*conj(motionVecs(2:end)));
% dTh_motion = [0; dTh(:)]*180/pi;
% dS_motion = abs(motionVecs);
%
% dS_rightInds = find(dTh_motion < -turnAngleThr);
% dS_leftInds = find(dTh_motion > turnAngleThr);
% dS_straightInds = find(abs(dTh_motion) <= turnAngleThr);
%
% dS_left = dS_motion(dS_leftInds);
% dS_right = dS_motion(dS_rightInds);
% dS_straight = dS_motion(dS_straightInds);
%
% [dS_left_count, dS_left_vals] = hist(dS_left,50);
% [dS_right_count, dS_right_vals] = hist(dS_right,50);
% [dS_straight_count, dS_straight_vals] = hist(dS_straight);
%
% ker = gausswin(3); ker = ker/sum(ker);
% dS_left_count = conv2(dS_left_count(:),ker(:),'same');
% dS_left_count = [0; dS_left_count(:)];
% dS_left_vals = [0; dS_left_vals(:)];
%
% dS_right_count = conv2(dS_right_count(:),ker(:),'same');
% dS_right_count = [0; dS_right_count(:)];
% dS_right_vals = [0; dS_right_vals(:)];
%
% dS_straight_count = conv2(dS_straight_count(:),ker(:),'same');
% dS_straight_count = [0; dS_straight_count(:)];
% dS_straight_vals = [0; dS_straight_vals(:)];
%
% %% Some Plotting
% figure('Name','Distribution of swim distances between moving frames sorted by turn direction')
% plot(dS_left_vals,dS_left_count,'linewidth',2)
% hold on
% plot(dS_right_vals,dS_right_count,'r','linewidth',2)
% plot(dS_straight_vals,dS_straight_count,'k','linewidth',2)
% legend('Left','Right','Straight')
% xlim([0 40])
% ylim([-inf inf])
% xlabel('Swim distance between moving frames')
% ylabel('Count')
% box off
% title('Distribution of swim distances between subsequent moving frames sorted by turn direction')

%% Shuffling
% Plot original
traj_shuffle = motionInfo.traj_adj;
figure('Name','Original')
for jj = 2:length(traj_shuffle)
    plot(traj_shuffle{jj}(:,1),traj_shuffle{jj}(:,2))
    hold on
end
axis image
shg

%%  Shuffle
nIter = 1;
for kk = 1:nIter
    rp = randperm(length(traj_shuffle)-1);
    rp(rp==1)=[];
    p_left = 0.3;
    p_right = 1-p_left;
    leftLen = round(p_left*(length(traj_shuffle)-1));
    for jj = 2:length(traj_shuffle)
        if jj <= leftLen
            ind = min(length(traj_shuffle{rp(jj)}(:,1)),3);
            blah = traj_shuffle{rp(jj)}(ind,1);
            if blah > 0
                traj_shuffle{rp(jj)}(:,1) = - traj_shuffle{rp(jj)}(:,1);
            end
            
            %             traj_shuffle{rp(jj)}(:,1) = - traj_shuffle{rp(jj)}(:,1);
        end
        ind = min(length(traj_shuffle{jj}(:,1)));
        blah = traj_shuffle{jj}(ind,2);
        if blah < 0
            r = rand(1);
            if r< 0.5
                disp('y fixed')
                disp(num2str(jj))
                traj_shuffle{jj}(:,2) = -1*traj_shuffle{jj}(:,2);
            end
        end
    end
    axis image
    disp('Shuffled')
end

%% Plot shuffled
figure('Name','Shuffled')
for jj = 2:length(traj_shuffle)
    plot(traj_shuffle{jj}(:,1),traj_shuffle{jj}(:,2))
    hold on
end
axis image
shg

%% Adjust traj angle based on traj
motionInfo.traj_adj = traj_shuffle;
traj_angle = motionInfo.traj_angle;
for jj = 2:length(motionInfo.traj_adj)
    c = motionInfo.traj_adj{jj}(end,1) + motionInfo.traj_adj{jj}(end,2)*1i;
    if abs(c)== 0
        traj_angle(jj) = nan;
    else
        traj_angle(jj) = angle(c)*180/pi;
    end
end
motionInfo.traj_angle = traj_angle;
disp('Adjusted angles')


