
function WriteLSVideo(aveResponseImg, baselineImg, dff5secImg, nRows, nCols, movName,output_dir)

  %% Videowriter
   stackDim = size(aveResponseImg);
    currentPath = cd;
    cd(output_dir)
    monSize = getMonitorSize;
   
    figure('units','pixels','outerposition',[0 0 monSize(3)-0.1*monSize(3) monSize(4)-0.1*monSize(4)]);    
    writerObj = VideoWriter(movName,'Uncompressed AVI');
    writerObj.FrameRate = 5;
    open(writerObj);    
    for i = 1:size(aveResponseImg,4)
        f1 = (aveResponseImg(:,:,:,i)./baselineImg)-1; 
        gcf;
        h = imagesc(reshape(permute(reshape(f1,[stackDim(1) stackDim(2) nRows nCols]), [1 4 2 3]), ...
            [stackDim(1)*nCols, stackDim(2)*nRows]),[-0.2 0.5]);
        
        axis off;
        axis image;
        title(['frame no: ', int2str(i)]);
        colorbar;
        colormap gray;
        set(gca,'Units','normalized','Position',[0.025 0.025 0.95 0.95]);
        %     F(i) = getframe(gcf);
        frame = getframe(gcf);
        writeVideo(writerObj,frame);
    end
    
    % movie(F,20);
    close(writerObj);
    
     %% dff
    fprintf('\n Creating dff stack \n')
    dff = zeros(stackDim(1)*nCols, stackDim(2)*nRows,size(aveResponseImg,4));
    for i = 1:size(aveResponseImg,4)
        f1 = (aveResponseImg(:,:,:,i)./baselineImg)-1;
        dff(:,:,i) = reshape(permute(reshape(f1,[stackDim(1) stackDim(2) nRows nCols]), [1 4 2 3]), [stackDim(1)*nCols, stackDim(2)*nRows]);
    end
    fh = fopen(['dff_' movName '.bin'],'w');
    fwrite(fh, dff,'double');
    fclose(fh);
    fprintf('\n Done! \n')
    
    %% stflat
    fprintf('\n Creating stflat stack \n')
    stflat = zeros(stackDim(1)*nCols, stackDim(2)*nRows,size(aveResponseImg,4));
    for i = 1:size(aveResponseImg,4)
        stflat(:,:,i) = reshape(permute(reshape((baselineImg-min(baselineImg(:)))/max(baselineImg(:)),[stackDim(1) stackDim(2) nRows nCols]), [1 4 2 3]), [stackDim(1)*nCols, stackDim(2)*nRows]);
    end
    fh = fopen(['stflat_' movName '.bin'],'w');
    fwrite(fh, stflat,'double');
    fclose(fh);
    fprintf('\n Done! \n')
    
    %%
    dffPlus= zeros(stackDim);dffNegative = zeros(stackDim);
    plusIndex = dff5secImg(:)>0.02;
    negIndex = dff5secImg(:)<-0.02;
    dffPlus(plusIndex) = dff5secImg(plusIndex);
    dffNegative(negIndex) = -dff5secImg(negIndex);
    
    nor_dffPlus = dffPlus/0.5;
    nor_dffNegative = dffNegative/0.5;
    
    figure('position', [0 0 1600*stackDim(2)/stackDim(1) 1600]);
    imagesc(baselineImg(:,:,24));
    axis image;
    axis off;
    set(gca,'Units','normalized', 'Position', [0 0 1 1]);
    
    movName = [fName '_' timeStamp '_ResponseMap.avi'];
    writerObj = VideoWriter(movName,'Uncompressed AVI');
    writerObj.FrameRate = 1;
    open(writerObj);
    stImg = (baselineImg-min(baselineImg(:)))/max(baselineImg(:));
    for i = 1:size(baselineImg,3)
        imagesc(stImg(:,:,i),[0 0.5]);
        colormap(gray);
        axis image;
        axis off;
        set(gca,'Units','normalized','Position',[0 0 1 1]);
        hold on;
        
        red = cat(3, ones(stackDim(1:2)),zeros(stackDim(1:2)),zeros(stackDim(1:2)));
        green = cat(3, zeros(stackDim(1:2)),ones(stackDim(1:2)),zeros(stackDim(1:2)));
        
        h_red = imshow(red);
        set(h_red,'AlphaData',nor_dffPlus(:,:,i));
        
        h_green = imshow(green);
        set(h_green,'AlphaData',nor_dffNegative(:,:,i));
        hold off;
        
        frame = getframe;
        writeVideo(writerObj,frame);
    end
    
    close(writerObj);
    
    cd(currentPath) 
     
    
    
    
end
    
    
    
    
    


