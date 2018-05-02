function posesNew = new_poses_symmetryC(poses,n)

nbVols = size(poses,1);

rotC = 360/n;
posesNew = zeros(n*nbVols,6);

for i=1:nbVols
    for k=0:n-1
        posesNew(i+k*nbVols,:) = poses(i,:);
        posesNew(i+k*nbVols,3) = mod(poses(i,3) + k*rotC,360);
    end
end
