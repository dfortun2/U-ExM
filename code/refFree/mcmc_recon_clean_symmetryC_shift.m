function [outVolC1,outVolC2,pose] = mcmc_recon_clean_symmetryC_shift(handles,yC1,yC2,psfC1,psfC2,varargin)

[nbItersAngle,shiftRange,symmetryC,lambda] = ...
    process_options(varargin,'nbItersAngle',200,'shiftRange',2,'symmetryC',9,'lambda',1e-2);

samplingRatio_xy_z=1;
%%%%%%%% Some variables
rs = samplingRatio_xy_z;
n = symmetryC;
nbVolsTot = length(yC1);
sy=size(yC1{1});
HtH = cell(nbVolsTot,1);
Hty = cell(nbVolsTot,1);
G=LinOpGrad([size(yC1{1},1),size(yC1{1},2),size(yC1{1},3)],[],'circular',[1,1,samplingRatio_xy_z]);               % TV regularizer: Operator Gradient
fGtG=fftn(make_fHtH(G));

%%%%%%%% Parameters
T = 0.001;
nbOuterItersAngle = 1;

%%%%%%%% Padding
inVolsPadding = yC1;
sy = size(inVolsPadding{1});

%%%%%%%% Initialization
theta = zeros(nbVolsTot,3);
shift = zeros(nbVolsTot,3);
pose = cat(2,theta,shift);
pose(2,1)=315;
pose(2,2)=90;

%% Loop on poses
k = 1;
N = (nbVolsTot-1)*nbOuterItersAngle;

[tx,ty,tz]=meshgrid(-shiftRange:shiftRange);
tx=tx(:);ty=ty(:);tz=tz(:);
xt=zeros(sy(1),sy(2),sy(3),length(tx));

for iAngle=2:N+1
    k = mod(k-1,nbVolsTot-1) + 2;
    nbVols = min(iAngle,nbVolsTot);

    HtH=cell(nbVols,1);
    FHty=cell(nbVols,1);
    yTheta=cell(nbVols,1);
    HTheta=cell(nbVols,1);

    %% Pre-computation of HtH and ytheta for the initial pose
    for i=1:nbVols
       [HtH{i},Hty{i},yTheta{i},HTheta{i}] = compute_HtH_Hty_pose_symmetryC_store(inVolsPadding{i},psfC1,pose(i,:),n);
    end
    sumHtH = 0;
    sumHty = 0;
    for i=1:nbVols
        sumHtH = sumHtH + HtH{i};
        sumHty = sumHty + Hty{i};
    end

    %% First cost evaluation of the MCMC procedure
    EArray=zeros(length(tx),1);
    c=1;
    shiftBegin=shiftRange+1+c;
    shiftEnd=sy-shiftRange-c;
    parfor t=1:length(tx)
        poseParfor=pose;
        yTrans = imtranslate(inVolsPadding{k},[tx(t),ty(t),tz(t)]);
        [FHtyNew,yTheta1]= compute_FHty_pose_symmetryC(yTrans,HTheta{k},poseParfor(k,:),n);

        sumFHtyNew = sumHty - Hty{k} + FHtyNew;

        xt(:,:,:,t) = reconstruction_l2(sumFHtyNew/(nbVols*n),sumHtH/(nbVols*n),fGtG,lambda);
        poseParfor(k,4:6)=-[tx(t),ty(t),tz(t)];
        EArray(t) = evaluate_cost_shiftOnly({inVolsPadding{1:k-1},yTheta1},xt(:,:,:,t),HTheta,poseParfor(1:nbVols,:),shiftBegin,shiftEnd,lambda,G);
         fprintf('E = %f\n',EArray(t));
    end
    [E,iE]=min(EArray);
    pose(k,4:6)=-[tx(iE),ty(iE),tz(iE)];
    xBest=xt(:,:,:,iE);
    axes(handles.ImXYRecon)
    imagesc(squeeze(xBest(:,:,floor(size(xBest,3)/2)-1))); axis image; axis off ; colormap gray;
    axes(handles.ImXZRecon)
    imagesc(squeeze(xBest(:,floor(size(xBest,2)/2),:))); axis image; axis off ; colormap gray;
    axes(handles.ImZYRecon)
    imagesc(imrotate(squeeze(xBest(floor(size(xBest,1)/2),:,:)),90)); axis image; axis off ; colormap gray;
    drawnow;
    
    %% MCMC procedure
    %% Angular parameters
    for t=1:nbItersAngle
        %%%%%%%% New pose proposal
        poseNew = pose;
        poseNew(k,1:3) = proposal_angle_golden_angle(t,n);

        %%%%%%%% New cost evaluation
        [ENew,xNew,poseNew] = mcmc_evaluation_symmetryC_with_shift(poseNew,yTheta,inVolsPadding,psfC1,HTheta,tx,ty,tz,shiftBegin,shiftEnd,k,sumHtH,sumHty,HtH,Hty,fGtG,G,lambda,nbVols,n);
         fprintf('ENew = %f\n',ENew);

        %%%%%%%% Pose update
        [pose,E] = mcmc_select_pose(E,ENew,pose,poseNew,T);
        if sum(pose(k,:)~=poseNew(k,:))==0
            xBest=xNew;
            axes(handles.ImXYRecon)
            imagesc(squeeze(xBest(:,:,floor(size(xBest,3)/2)-1))); axis image; axis off ; colormap gray;
            axes(handles.ImXZRecon)
            imagesc(squeeze(xBest(:,floor(size(xBest,2)/2),:))); axis image; axis off ; colormap gray;
            axes(handles.ImZYRecon)
            imagesc(imrotate(squeeze(xBest(floor(size(xBest,1)/2),:,:)),90)); axis image; axis off ; colormap gray;
            drawnow;
            fprintf('pose = %f,%f,%f\n',pose(1),pose(2),pose(3));

        end

        progress=t*(iAngle-1)/(N*nbItersAngle)*100;
        set(handles.boxProgress,'String',[num2str(progress),'%']);
        drawnow;
    end
    outVolC1=xBest;
    
    %% Second channel
    for i=1:nbVols
        [HtH{i},Hty{i},yTheta{i},HTheta{i}] = compute_HtH_Hty_pose_symmetryC_store(yC2{i},psfC2,pose(i,:),n);
    end
    sumHtH = 0;
    sumHty = 0;
    for i=1:nbVols
        sumHtH = sumHtH + HtH{i};
        sumHty = sumHty + Hty{i};
    end

    outVolC2= reconstruction_l2(sumHty/(nbVols),sumHtH/(nbVols),fGtG,lambda);

