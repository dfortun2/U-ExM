function [poses] = convolution_matching_C9_refine(inVols,inVolsC2,psf,initVol,poses,angle_sampling,angle_range,posesGt,varargin)

nbVols = length(inVols);
sz = size(inVols{1});

sizePad=(size(inVols{1})-size(psf))/2;
psf=padarray(psf,sizePad);
psf=fftshift(psf);
H=LinOpConv(psf);

%% Discretization parameters
shift_sampling = 0;
angle_init = -angle_range;
angle_end = angle_range;
shiftInit = -2;
shiftEnd = 2;
shiftInitXY = -10;
shiftEndXY = 10;
shiftInitZ = -5;
shiftEndZ = 5;

nbDiscretePoses = round((angle_end-angle_init)/angle_sampling+1)^3;

%% Create Library
%%%%%%%% Create list of angles
listPoses = zeros(nbVols,nbDiscretePoses,3);
for i=1:nbVols
    rot = poses(i,1);
    tilt = poses(i,2);
    psi = poses(i,3);
    iAngle = 0;
    for rotNew=rot+angle_init:angle_sampling:rot+angle_end
        for tiltNew=tilt+angle_init:angle_sampling:tilt+angle_end
            for psiNew=psi+angle_init:angle_sampling:psi+angle_end
                iAngle = iAngle + 1;
                listPoses(i,iAngle,:) = [mod(rotNew,360),mod(tiltNew,360),mod(psiNew,360)];
            end
        end
    end
end

%%%%%%%% Create volume library
fprintf('Projections in c9 symmetry range');
t = cputime;
volsLibrary = cell(nbVols,nbDiscretePoses);
for i=1:nbVols
    parfor j=1:nbDiscretePoses
%    for j=1:nbDiscretePoses
        angles = listPoses(i,j,:);
        rot = angles(1); tilt = angles(2); psi = angles(3);

        rotRecon = rotVolClean(initVol,rot,tilt,psi);

        convRotRecon = H*rotRecon;

        volsLibrary{i,j} = convRotRecon;
    end
end
e = cputime-t;
fprintf(' - %.2f sec\n', e);

fprintf('Estimate poses');
t = cputime;

%% Matching
iAngleLibList=zeros(nbVols);

%%%%%%%%% Shift search variables
nbPixs=sz(1)*sz(2)*sz(3); 

w=window3(size(inVols{1}),'hanning',-1);
for iVol=1:nbVols
    yi = inVols{iVol}.*w;
    minE = 1e+50;
    for iVolLib=1:nbDiscretePoses
        a=volsLibrary{iVol,iVolLib};
        %%%%%%%%% Registration
        out=dftregistration3D(fftn(yi),fftn(a),1);
        dist=out(1);

        if dist<minE
            minE = dist;
            iAngleLibList(iVol) = iVolLib;
            shift = [out(4)-1,out(3)-1,out(5)];
        end
    end
    poses(iVol,1:3) = listPoses(iVol,iAngleLibList(iVol),:);
    poses(iVol,4:6) = shift;
end

e = cputime-t;
fprintf(' - %.2f sec\n', e);
