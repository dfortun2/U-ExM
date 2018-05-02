function [HtH,FHty,yTheta,HTheta] = compute_HtH_Hty_pose_symmetryC_store(y,psf,pose,n)

poseC = new_poses_symmetryC(pose,n);

HtHLocal = zeros(size(y,1),size(y,2),size(y,3),n);
FHtyLocal = zeros(size(y,1),size(y,2),size(y,3),n);
yTheta=zeros(size(y,1),size(y,2),size(y,3),n);
HTheta=cell(n,1);

for i=1:n
    hTheta = bigfluo_apply_pose_inversePSF(psf,poseC(i,:));
    yTheta(:,:,:,i) = bigfluo_apply_pose_inverse(y,poseC(i,:));

    sizePad=(size(y)-size(hTheta))/2;
    hTheta=padarray(hTheta,sizePad);
    HTheta{i}=LinOpConv(fftn(hTheta));         

    HtHLocal(:,:,:,i) = abs(conj(HTheta{i}.mtf).*HTheta{i}.mtf);
    FHtyLocal(:,:,:,i) = (conj(HTheta{i}.mtf).*fftn(fftshift(yTheta(:,:,:,i))));
end

HtH = sum(HtHLocal,4);
FHty = sum(FHtyLocal,4);
