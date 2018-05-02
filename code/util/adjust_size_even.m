function outVol = adjust_size_even(inVol)

s=size(inVol);
iPad=[0,0,0];
for k=1:3
    if mod(s(k),2)~=0
        iPad(k)=1;
    end
end
outVol=zeros(s(1)+iPad(1),s(2)+iPad(2),s(3)+iPad(3));
outVol(iPad(1)+1:end,iPad(2)+1:end,iPad(3)+1:end)=inVol;