end

end

function Du = ForwardD(U)

Du = zeros(size(U,1),size(U,2),size(U,3),3);
Du(:,:,:,1) = cat(2,diff(U,1,2), U(:,1,:) - U(:,end,:));
Du(:,:,:,2) = cat(1,diff(U,1,1), U(1,:,:) - U(end,:,:));
Du(:,:,:,3) = cat(3,diff(U,1,3), U(:,:,1) - U(:,:,end));
end

function fHtH = make_fHtH(G)
    fHtH=zeros(G.sizein);
    if strcmp(G.bc,'circular')&&(G.ndms<=4)
        switch(G.ndms)
            case(1), fHtH(1)=2;fHtH(2)=-1;fHtH(end)=-1;fHtH=fHtH/G.res(1)^2;
            case(2), fHtH(1,1)=2/G.res(1)^2+2/G.res(2)^2;fHtH(1,2)=-1/G.res(2)^2;fHtH(2,1)=-1/G.res(1)^2;fHtH(1,end)=-1/G.res(2)^2;fHtH(end,1)=-1/G.res(1)^2;
            case(3), fHtH(1,1,1)=2/G.res(1)^2+2/G.res(2)^2+2/G.res(3)^2;fHtH(1,2,1)=-1/G.res(2)^2;fHtH(2,1,1)=-1/G.res(1)^2;fHtH(1,end,1)=-1/G.res(2)^2;fHtH(end,1,1)=-1/G.res(1)^2;
                fHtH(1,1,2)=-1/G.res(3)^2;fHtH(1,1,end)=-1/G.res(3)^2;
            case(4), fHtH(1,1,1,1)=2/G.res(1)^2+2/G.res(2)^2+2/G.res(3)^2+2/G.res(4)^2;fHtH(1,2,1,1)=-1/G.res(2)^2;fHtH(2,1,1,1)=-1/G.res(1)^2;fHtH(1,end,1,1)=-1/G.res(2)^2;fHtH(end,1,1,1)=-1/G.res(1)^2;
                fHtH(1,1,2,1)=-1/G.res(3)^2;fHtH(1,1,end,1)=-1/G.res(3)^2;fHtH(1,1,1,2)=-1/G.res(4)^2;fHtH(1,1,1,end)=-1/G.res(4)^2;
        end
    else
        fprintf('boundary conditions must be circular');
    end
end

