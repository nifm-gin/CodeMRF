clear all

%% Chargement des images : dossier contenant le fichier method de la sequence
dossier_method='D:\Experiments\2017\Mai\2017-05-19\20170519_094231_2017_05_19_1_1\14';

%% Chargement d'une carte de B1rel de m�me g�om�trie
load('D:\MATLAB\MRF_v3_SliceProfile_flux\Data\2017-05-19\Cartes de r�f�rence\B1relMaps\B1map_MRF_E12.mat', 'B1relMap')
% If no map is loaded, a B1 equal to 1 everywhere will be assumed in the fit. 

%% Read method file
method=fopen(strcat(dossier_method,'\method'),'r','ieee-le');
texteMethod=char(fread(method,[inf],'int8'));
fclose(method);
texteMethod=texteMethod(:)';
Nimages=scan_acqp('##$PVM_NRepetitions=',texteMethod,1); % ---------------------- A VERIFIER
TI=scan_acqp('##$MRF_TIList=',texteMethod,1); % ---------------------- A VERIFIER
clear texteMethod ans

%% Load & rescale images
dossier_visu=strcat(dossier_method,'\pdata\1');
dossier=strcat(dossier_visu,'\dicom\');
clear dossier_method

if Nimages>99
    X=dicomread(strcat(dossier,'MRIm001.dcm'));
elseif Nimages>9
    X=dicomread(strcat(dossier,'MRIm01.dcm'));
else
    X=dicomread(strcat(dossier,'MRIm1.dcm'));
end
[Nx,Ny]=size(X);
clear X;

Images_dicom=zeros(Nx,Ny,Nimages);
for i=1:Nimages
    if Nimages>999
        filename=sprintf('MRIm%04i.dcm',i);
    elseif Nimages>99
        filename=sprintf('MRIm%03i.dcm',i);
    elseif Nimages>9
        filename=sprintf('MRIm%02i.dcm',i);
    else
        filename=sprintf('MRIm%01i.dcm',i);
    end
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
    Images_dicom_rescaled(:,:,i)=double(Images_dicom(:,:,i))*VisuCoreDataSlope(i);
end
clear i% VisuCoreDataMax VisuCoreDataSlope
clear dossier filename

%% Fit 2 param�tres -> carte de T1
T1Map=zeros(Nx,Ny);

if ~exist('B1relMap')
    B1relMap=ones(Nx,Ny);
end

for kx=1:Nx
    for ky=1:Ny
        if Images_dicom_rescaled(kx,ky,1)>0  % Pour les voxels  p�riph�riques de signal nul, on pose T1=0ms
            global B1
            B1=B1relMap(kx,ky);
            signal_temp=squeeze(Images_dicom_rescaled(kx,ky,:));

            [B, D, STATUS]=levenbergmarquardt('fitT1_MRF',TI,signal_temp,[1000 max(signal_temp)]);
            T1Map(kx,ky)=B(1);
%             plot(TI,signal_temp); hold on; plot(TI, B(3)+ B(2).*abs(1-2.*exp(-TI/B(1))));hold off;title(strcat(num2str(B(1)),'  ',num2str(B1))); pause;%---------

            dT1Map(kx,ky)=D(1);
            Amplitude(kx,ky)=B(2);
%             Offset(kx,ky)=B(3);
            status(kx,ky)=STATUS; % fit r�ussi si status=-1, fit �chou� si status>0
        end
    end
end
clear global B1

%% Plot carte de T1
figure('Name','Carte de T1','units','normalized','outerposition',[1/3 1/3 1/2 1/2])
imagesc(T1Map)
daspect([1 1 1])
title('T1 (ms)')
caxis([0 3000])
colorbar
set(gcf,'color','w');


clear Images_dicom VisuCoreDataMax VisuCoreDataSlope kx ky signal_temp B D STATUS method