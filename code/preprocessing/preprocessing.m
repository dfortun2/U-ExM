function [outVolsC1,outVolsC2,outPsf1,outPsf2] = preprocessing(inVolsC1,inVolsC2,psf1,psf2,downsampling,sizeCrop)

%% Equalization
inVolsC1 = midwayN3D_cell(inVolsC1);
inVolsC2 = midwayN3D_cell(inVolsC2);

%% Downsample
sizeDown = floor(size(inVolsC1{1})*downsampling) + mod(floor(size(inVolsC1{1})*downsampling),2);
inVolsC1Down = cell(length(inVolsC1)); 
inVolsC2Down = cell(length(inVolsC1)); 
for i=1:length(inVolsC1)
    inVolsC1Down{i} = resizeVol(inVolsC1{i},[sizeDown(1),sizeDown(2),sizeDown(3)]);
    inVolsC2Down{i} = resizeVol(inVolsC2{i},[sizeDown(1),sizeDown(2),sizeDown(3)]);
end
sizeDown = floor(size(psf1)*downsampling) + mod(floor(size(psf1)*downsampling)+1,2);
psfDown = resizeVol(psf1,sizeDown);
psfDown=psfDown/sum(psfDown(:));
psfDown=adjust_size_even(psfDown);

%% Crop
if sizeCrop~=-1
    inVolsC1Crop = cell(length(inVolsC1));
    inVolsC2Crop = cell(length(inVolsC1));
    for i=1:length(inVolsC1)
        inVolsC1Crop{i}=crop_fit_size_center(inVolsC1Down{i},sizeCrop);
        inVolsC2Crop{i}=crop_fit_size_center(inVolsC2Down{i},sizeCrop);
    end
else
    inVolsC1Crop=inVolsC1Down;
    inVolsC2Crop=inVolsC2Down;
end

if size(inVolsC1Crop{1},3)<size(psfDown,3)
    psfDown=crop_fit_size_center(psfDown,[size(psfDown,1),size(psfDown,2),size(inVolsC1Crop{1},3)]);
end

%% Adjust size (must be even)
psfPad=adjust_size_even(psfDown);

%% Output
outVolsC1 = inVolsC1Crop;
outVolsC2 = inVolsC2Crop;
outPsf1 = psfPad;
outPsf2 = psfPad;
