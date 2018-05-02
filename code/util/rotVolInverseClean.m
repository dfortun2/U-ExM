function outVol = rotVolInverseClean(inVol,rot,tilt,psi)

sz = size(inVol);
s = max(sz);

%% Rotation matrix
rotMat = eulerAnglesToRotation3d_zxz(rot,tilt,psi);
rotMat = rotMat(1:3,1:3)';

%% Padding
inVolPad = zeros([round(2 * s)+1, round(2 * s)+1, round(2 * s)+1]);
ss = floor((round(2*s)+1 - sz) / 2);
inVolPad(ss(1)+2:ss(1)+sz(1)+1, ss(2)+2:ss(2)+sz(2)+1, ss(3)+2:ss(3)+sz(3)+1) = inVol;

[nd1, nd2, nd3] = size(inVolPad);
cx=(nd1+1)/2; cy=(nd2+1)/2; cz=(nd3+1)/2;

%% Rotation - coordinates
ii = zeros(size(inVolPad));
idx = find( ~ii );
[x,y,z] = ind2sub (size(inVolPad) , idx ) ;

xyzRot = [x(:)-cx,y(:)-cy,z(:)-cz]*rotMat;

xyzRot = xyzRot+[cx cy cz];
xRot = xyzRot(:,1); yRot = xyzRot(:,2); zRot = xyzRot(:,3);

%% Rotation - volume
outVol = interp3(inVolPad, yRot, xRot, zRot, 'linear');
outVol = reshape(outVol, size(inVolPad));

%% Crop
outVol = crop_fit_size_center(outVol,[s,s,s]);

end
