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
