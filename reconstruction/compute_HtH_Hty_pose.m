function [HtH,FHty] = compute_HtH_Hty_pose(y,psf,pose)

hTheta = bigfluo_apply_pose_inversePSF(psf,pose);
yTheta = bigfluo_apply_pose_inverse(y,pose);

sizePad=(size(yTheta)-size(hTheta))/2;
hTheta=padarray(hTheta,sizePad);
H=LinOpConv((hTheta));         

HtH = abs(conj(H.mtf).*H.mtf);
FHty = (conj(H.mtf).*fftn(fftshift(yTheta)));
