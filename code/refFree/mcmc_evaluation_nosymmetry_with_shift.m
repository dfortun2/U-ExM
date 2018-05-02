function [E,x,poseNew] = mcmc_evaluation_nosymmetry_with_shift(poseNew,yTheta,inVolsPadding,psf,HTheta,tx,ty,tz,shiftBegin,shiftEnd,k0,sumHtH,sumFHty,HtH,Hty,DtD,G,lambda,nbVols)

%% Update HtH and Hty
[HtHNew ,FHtyNew,yTheta{k0},HTheta{k0}]= compute_HtH_Hty_pose_nosymmetry_store(inVolsPadding{k0},psf,poseNew(k0,:));

sumHtHNew = sumHtH - HtH{k0} + HtHNew;

%% Shift search
EArray=zeros(length(tx),1);
for t=1:length(tx)
    poseParfor=poseNew;
    %% Update x
    yTrans = imtranslate(inVolsPadding{k0},-poseParfor(k0,4:6)+[tx(t),ty(t),tz(t)]);

    [FHtyNew,yTheta1]= compute_FHty_pose_nosymmetry(yTrans,HTheta{k0},poseParfor(k0,:));

    sumFHtyNew = sumFHty - Hty{k0} + FHtyNew;
    xt(:,:,:,t) = reconstruction_l2(sumFHtyNew/(nbVols),sumHtHNew/(nbVols),DtD,lambda);

    xtmp=xt(:,:,:,t);

    %% Compute cost
    poseParfor(k0,4:6)=poseParfor(k0,4:6)-[tx(t),ty(t),tz(t)];
    EArray(t) = evaluate_cost_shiftOnly_nosymmetry({inVolsPadding{1:k0-1},yTheta1},xtmp,HTheta,poseParfor(1:nbVols,:),shiftBegin,shiftEnd,lambda,G);
    
end
[E,iE]=min(EArray);
poseNew(k0,4:6)=poseNew(k0,4:6)-[tx(iE),ty(iE),tz(iE)];
x=xt(:,:,:,iE);

end

