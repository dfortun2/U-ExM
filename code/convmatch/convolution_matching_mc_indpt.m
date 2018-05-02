function [curVolC1,curVolC2,poses] = convolution_matching_mc_indpt(handles,inVolsC1,inVolsC2,psf1,psf2, initVolC1, varargin)

[posesGt,lambda,samplingList,rangeList,rangeListShift,downsampling,symmetry,nbIters] = ...
    process_options(varargin,'poseGt',[],'lambda',100,'samplingList',[40,10,5,2],'rangeList',[0,10,5,2],'rangeListShift',[5,2,2,2]...
    ,'downsampling',0.5,'symmetry','C9','nbIters',100);

curVolC1 = initVolC1;
for i=1:length(samplingList)
    set(handles.boxProgress,'String',['Step ',num2str(i),'/',num2str(length(samplingList))]); drawnow
    %% Poses estimation
%      fprintf('#############   Pose estimation\n');
    if i==1
        t = cputime;
         poses = convolution_matching_C9(inVolsC1,inVolsC2,psf1,initVolC1,samplingList(i),rangeListShift(i),posesGt,symmetry);
        e = cputime-t;
        fprintf('--- angular convolution-matching: %.2f sec\n', e);
    else
        t = cputime;
        poses = convolution_matching_C9_refine(inVolsC1,inVolsC2,psf1,initVolC1,poses,samplingList(i),rangeList(i),rangeListShift(i),posesGt);
        e = cputime-t;
        fprintf('--- angular convolution-matching refinement: %.2f sec\n', e);
    end        
    
    %% Reconstruction
    fprintf('#############   Reconstruction\n');
    t = cputime;
    curVolC1 = reconstruction_InvPbLib(inVolsC1,psf1,poses,lambda,'C9',nbIters,handles.ImXYRecon,handles.ImZYRecon,handles.ImXZRecon);
    e = cputime-t;
    fprintf('--- reconstruction: %.2f sec\n', e);

    disp3D_gui(curVolC1,handles.ImXYRecon,handles.ImZYRecon,handles.ImXZRecon);
end
curVolC2 = reconstruction_InvPbLib(inVolsC2,psf2,poses,lambda,'C9',nbIters,handles.ImXYRecon,handles.ImZYRecon,handles.ImXZRecon);
set(handles.boxProgress,'String','Done');

