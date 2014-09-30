function rectData = rectify(data);
rectData=data;
rectData(find(rectData<0))=0;
