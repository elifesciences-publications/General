
% freqResolution = 1;
% 
% if size(x,1)< size(x,2)
%     x = x';
% end
% Fs = 1/samplingInt;
% h = hamming(length(x));
% xp = x.*h;
% % zp  = zeros((2^nextpow2(length(x)/20))/2,1);
% % xp = [zp(:); x(:); zp(:)];
% y = fft(xp);
% 
% f = 0.5*Fs*linspace(0,1,length(x));
% df = mode(diff(f));
% kerLen = round(freqResolution/df);
% ker = gausswin(kerLen); ker = ker/sum(ker);
% y_smooth = conv2(y(:), ker(:),'same');
% x_post = abs(ifft(y_smooth));

% zpLen = length(zp);
% xLen = length(x);
% 
% x_post(1:zpLen) = [];
% x_post(xLen+1:end) = [];






% x_post = x_post(1:nfft/2,:,:);

% y=2*abs(y(1:nfft/2,:,:)); % Why scale with 2 ????


function yy = triginterpol(y,xx)  
N = numel(y);
M = N/2;  
z = dft(y);  
A_0 = 2*z(1);
A_M = 2*z(M);  
n = length(xx);
yy = zeros(1,n);
A_l = zeros(1,M);
B_l = zeros(1,M);
 for a = 1:n %loop over all x's that need to be calculated
     zz = 0; %assist variable
     for l = 1:M-1
         A_l(l) =      z(l+1) + z(N-l+1);
         B_l(l) = 1i.*(z(l+1) - z(N-l+1));
         zz = zz+(A_l(l).*cos(l.*xx(a)) + B_l(l).*sin(l.*xx(a)));
     end
     yy(a) = A_0/2 + zz + (A_M/2.*cos(M.*xx(a)));
 end  
end