function [FHty,yTheta1] = compute_FHty_pose_symmetryC(y,H,pose,n)

poseC = new_poses_symmetryC(pose,n);

FHtyLocal = zeros(size(y,1),size(y,2),size(y,3),n);

for i=1:n    
    yTheta=rotVolInverseClean(y,poseC(i,1),poseC(i,2),poseC(i,3));

    FHtyLocal(:,:,:,i) = (conj(H{i}.mtf).*fftn(fftshift(yTheta)));
    
    if i==1
        yTheta1=yTheta;
    end
end

FHty = sum(FHtyLocal,4);
