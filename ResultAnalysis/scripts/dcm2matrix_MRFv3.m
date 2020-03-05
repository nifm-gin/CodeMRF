Images.dossier=strcat(Images.dossier_visu,'/dicom/');
if Images.Nimages>999
    X=dicomread(strcat(Images.dossier,'MRIm0001.dcm'));
elseif Images.Nimages>99
    X=dicomread(strcat(Images.dossier,'MRIm001.dcm'));
elseif Images.Nimages>9
    X=dicomread(strcat(Images.dossier,'MRIm01.dcm'));
else
    X=dicomread(strcat(Images.dossier,'MRIm1.dcm'));
end


[Images.Nx,Images.Ny]=size(X);
clear X;
Images.Images_dicom=zeros(Images.Nx,Images.Ny,Images.Nimages);

for i=1:Images.Nimages
    if Images.Nimages>999
        filename=sprintf('MRIm%04i.dcm',i);
    elseif Images.Nimages>99
        filename=sprintf('MRIm%03i.dcm',i);
    elseif Images.Nimages>9
        filename=sprintf('MRIm%02i.dcm',i);
    else
        filename=sprintf('MRIm%01i.dcm',i);
    end
    Images.Images_dicom(:,:,i)=dicomread(strcat(Images.dossier,filename));
end


visu_pars=fopen(strcat(Images.dossier_visu,'/visu_pars'),'r','ieee-le');
texteVisuPars=char(fread(visu_pars,[inf],'int8'));
fclose(visu_pars);
texteVisuPars=texteVisuPars(:)';
clear ans visu_pars
 Images.VisuCoreDataMax=scan_acqp('##$VisuCoreDataMax=',texteVisuPars,1);
 Images.VisuCoreDataSlope=scan_acqp('##$VisuCoreDataSlope=',texteVisuPars,1);
clear texteVisuPars filename

for i=1:Images.Nimages
    Images.Images_dicom_rescaled(:,:,i)=double(Images.Images_dicom(:,:,i))*Images.VisuCoreDataSlope(i);%/32767;%*Images.VisuCoreDataMax(i)
end
clear i% Images.VisuCoreDataMax Images.VisuCoreDataSlope
clear Images.Images_dicom


dossier_init=pwd;
cd(Images.dossier_visu)
cd ..
cd ..
method=fopen('method','r','ieee-le');
texteMethod=char(fread(method,[inf],'int8'));
fclose(method);
texteMethod=texteMethod(:)';
clear ans method
Images.PVM_SliceThick=scan_acqp('##$PVM_SliceThick=',texteMethod,1);
cd(dossier_init)
clear Images.dossier_visu texteMethod dossier_init
