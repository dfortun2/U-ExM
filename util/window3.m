function w=window3(siz,w_func,param)

if strcmp(w_func,'tukeywin')
    d0=300;
    w0=tukeywin(d0,param);
    center0=d0/2;
    a=d0./siz;
    w=zeros(siz(1),siz(2),siz(3));
    center=siz/2;
    for i=1:siz(1)
        for j=1:siz(2)
            for k=1:siz(3)
                d1=a(1)*abs((i-center(1)));
                d2=a(2)*abs((j-center(2)));
                d3=a(3)*abs((k-center(3)));
                d=round(sqrt(d1^2+d2^2+d3^2));
                p=center0-d;
                if p<=0
                    w(i,j,k)=0;
                else
                    w(i,j,k)=w0(p);
                end
            end
        end
    end
else
    if param==-1
        w1=window(w_func,siz(1));
        w2=window(w_func,siz(2));
        w3=window(w_func,siz(3));
    else
        w1=window(w_func,siz(1),param);
        w2=window(w_func,siz(2),param);
        w3=window(w_func,siz(3),param);
    end
    [mask1,mask2,mask3]=meshgrid(w2,w1,w3);

    w=mask1.*mask2.*mask3;
end

end
