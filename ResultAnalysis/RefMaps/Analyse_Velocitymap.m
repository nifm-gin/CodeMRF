clear all
% close all
% clc



%% Path to the folder that contains que visu_pars file
dossier_visu='D:\Experiments\2016\Août\2016-08-19\20160819_102309_2016_08_19_1_1\9\pdata\1';

name='Velocity_map';
plotOnOff='On'; % On of Off




%% Get VisuCoreDataMax and VisuCoreDataSlope
visu_pars=fopen(strcat(dossier_visu,'\visu_pars'),'r','ieee-le');
texteVisuPars=char(fread(visu_pars,[inf],'int8'));
fclose(visu_pars);
texteVisuPars=texteVisuPars(:)';
clear ans visu_pars
VisuCoreDataSlope=scan_acqp('##$VisuCoreDataSlope=',texteVisuPars,1);
clear texteVisuPars


%% Get images
dossier=strcat(dossier_visu,'\dicom\');

Images_dicom=dicomread(strcat(dossier,'MRIm1.dcm'));
[Nx,Ny]=size(Images_dicom);
clear dossier_visu;


%% Rescale images intensity
assignin('base',name,double(Images_dicom)*VisuCoreDataSlope(1));
clear Images_dicom VisuCoreDataMax VisuCoreDataSlope


clear dossier filename i

%% Plot
if strcmp(plotOnOff,'On')
    figure
imagesc(abs(eval(name)))
colorbar
% caxis([0 20])
daspect([1 1 1])
title(strcat('Absolute transverse velocity map (cm/s)'))
set(gcf,'color','w');
clear k plotOnOff name unit
set(gcf,'color','w')
end