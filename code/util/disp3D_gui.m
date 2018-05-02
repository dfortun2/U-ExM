function disp3D_gui(vol,handlesXY,handlesZY,handlesXZ)

axes(handlesXY)
imagesc(squeeze(vol(:,:,floor(size(vol,3)/2)-1,:))); axis image; axis off ; colormap gray;
axes(handlesZY)
imagesc(squeeze(vol(:,floor(size(vol,2)/2),:,:))); axis image; axis off ; colormap gray;
axes(handlesXZ)
imagesc(imrotate(squeeze(vol(floor(size(vol,1)/2),:,:,:)),90)); axis image; axis off ; colormap gray;
