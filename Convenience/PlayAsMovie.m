function PlayAsMovie(M, varargin)
%PlayMatrixAsMovie Given a 3- or 4D matrix, plays images as movie with specified 
% pause duration between images
% PlayMovie(M);
% PlayMovie(M,'pauseDur',pauseDur,'clrMap',clrMap)
% 

pauseDur = 0;
clrMap = gray;

for jj = 1:numel(varargin)
    if ischar(varargin{jj})
        switch lower(varargin{jj})
            case 'pausedur'
                pauseDur =  varargin{jj+1};
            case 'clrmap'
                clrMap = varargin{jj+1};
        end
    end
end

fh = figure('Name','Movie');
colormap(clrMap)
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


