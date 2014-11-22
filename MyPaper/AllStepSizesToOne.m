function out = AllStepSizesToOne(in)
% Anytime in(x+1)~=in(x), set in(x+1) = in(x)+1 until next step

out = in;
f = find(in(2:end)~=in(1:end-1));
out(1:f(1)) = 1;
for jj = 1:numel(f)-1
    out(f(jj)+1:f(jj+1)) = out(f(jj)) + 1; 
end
out(f(end)+1:end) = out(f(end)); 