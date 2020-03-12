figure('Name','MRF reconstruction results','units','normalized','outerposition',[0 0 1 1])

if strcmp(Reconstruction.treshholdOnOff,'Off')
RecoMaps=struct;
RecoMaps.T1map_dicom=Properties.T1list(Reconstruction.idxMatch);
RecoMaps.T2map_dicom=Properties.T2list(Reconstruction.idxMatch);
RecoMaps.dfmap_dicom=Properties.dflist(Reconstruction.idxMatch);
RecoMaps.B1relmap_dicom=Properties.B1rellist(Reconstruction.idxMatch);
RecoMaps.vmap_dicom=Properties.vlist(Reconstruction.t_exp_v);

subplot(2,3,1)
imagesc(RecoMaps.T1map_dicom)
caxis([0 3000])
colorbar
title('Reconstructed T1map (ms)')
daspect([1 1 1])

subplot(2,3,2)
imagesc(RecoMaps.T2map_dicom)
caxis([0 1500])
colorbar
title('Reconstructed T2map (ms)')
daspect([1 1 1])

subplot(2,3,3)
imagesc(RecoMaps.dfmap_dicom)
caxis([-200 200])
colorbar
title('Reconstructed dfmap (Hz)')
daspect([1 1 1])

subplot(2,3,4)
imagesc(RecoMaps.B1relmap_dicom)
caxis([0.5 1.2])
colorbar
title('Reconstructed relative B1map')
daspect([1 1 1])

subplot(2,3,5)
imagesc(RecoMaps.vmap_dicom)
caxis([0 200])
colorbar
title('Reconstructed vmap (mm/s)')
daspect([1 1 1])

subplot(2,3,6)
imagesc(Reconstruction.max_innerproduct)
caxis([0.5 1])
colorbar
title('Maximum innerproduct map')
daspect([1 1 1])


else
RecoMaps=struct;
Reconstruction.area=find(Reconstruction.max_innerproduct>Reconstruction.seuil); % ---------------------------------------------------------- seuil
RecoMaps.T1map_dicom=Properties.T1list(Reconstruction.idxMatch);
RecoMaps.T1map_treshhold_dicom=zeros(Images.Nx,Images.Ny);
RecoMaps.T1map_treshhold_dicom(Reconstruction.area)=RecoMaps.T1map_dicom(Reconstruction.area);
RecoMaps.T2map_dicom=Properties.T2list(Reconstruction.idxMatch);
RecoMaps.T2map_treshhold_dicom=zeros(Images.Nx,Images.Ny);
RecoMaps.T2map_treshhold_dicom(Reconstruction.area)=RecoMaps.T2map_dicom(Reconstruction.area);
RecoMaps.dfmap_dicom=Properties.dflist(Reconstruction.idxMatch);
RecoMaps.dfmap_treshhold_dicom=zeros(Images.Nx,Images.Ny);
RecoMaps.dfmap_treshhold_dicom(Reconstruction.area)=RecoMaps.dfmap_dicom(Reconstruction.area);
RecoMaps.B1relmap_dicom=Properties.B1rellist(Reconstruction.idxMatch);
RecoMaps.B1relmap_treshhold_dicom=zeros(Images.Nx,Images.Ny);
RecoMaps.B1relmap_treshhold_dicom(Reconstruction.area)=RecoMaps.B1relmap_dicom(Reconstruction.area);
RecoMaps.vmap_dicom=Properties.vlist(Reconstruction.t_exp_v);
RecoMaps.vmap_treshhold_dicom=zeros(Images.Nx,Images.Ny);
RecoMaps.vmap_treshhold_dicom(Reconstruction.area)=RecoMaps.vmap_dicom(Reconstruction.area);

subplot(2,3,1)
    imagesc(RecoMaps.T1map_treshhold_dicom)
    title('Reconstructed T1 map (ms)','FontSize',14)
    caxis([0 2500])
    daspect([1 1 1])
    colorbar
subplot(2,3,2)
    imagesc(RecoMaps.T2map_treshhold_dicom)
    title('Reconstructed T2 map (ms)','FontSize',14)
    caxis([0 1500])
    daspect([1 1 1])
    colorbar
subplot(2,3,4)
    imagesc(abs(RecoMaps.dfmap_treshhold_dicom))
    title('Reconstructed df map (Hz)','FontSize',14)
    caxis([-200 200])
    daspect([1 1 1])
    colorbar
subplot(2,3,3)
    imagesc(RecoMaps.B1relmap_treshhold_dicom)
    title('Reconstructed relative B1 map','FontSize',14)
    caxis([0.75 1.15])
    daspect([1 1 1])
    colorbar
% subplot(2,3,5)
%     imagesc(Reconstruction.PDmap)
%     title('Proton density map (AU)','FontSize',14)
%     daspect([1 1 1])
%     colorbar
subplot(2,3,5)
    imagesc(RecoMaps.vmap_treshhold_dicom)
    title('Reconstructed transverse velocity map (mm/s)','FontSize',14)
    caxis([0 200])
    daspect([1 1 1])
    colorbar    
subplot(2,3,6)
    imagesc(Reconstruction.max_innerproduct)
    title('Innerproduct signal/best match','FontSize',14)
    daspect([1 1 1])
    caxis([0.9 1]) 
    colorbar
set(gcf,'color','w');
    
    
end