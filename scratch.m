

maskDir = 'S:\Avinash\SPIM\Alx\9-12-2015-AlxRG-relaxed-dpf4\Fish1\preExptStack_lowRes_20150912_164446\TM00000'
maskFName = 'TM00000_CM0_CHN01.tif';

I = ReadImgStack(fullfile(maskDir,maskFName));

mask = Standardize(medfilt2(I,[3 3]));
mask(mask <= 0.1) = 0;
mask(mask > 0.1) = 1;