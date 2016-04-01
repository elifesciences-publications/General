% %% Testing fish rotation by plotting images
% figure

%%
figure
imgList = 1:size(IM,3);
% imgList = 203;
for imgNum = imgList(:)'
    blah = IM(:,:,imgNum);
    blah  = max(blah(:))-blah;
    %blah(blah<intThr)=0;
    startPt = fishPos(imgNum,:);
    
    lineLens = [16 15 14 10 10 8];
    lineInds = {};
    for jj = 1:length(lineLens)
        if jj ==1
            %       lineInds{jj} = GetLineToEdge(blah,startPt,[],[],lineLens(jj));
            startPt = fishPos(imgNum,:);
            lineInds{jj} = GetMidline(blah,startPt,[],[],lineLens(jj));
        else
            %       lineInds{jj} = GetLineToEdge(blah,startPt,prevStartPt,[],lineLens(jj));
            lineInds{jj} = GetMidline(blah,startPt,prevStartPt,[],lineLens(jj));
        end
        if jj ==3
            a = 1;
        end
        si = lineInds{jj}(end);
        [r,c] = ind2sub(size(blah),si);
        x = c;
        y = r;
        prevStartPt = startPt;
        startPt = [x,y];
        img = blah;
        
    end
    cla
    for kk = 1:length(lineInds)
        img(lineInds{kk}) = max(im(:));
        imagesc(img),axis image
    end
    hold on
    plot(fishPos(imgNum,1),fishPos(imgNum,2),'k*')
    title(num2str(imgNum))
    shg
    % pause(0.12)
end
% lineInds = GetLineToEdge(blah,fishPos(560,:));

%%