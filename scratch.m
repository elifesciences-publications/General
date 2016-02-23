
%% Estimating turns with respect to prev swim direction vectors
turnAngleThr = 5;

clear i
tracexy_motion = tracexy(motionFrames,:);
motionVecs = diff(tracexy_motion);
motionVecs = motionVecs(:,1) + motionVecs(:,2)*i;
dTh = angle(motionVecs(1:end-1).*conj(motionVecs(2:end)));
dTh_motion = [0; dTh(:)]*180/pi;
dS_motion = abs(motionVecs);

dS_rightInds = find(dTh_motion < -turnAngleThr);
dS_leftInds = find(dTh_motion > turnAngleThr);
dS_straightInds = find(abs(dTh_motion) <= turnAngleThr);

dS_left = dS_motion(dS_leftInds);
dS_right = dS_motion(dS_rightInds);
dS_straight = dS_motion(dS_straightInds);

[dS_left_count, dS_left_vals] = hist(dS_left,50);
[dS_right_count, dS_right_vals] = hist(dS_right,50);
[dS_straight_count, dS_straight_vals] = hist(dS_straight);

ker = gausswin(3); ker = ker/sum(ker);
dS_left_count = conv2(dS_left_count(:),ker(:),'same');
dS_left_count = [0; dS_left_count(:)];
dS_left_vals = [0; dS_left_vals(:)];

dS_right_count = conv2(dS_right_count(:),ker(:),'same');
dS_right_count = [0; dS_right_count(:)];
dS_right_vals = [0; dS_right_vals(:)];

dS_straight_count = conv2(dS_straight_count(:),ker(:),'same');
dS_straight_count = [0; dS_straight_count(:)];
dS_straight_vals = [0; dS_straight_vals(:)];

%% Some Plotting
figure('Name','Distribution of swim distances between moving frames sorted by turn direction')
plot(dS_left_vals,dS_left_count,'linewidth',2)
hold on
plot(dS_right_vals,dS_right_count,'r','linewidth',2)
plot(dS_straight_vals,dS_straight_count,'k','linewidth',2)
legend('Left','Right','Straight')
xlim([0 40])
ylim([-inf inf])
xlabel('Swim distance between moving frames')
ylabel('Count')
box off
title('Distribution of swim distances between subsequent moving frames sorted by turn direction')
