function Aout = readGeciData(filename)

hTif = Tiff(filename);
Aout = zeros(512,512, 4000, 'int16');
for i=1:4000
    hTif.setDirectory(i);
    Aout(:,:,i) = hTif.read();
end

    
    
    