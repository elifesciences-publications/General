function PlayAsMovie(M, varargin)
%PlayMatrixAsMovie Given a 3- or 4D matrix, plays images as movie with specified 
% pause duration between images
% PlayMovie(M);
% PlayMovie(M,pauseDir)
% 

pauseDur = 0;
if nargin >1
    pauseDur = varargin{1};
end

fh = figure('Name','Movie');
colormap(gray)
if ndims(M)==3
    for jj = 1:size(M,3)
        figure(fh)
        imagesc(M(:,:,jj)), axis image
        axis off
        title(num2str(jj))
        drawnow
        if isempty(pauseDur)
            pause()
        else
            pause(pauseDur)
        end
    end
else
    for jj = 1:size(M,4)
        figure(fh)       
        imagesc(M(:,:,:,jj)),axis image
        axis off
        title(num2str(jj))
        drawnow
         if isempty(pauseDur)
            pause()
        else
            pause(pauseDur)
        end
    end
end

end


