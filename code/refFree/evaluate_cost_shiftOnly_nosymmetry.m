function E = evaluate_cost_shiftOnly_nosymmetry(yTheta,x,HTheta,pose,shiftBegin,shiftEnd,lambda,G)

%% Data term
nbVols = length(yTheta); 
w=window3(size(yTheta{1}),'hanning',-1);

Edata = 0;
for i=1:nbVols
    yi=imtranslate(yTheta{i},-[pose(i,4),pose(i,5),pose(i,6)]);
    yEst = ifftshift(HTheta{i}*x);
    yi=yi.*w;
    yEst=yEst.*w;

    out=dftregistration3D(fftn(yi),fftn(yEst),1);
    Edata=Edata+out(1);

end

E = Edata/nbVols;

%% Regularization term
% Dx = G*x;
% Dxx = Dx(:,:,:,1); Dxy = Dx(:,:,:,2); Dxz = Dx(:,:,:,3); 
% Ereg = norm(Dxx(:),2)^2 + norm(Dxy(:),2)^2 + norm(Dxz(:),2)^2;
Ereg=0;

E = Edata + lambda*Ereg;