function outVol = bigfluo_apply_pose_inversePSF(inVol, poses)

outVol = rotVolInverseClean(inVol,poses(1),poses(2),poses(3));

