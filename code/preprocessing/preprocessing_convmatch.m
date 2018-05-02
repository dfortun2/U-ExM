function [outVolsC1,outVolsC2,outPsf1,outPsf2,outInitVol] = preprocessing_convmatch(inVolsC1,inVolsC2,psf1,psf2,initVol,downsampling,sizeCrop)

%% Downsample
sizeDown = floor(size(inVolsC1{1})*downsampling) + mod(floor(size(inVolsC1{1})*downsampling),2);
inVolsC1Down = cell(length(inVolsC1)); 
inVolsC2Down = cell(length(inVolsC1)); 
for i=1:length(inVolsC1)
    inVolsC1Down{i} = resizeVol(inVolsC1{i},[sizeDown(1),sizeDown(2),sizeDown(3)]);
    inVolsC2Down{i} = resizeVol(inVolsC2{i},[sizeDown(1),sizeDown(2),sizeDown(3)]);
end
initVolDown = resizeVol(initVol,[sizeDown(1),sizeDown(2),sizeDown(3)]);
sizeDown = floor(size(psf1)*downsampling) + mod(floor(size(psf1)*downsampling)+1,2);
psfDown = resizeVol(psf1,sizeDown);
psfDown=psfDown/sum(psfDown(:));

sizeCropPsf=min(size(psfDown),sizeCrop);
psfDown=crop_fit_size_center(psfDown,sizeCropPsf);
psfDown=adjust_size_even(psfDown);

%% Crop
if sizeCrop~=-1
    inVolsC1Crop = cell(length(inVolsC1));
    inVolsC2Crop = cell(length(inVolsC1));
    for i=1:length(inVolsC1)
        inVolsC1Crop{i}=crop_fit_size_center(inVolsC1Down{i},sizeCrop);
        inVolsC2Crop{i}=crop_fit_size_center(inVolsC2Down{i},sizeCrop);
    end
    initVolCrop=crop_fit_size_center(initVolDown,sizeCrop);
else
    inVolsC1Crop=inVolsC1Down;
    inVolsC2Crop=inVolsC2Down;
    initVolCrop=initVolDown;
end

outVolsC1 = inVolsC1Crop;
outVolsC2 = inVolsC2Crop;
outInitVol = initVolCrop;
outPsf1 = psfDown;
outPsf2 = psfDown;
