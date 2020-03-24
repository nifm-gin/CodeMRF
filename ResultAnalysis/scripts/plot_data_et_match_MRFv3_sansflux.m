kx=25;
ky=32;
figure
plot(squeeze(Images.Image_normalized_dicom(kx,ky,:)))
hold on
plot(abs(dictionary(Reconstruction.idxMatch(kx,ky),:))/norm(abs(dictionary(Reconstruction.idxMatch(kx,ky),:))))
legend('Raw', 'Match')

% 
% 
% 
% figure
% plot(squeeze(Images1.Image_normalized_dicom(kx,ky,:)))
% hold on
% plot(squeeze(Images2.Image_normalized_dicom(kx,ky,:)))
% plot(squeeze(Images3.Image_normalized_dicom(kx,ky,:)))
% plot(squeeze(Images4.Image_normalized_dicom(kx,ky,:)))
% 
% plot(abs(dictionary(Reconstruction1.idxMatch(kx,ky),:))/norm(abs(dictionary(Reconstruction1.idxMatch(kx,ky),:))))
% hold on
% plot(abs(dictionary(Reconstruction2.idxMatch(kx,ky),:))/norm(abs(dictionary(Reconstruction2.idxMatch(kx,ky),:))))
% plot(abs(dictionary(Reconstruction3.idxMatch(kx,ky),:))/norm(abs(dictionary(Reconstruction3.idxMatch(kx,ky),:))))
% plot(abs(dictionary(Reconstruction4.idxMatch(kx,ky),:))/norm(abs(dictionary(Reconstruction4.idxMatch(kx,ky),:))))