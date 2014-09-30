%% MATLAB M-file fractal.m
iterations=25000;
Mat1=[0 0;0 0.16];
Mat2=[0.85 0.04;-0.04 0.85];
Mat3=[0.2 -0.26;0.23 0.22];
Mat4=[-0.15 0.28;0.26 0.24];
Vector1=[0;0];
Vector2=[0;1.6];
Vector3=[0;1.6];
Vector4=[0;0.44];
Prob1=0.01;
Prob2=0.85;
Prob3=0.07;
Prob4=0.07;
P=[0;0];
starttime=cputime;
for counter = 1:iterations
  prob=rand;
  if prob<Prob1 
     P=Mat1*P+Vector1;
  elseif prob<Prob1+Prob2
     P=Mat2*P+Vector2;
  elseif prob<Prob1+Prob2+Prob3
     P=Mat3*P+Vector3;
  else
     P=Mat4*P+Vector4;
  end
x(counter)=P(1);
y(counter)=P(2);
end
plot(x,y,'g.')

axis equal; axis off;
title([int2str(iterations),' iterations'],'Color','red','FontSize',24);
elapsedtime=cputime-starttime;
fprintf('Execution time was %g seconds.\n', elapsedtime)