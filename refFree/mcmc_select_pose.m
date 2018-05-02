function [pose,E] = mcmc_select_pose(E,ENew,pose,poseNew,T)

if(ENew < E)
    pose = poseNew;
    E = ENew;
    fprintf('Update 1');
end
