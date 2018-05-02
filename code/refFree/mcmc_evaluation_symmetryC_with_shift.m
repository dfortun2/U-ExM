function [E,x,poseNew] = mcmc_evaluation_symmetryC_with_shift(poseNew,yTheta,inVolsPadding,psf,HTheta,tx,ty,tz,shiftBegin,shiftEnd,k,sumHtH,sumFHty,HtH,Hty,DtD,G,lambda,nbVols,n)

%% Update HtH and Hty
[HtHNew ,FHtyNew,yTheta{k},HTheta{k}]= compute_HtH_Hty_pose_symmetryC_store(inVolsPadding{k},psf,poseNew(k,:),n);

sumHtHNew = sumHtH - HtH{k} + HtHNew;

%% Shift search
EArray=zeros(length(tx),1);
parfor t=1:length(tx)
    poseParfor=poseNew;
    %% Update x
    yTrans = imtranslate(inVolsPadding{k},[tx(t),ty(t),tz(t)]);

    [FHtyNew,yTheta1]= compute_FHty_pose_symmetryC(yTrans,HTheta{k},poseParfor(k,:),n);

    sumFHtyNew = sumFHty - Hty{k} + FHtyNew;
    xt(:,:,:,t) = reconstruction_l2(sumFHtyNew/(nbVols*n),sumHtHNew/(nbVols*n),DtD,lambda);

    %% Compute cost
    poseParfor(k,4:6)=[tx(t),ty(t),tz(t)];
    EArray(t) = evaluate_cost_shiftOnly({inVolsPadding{1:k-1},yTheta1},xt(:,:,:,t),HTheta,poseParfor(1:nbVols,:),shiftBegin,shiftEnd,lambda,G);
end
[E,iE]=min(EArray);
poseNew(k,4:6)=-[tx(iE),ty(iE),tz(iE)];
x=xt(:,:,:,iE);

end

