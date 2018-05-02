function f = reconstruction_InvPbLib(y,psf,pose,lamb,symmetry,nbIters,handlesXY,handlesZY,handlesXZ,handlesBoxProgress)

%%
yArray=zeros(size(y{1},1),size(y{1},2),size(y{1},3),length(y));
for i=1:length(y)
    yArray(:,:,:,i)=y{i};
end
halfPad=ceil(size(psf)/2);
yArrayPad=zeros(size(y{1},1)+2*halfPad(1),size(y{1},2)+2*halfPad(2),size(y{1},3)+2*halfPad(3),length(y));
for i=1:length(y)
    yArrayPad(:,:,:,i)=padarray(yArray(:,:,:,i),halfPad);
end

%% Building the Cost-Function without mask
sz=[size(yArray,1),size(yArray,2),size(yArray,3)];
if nargin==10
    set(handlesBoxProgress,'String','Pre-computations...');drawnow;
end
H=LinOpMultiPoseConv(psf,pose,symmetry);
H.precompute(yArray);
LS=CostL2(H.sizeout,yArray);  
F_LS=LS*H;
R_N12=CostMixNorm21([sz,3],4);
G=LinOpGrad(sz);         
R_POS=CostNonNeg(sz);    
Id=LinOpIdentity(sz);    

%% Parameters
maxiter=nbIters;

%% Fourier of the filter G'G (Laplacian)
fGtG=fftn(make_fHtH(G));

%% TV Regularization (ADMM minimization)
Fn={lamb*R_N12,R_POS};   
Hn={G,Id};               
rho_n=[1e-2,1e-2];       
solver = @(z,rho,x) real(ifftn((H.Hty0 + fftn(rho(1)*G'*z{1} + rho(2)*z{2}) )./(H.HtH0 + rho(1)*fGtG + rho(2))));

if nargin==10
    set(handlesBoxProgress,'String','Iterating...');drawnow;
end
ADMM=OptiADMM(F_LS,Fn,Hn,rho_n,solver);
ADMM.ItUpOut=10;            
ADMM.maxiter=maxiter;      
ADMM.run(yArray(:,:,:,1)); 
f=ADMM.xopt;
