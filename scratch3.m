
%%
imgNum = 560;
blah = IM(:,:,imgNum);
blah  = max(blah(:))-blah;
%blah(blah<intThr)=0;
startPt = fishPos(imgNum,:);

lineLens = [15 15 15 10 10 8 5 5];
lineInds = {};
for jj = 1:length(lineLens)
  if jj ==1
%       lineInds{jj} = GetLineToEdge(blah,startPt,[],[],lineLens(jj));
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
end
% lineInds = GetLineToEdge(blah,fishPos(560,:));

%%
inds = [];
for jj = 1:length(lineInds)
    inds = [inds; lineInds{jj}];
end

blah2 = blah;
blah2(inds) = max(blah(:))*0.9;
figure
imagesc(blah2),axis image