function disp3D(vol1,vol2)

switch nargin
    case 1
        figure(3);
        subplot(2,2,1);imagesc(squeeze(vol1(:,:,floor(size(vol1,3)/2)-1))); axis image ; colormap gray;
        subplot(2,2,2);imagesc(squeeze(vol1(:,floor(size(vol1,2)/2),:))); axis image ; colormap gray;
        subplot(2,2,3);imagesc(imrotate(squeeze(vol1(floor(size(vol1,1)/2),:,:)),90)); axis image ; colormap gray;
    case 2
        figure(3);
        subplot(2,4,1);imagesc(squeeze(vol1(:,:,floor(size(vol1,3)/2)))); axis image ; colormap gray;
        subplot(2,4,2);imagesc(squeeze(vol1(:,floor(size(vol1,2)/2),:))); axis image ; colormap gray;
        subplot(2,4,5);imagesc(imrotate(squeeze(vol1(floor(size(vol1,1)/2),:,:)),-90)); axis image ; colormap gray;

        subplot(2,4,3);imagesc(squeeze(vol2(:,:,floor(size(vol2,3)/2)))); axis image ; colormap gray;
        subplot(2,4,4);imagesc(squeeze(vol2(:,floor(size(vol2,2)/2),:))); axis image ; colormap gray;
        subplot(2,4,7);imagesc(imrotate(squeeze(vol2(floor(size(vol1,2)/2),:,:)),-90)); axis image ; colormap gray;

end    
    
drawnow

% figure(5);
%         subplot(2,2,1);imagesc(squeeze(xCrop(:,:,floor(size(xCrop,3)/2)))); axis image ; colormap gray;
%         subplot(2,2,2);imagesc(squeeze(xCrop(floor(size(xCrop,1)/2),:,:))); axis image ; colormap gray;
%         subplot(2,2,3);imagesc(squeeze(xCrop(:,floor(size(xCrop,2)/2),:))); axis image ; colormap gray;
