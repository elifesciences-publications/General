function aux01 = neurosetup(data)

B = 1:length(data(:,1));
C = data(:,1)==50;
index2 = B(C);
if(length(index2)==0)
    B = 1:length(data(:,1));
    C = data(:,1)==51;
    index2 = B(C);
end

aux01 = cell(1,(length(index2)-1));
for(j = 2:length(index2) ) 
  data0 = data(((index2((j-1))+1):(index2(j)-1)),:);
  B = 1:length(data0(:,1));
  C = data0(:,1)==8;
  index = B(C);
  time0 = data0(index,2);
  start = time0 - 400;
  end2   = time0 + 750;
  data0 = data0(((data0(:,2) > start) & (data0(:,2) < end2) ) ,:);
  data0(:,2) = data0(:,2)-time0;
  data0 = data0(data0(:,1)==1, 2);
  if( length(data0)>0 )
      aux01{1,(j-1)} = data0;
  end
end

  
  