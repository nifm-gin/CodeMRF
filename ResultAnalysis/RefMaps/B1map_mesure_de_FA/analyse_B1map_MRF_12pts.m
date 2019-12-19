clear all

%% Chargement des images 
dossier_visu='D:\Experiments\2017\Mai\2017-05-09\20170509_093113_2017_05_09_1_1\29\pdata\1';


Nimages=12;
FA=[10:10:120];

dossier=strcat(dossier_visu,'\dicom\');
X=dicomread(strcat(dossier,'MRIm01.dcm'));
[Nx,Ny]=size(X);
clear X;
Images_dicom=zeros(Nx,Ny,Nimages);
for i=1:Nimages
    filename=sprintf('MRIm%02i.dcm',i);
    Images_dicom(:,:,i)=dicomread(strcat(dossier,filename));
end

visu_pars=fopen(strcat(dossier_visu,'\visu_pars'),'r','ieee-le');
texteVisuPars=char(fread(visu_pars,[inf],'int8'));
fclose(visu_pars);
texteVisuPars=texteVisuPars(:)';
clear ans visu_pars
VisuCoreDataMax=scan_acqp('##$VisuCoreDataMax=',texteVisuPars,1);
VisuCoreDataSlope=scan_acqp('##$VisuCoreDataSlope=',texteVisuPars,1);
clear dossier_visu texteVisuPars
for i=1:Nimages
    Images_dicom_rescaled(:,:,i)=double(Images_dicom(:,:,i))*VisuCoreDataSlope(i)/32767;
end
clear i% VisuCoreDataMax VisuCoreDataSlope
clear dossier filename

%% Fit 1 paramètre -> carte de B1 relatif
B1relMap=zeros(Nx,Ny);
AmplitudeMap=zeros(Nx,Ny);
for kx=1:Nx
    for ky=1:Ny
        AmplitudeMap(kx,ky)=max(Images_dicom(kx,ky,:));
        if Images_dicom(kx,ky,1)>0
            signal_temp=squeeze(Images_dicom(kx,ky,:))/max(Images_dicom(kx,ky,:));
            [B D]=levenbergmarquardt('fitB1relatif_sansoffset',FA,signal_temp',[0.5]);
            B1relMap(kx,ky)=B(1);
            dB1relMap(kx,ky)=D(1);
        end
    end
end
clear kx ky B D
%% Plot carte de B1 relatif
figure('Name','Carte de B1 relatif','units','normalized','outerposition',[1/3 1/3 1/2 1/2])
% subplot(1,2,1)
% imagesc(AmplitudeMap)
% daspect([1 1 1])
% title('Amplitude (~proton density)')
% colorbar
% 
% subplot(1,2,2)
imagesc(B1relMap)
daspect([1 1 1])
title('relative B1')
caxis([0.5 1.2])
colorbar
set(gcf,'color','w');


%% Fit avec offset
% Facteurmap=zeros(64);
% Offsetmap=zeros(64);
% Amap=zeros(64);
% for kx=1:64
%     for ky=1:64
%         Amap(kx,ky)=max(Images_dicom(kx,ky,:));
%     if Images_dicom(kx,ky,1)>3000
%         signal_temp=squeeze(Images_dicom(kx,ky,:))/max(Images_dicom(kx,ky,:));
%         [B D]=levenbergmarquardt('fitB1relatif',FA,signal_temp',[0.5 -1]);
%         Facteurmap(kx,ky)=B(1);
%         Offsetmap(kx,ky)=B(2);
%     end
%     end
% end
%
% figure;
% subplot(1,3,1)
% imagesc(Amap)
% daspect([1 1 1])
% title('A (AU)')
%
% subplot(1,3,2)
% imagesc(Facteurmap)
% daspect([1 1 1])
% title('Facteur')
%
% subplot(1,3,3)
% imagesc(Offsetmap)
% daspect([1 1 1])
% title('Offset (°)')
% caxis([-3 3])
%
% -------------------------------------------------------------------------