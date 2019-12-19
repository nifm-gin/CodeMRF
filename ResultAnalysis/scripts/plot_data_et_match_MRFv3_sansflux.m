kx=31;
ky=50;
figure
plot(squeeze(Images.Image_normalized_dicom(kx,ky,:)))
hold on
plot(abs(dictionary(Reconstruction.t_exp_dicom(kx,ky),:))/norm(abs(dictionary(Reconstruction.t_exp_dicom(kx,ky),:))))


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
% plot(abs(dictionary(Reconstruction1.t_exp_dicom(kx,ky),:))/norm(abs(dictionary(Reconstruction1.t_exp_dicom(kx,ky),:))))
% hold on
% plot(abs(dictionary(Reconstruction2.t_exp_dicom(kx,ky),:))/norm(abs(dictionary(Reconstruction2.t_exp_dicom(kx,ky),:))))
% plot(abs(dictionary(Reconstruction3.t_exp_dicom(kx,ky),:))/norm(abs(dictionary(Reconstruction3.t_exp_dicom(kx,ky),:))))
% plot(abs(dictionary(Reconstruction4.t_exp_dicom(kx,ky),:))/norm(abs(dictionary(Reconstruction4.t_exp_dicom(kx,ky),:))))