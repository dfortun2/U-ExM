function outVol = resizeVol(inVol, newDims)

[y,x,z]=ndgrid(linspace(1,size(inVol,1),newDims(1)),linspace(1,size(inVol,2),newDims(2)),linspace(1,size(inVol,3),newDims(3)));
outVol=interp3(inVol,x,y,z);

end

