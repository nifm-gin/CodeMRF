kx=28;
ky=12;
% kx=35;
% ky=64;
figure
plot(squeeze(Images.Image_normalized_dicom(kx,ky,:)))
hold on
% plot(abs(dictionary(t_exp_dicom(kx,ky),:))/norm(abs(dictionary(t_exp_dicom(kx,ky),:))))
plot(abs(dico_flux(Reconstruction.t_exp_T1T2dfB1(kx,ky),:,Reconstruction.t_exp_v(kx,ky)))/norm(abs(dico_flux(Reconstruction.t_exp_T1T2dfB1(kx,ky),:,Reconstruction.t_exp_v(kx,ky)))))
title(strcat('kx=',num2str(kx),', ky=',num2str(ky)))