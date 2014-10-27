
function mat3d = zstackmats(varargin)
mat3d = [];
nmats = nargin;
if nmats <2
    errordlg('There is only matrix input!')
end

counter = 0;
for ss = 1:nmats
    counter = counter + 1;
    mat3d(:,:,ss) = varargin{ss};
    if counter>1
        currentSize = size(varargin{ss});
        prevSize = size(varargin{ss-1});
        if currentSize ~= prevSize
            errordlg('2D matrices of difference sizes cannot be z-stacked!')
        end
    end
end