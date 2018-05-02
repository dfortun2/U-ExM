function E = evaluate_cost_shiftOnly(yTheta,x,HTheta,pose,shiftBegin,shiftEnd,lambda,G)

%% Data term
nbVols = length(yTheta); 
w=window3(size(yTheta{1}),'hanning',-1);

Edata = 0;
for i=1:nbVols
    yi=imtranslate(yTheta{i},-[pose(i,4),pose(i,5),pose(i,6)]);
    yEst = ifftshift(HTheta{i}{1}*x);
    yi=yi.*w;
    yEst=yEst.*w;

    out=dftregistration3D(fftn(yi),fftn(yEst),1);
    Edata=Edata+out(1);

end

E = Edata/nbVols;

