function HtH = compute_HtH_pose_symmetryC(psf,pose,s,n)

poseC = new_poses_symmetryC(pose,n);

HtHLocal = zeros(s(1),s(2),s(3),n);
parfor i=1:n
    hTheta = bigfluo_apply_pose_inversePSF(psf,poseC(i,:));

    HtHLocal(:,:,:,i) = abs(conj(fftn(hTheta,s)).*fftn(hTheta,s));
end

HtH = sum(HtHLocal,4);
