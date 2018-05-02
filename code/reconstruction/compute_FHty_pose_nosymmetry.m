function [FHty,yTheta] = compute_FHty_pose_nosymmetry(y,H,pose)

yTheta=rotVolInverseClean(y,pose(1),pose(2),pose(3));

FHty = (conj(H.mtf).*fftn(fftshift(yTheta)));

