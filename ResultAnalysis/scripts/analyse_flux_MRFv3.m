for kv=1:length(Properties.vlist)
    kv
    dictionary=dico_flux(:,:,kv);
    h = waitbar(0,'MRF reconstruction in progress...');

for k= 1:Images.Ny
    waitbar(k/Images.Ny, h)
[Reconstruction.innerproduct(:,k,kv),Reconstruction.idxMatch(:,k,kv)]= templatematch_MRFv3(abs(dictionary(:,(2:end))),squeeze(Images.Image_normalized_dicom(:,k,2:end)));
end
close(h)
end
clear dictionary

for kx=1:Images.Nx
    for ky=1:Images.Ny
        [Reconstruction.max_innerproduct(kx,ky) Reconstruction.t_exp_v(kx,ky)]=max(Reconstruction.innerproduct(kx,ky,:));
        Reconstruction.t_exp_T1T2dfB1(kx,ky)=Reconstruction.idxMatch(kx,ky,Reconstruction.t_exp_v(kx,ky));
    end
end

clear k kx ky kv
