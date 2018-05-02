function outVol = bigfluo_apply_pose(inVol, poses)

outVol = rotVolClean(inVol,poses(1),poses(2),poses(3));
outVol = imtranslate(outVol,[poses(4),poses(5),poses(6)]);

