function outVol = bigfluo_apply_pose_inverse(inVol, poses)

outVol = imtranslate(inVol,-[poses(4),poses(5),poses(6)]);
outVol = rotVolInverseClean(outVol,poses(1),poses(2),poses(3));

