% clear all

dossier_visu='D:\Experiments\2017\Mai\2017-05-19\20170519_094231_2017_05_19_1_1\10';
Nimages=6;

DrawROIYesNo='No';
SignalROIYesNo='No';
image_roi=6; % image à afficher pour tracer la ROI (doit contenir du signal !)
carteB1OnOff='Off';
    if strcmp(carteB1OnOff,'On')
        load('D:\MATLAB\MRF_v3_SliceProfile_flux\Data\2017-05-19\Cartes de référence\B1relMaps\B1map_MRF_E12.mat', 'B1relMap')
    end


%% Load DICOM images
dossier=strcat(dossier_visu,'\pdata\1\dicom\');
if Nimages>999
    X=dicomread(strcat(dossier,'MRIm0001.dcm'));
elseif Nimages>99
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

%% Read visu_pars file
visu_pars=fopen(strcat(dossier_visu,'\pdata\1\visu_pars'),'r','ieee-le');
texteVisuPars=char(fread(visu_pars,[inf],'int8'));
fclose(visu_pars);
texteVisuPars=texteVisuPars(:)';
clear ans visu_pars
VisuCoreDataMax=scan_acqp('##$VisuCoreDataMax=',texteVisuPars,1);
VisuCoreDataSlope=scan_acqp('##$VisuCoreDataSlope=',texteVisuPars,1);
clear texteVisuPars


%% Rescale Images with VisuCoreDataMax and VisuCoreDataSlope
for i=1:Nimages
    Images_dicom_rescaled(:,:,i)=double(Images_dicom(:,:,i))*VisuCoreDataSlope(i);%*VisuCoreDataMax(i)
end
clear i% VisuCoreDataMax VisuCoreDataSlope

clear dossier filename

%% Plot images
lim=max(max(max(Images_dicom)));

for k=1:Nimages
    imagesc(Images_dicom(:,:,k))
    caxis([0 lim])
    pause
end
clear k lim
close all


%% Read method file
method=fopen(strcat(dossier_visu,'\method'),'r','ieee-le');
texteMethod=char(fread(method,[inf],'int8'));
fclose(method);
texteMethod=texteMethod(:)';
clear ans visu_pars
MultiRepTime=scan_acqp('##$MultiRepTime=',texteMethod,1);
clear dossier_visu texteMethod

%% Draw ROI and extract mean signal over the time
if strcmp(DrawROIYesNo,'Yes')
    imagesc(Images_dicom(:,:,image_roi))
    ROI=roipoly;
end
if strcmp(SignalROIYesNo,'Yes')
    for k=1:Nimages
        signal(k)=sum(sum(Images_dicom(:,:,k).*ROI))./sum(ROI(:));
    end
    plot(MultiRepTime,signal)
    title('Signal moyen dans la ROI')
    pause
end


%% Reconstruction
if strcmp(carteB1OnOff,'On');
    global B1rel
    for kx=1:Nx
        for ky=1:Ny
            B_init=[max(Images_dicom_rescaled(:)) max(Images_dicom_rescaled(:))/10 500];
            B1rel=B1relMap(kx,ky);
            if B1rel<0.4
                T1map_ms(kx,ky)=0;
                Amplitude(kx,ky)=0;
                Offset(kx,ky)=0;
            else
            [B, D, STATUS]=levenbergmarquardt('fitT1_avecB1',MultiRepTime(2:end),squeeze(Images_dicom_rescaled(kx,ky,2:end)),B_init);
            Amplitude(kx,ky)=B(1);
            Offset(kx,ky)=B(2);
            T1map_ms(kx,ky)=max(0,min(5555,B(3)));
            end
        end
    end
    clear B1rel
else
    for kx=1:Nx
        for ky=1:Ny
            B_init=[max(Images_dicom_rescaled(:)) max(Images_dicom_rescaled(:))/10 500];
            [B, D, STATUS]=levenbergmarquardt('fitT1',MultiRepTime(2:end),squeeze(Images_dicom_rescaled(kx,ky,2:end)),B_init);
            Amplitude(kx,ky)=B(1);
            Offset(kx,ky)=B(2);
            T1map_ms(kx,ky)=max(0,min(5555,B(3)));
        end
    end
end
figure
imagesc(T1map_ms)
caxis([0 2*median(T1map_ms(:))])
colorbar
set(gcf,'color','w');
title('Calculated T1 map (ms) - T1mapRARE')
daspect([1 1 1])

if exist('ROI')
    meanT1_ROI=sum(sum(ROI.*T1map_ms))/sum(ROI(:))
end