function [outVolC1,outVolC2,pose] = mcmc_recon_clean_nosymmetry_shift(handles,yC1,yC2,psfC1,psfC2,varargin)

[nbItersAngle,shiftRange,symmetryC,lambda] = ...
    process_options(varargin,'nbItersAngle',200,'shiftRange',0,'symmetryC',9,'lambda',1e-2);

%%%%%%%% Some variables
rs = samplingRatio_xy_z;
n = symmetryC;
nbVolsTot = length(yC1);
sy=size(yC1{1});
HtH = cell(nbVolsTot,1);
Hty = cell(nbVolsTot,1);
G=LinOpGrad([size(yC1{1},1),size(yC1{1},2),size(yC1{1},3)],[],'circular',[1,1,samplingRatio_xy_z]);               % TV regularizer: Operator Gradient
fGtG=fftn(G.fHtH);
DtD = abs(fftn(cat(2,rs,-rs),sy)).^2 + abs(fftn(cat(1,rs,-rs),sy)).^2 + abs(fftn(cat(3,1,-1),sy)).^2;

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

%% Loop on poses
k = 1;
N = (nbVolsTot-1)*nbOuterItersAngle;

[tx,ty,tz]=meshgrid(-shiftRange:shiftRange);
tx=tx(:);ty=ty(:);tz=tz(:);
xt=zeros(sy(1),sy(2),sy(3),length(tx));

h = waitbar(0,'0%');

for iAngle=2:N+1
    fprintf('\nAngle %d\n',iAngle);
    k = mod(k-1,nbVolsTot-1) + 2;
    
    %%%%%%% Version 1: consider all the volumes
    nbVols = min(iAngle,nbVolsTot);
    inVolsPadding0=inVolsPadding;
    pose0=pose;
    k0=k;

    %%%%%%% Version 2: consider only pairs of volumes
    HtH=cell(nbVols,1);
    yTheta=cell(nbVols,1);
    HTheta=cell(nbVols,1);

    %% Pre-computation of HtH and ytheta for the initial pose
    for i=1:nbVols
       [HtH{i},Hty{i},yTheta{i},HTheta{i}] = compute_HtH_Hty_pose_nosymmetry_store(inVolsPadding0{i},psfC1,pose0(i,:));
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
    for t=1:length(tx)
        poseParfor=pose0;
        yTrans = imtranslate(inVolsPadding0{k0},-pose0(k0,4:6)+[tx(t),ty(t),tz(t)]);
        [FHtyNew,yTheta1]= compute_FHty_pose_nosymmetry(yTrans,HTheta{k0},poseParfor(k0,:));

        sumFHtyNew = sumHty - Hty{k0} + FHtyNew;

        xt(:,:,:,t) = reconstruction_l2(sumFHtyNew/(nbVols),sumHtH/(nbVols),fGtG,lambda);
        
        xtmp=xt(:,:,:,t);

        poseParfor(k0,4:6)=poseParfor(k0,4:6)-[tx(t),ty(t),tz(t)];
        EArray(t) = evaluate_cost_shiftOnly_nosymmetry({inVolsPadding0{1:k0-1},yTheta1},xtmp,HTheta,poseParfor(1:nbVols,:),shiftBegin,shiftEnd,lambda,G);
        disp3D(xt(:,:,:,t));
    end
    [E,iE]=min(EArray);
    pose0(k0,4:6)=pose0(k0,4:6)-[tx(iE),ty(iE),tz(iE)];
    xBest=xt(:,:,:,iE);
    disp3D(xBest);
    
    fprintf('iter ');
    
    %% MCMC procedure
    %% Angular parameters
    for t=1:nbItersAngle
        %%%%%%%% New pose proposal
        poseNew = pose;
        poseNew0 = pose0;
        poseNew0(k0,1:3) = proposal_angle_golden_angle(t,1);

        %%%%%%%% New cost evaluation
        [ENew,xNew,poseNew0] = mcmc_evaluation_nosymmetry_with_shift(poseNew0,yTheta,inVolsPadding0,psfC1,HTheta,tx,ty,tz,shiftBegin,shiftEnd,k0,sumHtH,sumHty,HtH,Hty,fGtG,G,lambda,nbVols);
        disp3D_fig4(xNew);

        %%%%%%%% Pose update
        [pose0,E] = mcmc_select_pose(E,ENew,pose0,poseNew0,T);
        if sum(pose0(k0,:)~=poseNew0(k0,:))==0
            xBest=xNew;
            disp3D_fig5(xBest);
            pose(k,:)=pose0(k0,:);
        end

        %%%%%%%% Trick to handle shifts
        progress=t*(iAngle-1)/(N*nbItersAngle);
        waitbar(progress,h,sprintf('%d%% ',progress*100));
    end
    outVolC1=xBest;
    
    %% Second channel
    for i=1:nbVols
         [HtH{i},Hty{i}] = compute_HtH_Hty_pose(inVolsPadding{i},psfC2,pose(i,:),sy);
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
