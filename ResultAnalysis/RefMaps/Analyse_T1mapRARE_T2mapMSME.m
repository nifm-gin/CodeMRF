clear all
% close all
% clc



%% Path to the folder that contains que visu_pars file
dossier_visu='D:\Experiments\2016\Novembre\2016-11-16\20161116_091617_2016_11_16_1_1\7\pdata\2';


name='T1map';
plotOnOff='On'; % On ou Off




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

Images_dicom=dicomread(strcat(dossier,'MRIm3.dcm'));
[Nx,Ny]=size(Images_dicom);
clear dossier_visu;


%% Rescale images intensity
assignin('base',name,double(Images_dicom)*VisuCoreDataMax(3)*VisuCoreDataSlope(3)/32767);
clear Images_dicom VisuCoreDataMax VisuCoreDataSlope


clear dossier filename i

%% Plot
if strcmp(plotOnOff,'On')
    figure
imagesc(eval(name))
colorbar
if strcmp(name,'T2map')
    caxis([0 300])
else
caxis([0 2500])
end
daspect([1 1 1])
title(strcat(name,' (ms)'))
set(gcf,'color','w');
clear k plotOnOff name unit
end