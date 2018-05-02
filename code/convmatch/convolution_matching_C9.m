function [poses] = convolution_matching_C9(inVols,inVolsC2,psf,initVol,angleSampling,rangeShift,posesGt,symmetry)

nbVols = length(inVols);
poses = zeros(nbVols,6);
sz = size(inVols{1});

sizePad=(size(inVols{1})-size(psf))/2;
psf=padarray(psf,sizePad);
psf=fftshift(psf);
H=LinOpConv(psf);

%% Discretization parameters
angleInit = 0;
angleEnd = 360;

rotInitC9 = angleInit;
rotEndC9 = angleEnd;
tiltInitC9 = angleInit;
tiltEndC9 = angleEnd;
psiInitC9 = angleInit;
if strcmp(symmetry,'C1')
    psiEndC9 = angleEnd;
elseif strcmp(symmetry,'C9') 
    psiEndC9 = angleEnd/9;
elseif strcmp(symmetry,'C20') 
    psiEndC9 = angleEnd/20;
end

nbDiscretePoses = floor((rotEndC9-rotInitC9)/angleSampling + 1) * floor((tiltEndC9-tiltInitC9)/angleSampling + 1) * floor((psiEndC9-psiInitC9)/angleSampling + 1);

%% Create Library
%%%%%%%% Create list of angles
listPoses = zeros(nbDiscretePoses,3);
i_angle = 0;
for rot=rotInitC9:angleSampling:rotEndC9
    for tilt=tiltInitC9:angleSampling:tiltEndC9
        for psi=psiInitC9:angleSampling:psiEndC9
            i_angle = i_angle + 1;
            listPoses(i_angle,:) = [rot,tilt,psi];
        end
    end
end

%%%%%%%% Create c9 restricted volume library
fprintf('Projections in c9 symmetry range');
t = cputime;
volsLibrary = cell(nbDiscretePoses,1);
parfor iAngle=1:nbDiscretePoses
    angles = listPoses(iAngle,:);
    rot = angles(1); tilt = angles(2); psi = angles(3);
    
    rotRecon = rotVolClean(initVol,rot,tilt,psi);

    convRotRecon = H*rotRecon;
    
    volsLibrary{iAngle} = convRotRecon;
end
e = cputime-t;
fprintf(' - %.2f sec\n', e);

fprintf('Estimate poses');
t = cputime;

%% Matching
iAngleLibList=zeros(nbVols);

nbPixs=sz(1)*sz(2)*sz(3); 

%%%%%%%%% Angle Search
w=window3(size(inVols{1}),'hanning',-1);
for i_vol=1:nbVols
    yi = inVols{i_vol}.*w;
    minE = 1e+50;
    for iVolLib=1:length(volsLibrary)
        a=volsLibrary{iVolLib}.*w;

        %%%%%%%%% Registration
        out=dftregistration3D(fftn(yi),fftn(a),1);
        dist=out(1);

        if dist<minE
            minE = dist;
            iAngleLibList(i_vol) = iVolLib;
            shift = [out(4),out(3),out(5)];
        end
    end
    poses(i_vol,1:3) = listPoses(iAngleLibList(i_vol),:);
    poses(i_vol,4:6) = shift;
end
