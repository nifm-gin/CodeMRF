clear all

%% Chargement des images : dossier contenant les images de PHASE !!
dossier_visu='D:\Experiments\2017\Mai\2017-05-09\20170509_093113_2017_05_09_1_1\19\pdata\2';


Nimages=5;
TE=[2:6];

dossier=strcat(dossier_visu,'\dicom\');
X=dicomread(strcat(dossier,'MRIm1.dcm')); % ATTENTION, ADAPTER LE NOMBRE DE 0 SI Nimages>10 !!
[Nx,Ny]=size(X);
clear X;
Images_dicom=zeros(Nx,Ny,Nimages);
for i=1:Nimages
    filename=sprintf('MRIm%01i.dcm',i); % ATTENTION, ADAPTER LE NOMBRE DE 0 SI Nimages>10 !!
    Images_dicom(:,:,i)=dicomread(strcat(dossier,filename));
end

visu_pars=fopen(strcat(dossier_visu,'\visu_pars'),'r','ieee-le');
texteVisuPars=char(fread(visu_pars,[inf],'int8'));
fclose(visu_pars);
texteVisuPars=texteVisuPars(:)';
clear ans visu_pars
% VisuCoreDataMax=scan_acqp('##$VisuCoreDataMax=',texteVisuPars,1);
VisuCoreDataSlope=scan_acqp('##$VisuCoreDataSlope=',texteVisuPars,1);
clear dossier_visu texteVisuPars
for i=1:Nimages
    Images_dicom_rescaled(:,:,i)=double(Images_dicom(:,:,i))*VisuCoreDataSlope(i); % PAS DE /32767 sinon résultat pas en radians !
end
clear i% VisuCoreDataMax VisuCoreDataSlope
clear dossier filename

%% Fit 1 paramètre -> carte d'off-resonance
B0Map=zeros(Nx,Ny);
TE=TE/1000; % conversion en s
for kx=1:Nx
    for ky=1:Ny
            signal_temp=unwrap(squeeze(Images_dicom_rescaled(kx,ky,1:Nimages)-Images_dicom_rescaled(kx,ky,1)),pi);
            [B, D, STATUS]=levenbergmarquardt('fitB0_MRF',TE-TE(1),signal_temp',[1]); % /!\ ne pas initialiser à 0Hz, ne fonctionne pas
            B0Map(kx,ky)=B(1);
            dB0Map(kx,ky)=D(1);
            status(kx,ky)=STATUS; % fit réussi si status=-1, fit échoué si status>0
    end
end

% min_invdTE=1/(min(TE(2:Nimages))-TE(1));  % En fait l'algorithme de fit ne sort jamais de valeurs au delà, donc bout de code inutile
% B0Map(find(B0Map(:,:)>min_invdTE/2))=B0Map(find(B0Map(:,:)>min_invdTE/2))-min_invdTE; 
% B0Map(find(B0Map(:,:)<-min_invdTE/2))=B0Map(find(B0Map(:,:)<-min_invdTE/2))+min_invdTE;

%% Plot carte de df
figure('Name','Carte de B0','units','normalized','outerposition',[1/3 1/3 1/2 1/2])
imagesc(B0Map)
daspect([1 1 1])
title('Off-resonance df (Hz)')
caxis([-100 100])
colorbar
set(gcf,'color','w');


clear Images_dicom VisuCoreDataSlope kx ky signal_temp B D STATUS
