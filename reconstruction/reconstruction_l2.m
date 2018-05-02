function f = reconstruction_l2(FHtg,eigsHtH,eigsDtD,lambda)

den = eigsHtH + lambda*eigsDtD;
f = real( ifftn( ( FHtg) ./ den ) );
f=max(f,0);

end
