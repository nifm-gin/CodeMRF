clear all
% close all
% clc



%% Path to the folder that contains que visu_pars file
dossier_visu='D:\Experiments\2016\Novembre\2016-11-16\20161116_091617_2016_11_16_1_1\26\pdata\1';

plotOnOff='On'; % On of Off




%% Get Nimages
reco=fopen(strcat(dossier_visu,'\reco'),'r','ieee-le');
texteReco=char(fread(reco,[inf],'int8'));
fclose(reco);
texteReco=texteReco(:)';
clear ans reco
Nimages=scan_acqp('##$RECO_inp_size=',texteReco,1);
Nimages=Nimages(3);
clear texteReco


%% Get VisuCoreDataMax and VisuCoreDataSlope
visu_pars=fopen(strcat(dossier_visu,'\visu_pars'),'r','ieee-le');
texteVisuPars=char(fread(visu_pars,[inf],'int8'));
fclose(visu_pars);
texteVisuPars=texteVisuPars(:)';
clear ans visu_pars
VisuCoreDataMax=scan_acqp('##$VisuCoreDataMax=',texteVisuPars,1);
VisuCoreDataSlope=scan_acqp('##$VisuCoreDataSlope=',texteVisuPars,1);
clear texteVisuPars


%% Get images
dossier=strcat(dossier_visu,'\dicom\');
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
clear X dossier_visu;
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


%% Rescale images intensity
B0map=double(Images_dicom)*VisuCoreDataMax*VisuCoreDataSlope/32767;
clear Images_dicom VisuCoreDataMax VisuCoreDataSlope


clear dossier filename i

%% Plot
if strcmp(plotOnOff,'On')
for k=1:Nimages
imagesc(squeeze(B0map(:,:,k)))
colorbar
caxis([-100 100])
daspect([1 1 1])
title({'B0map (Hz)', strcat('Image n°',num2str(k))})
set(gcf,'color','w');
pause
end
clear k plotOnOff
end