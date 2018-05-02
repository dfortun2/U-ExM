function [HtH,FHty,yTheta,HTheta] = compute_HtH_Hty_pose_nosymmetry_store(y,psf,pose)

hTheta = bigfluo_apply_pose_inversePSF(psf,pose);
yTheta = bigfluo_apply_pose_inverse(y,pose);

sizePad=(size(y)-size(hTheta))/2;
hTheta=padarray(hTheta,sizePad);
HTheta=LinOpConv((hTheta));         

HtH = abs(conj(HTheta.mtf).*HTheta.mtf);
FHty = (conj(HTheta.mtf).*fftn(fftshift(yTheta)));
