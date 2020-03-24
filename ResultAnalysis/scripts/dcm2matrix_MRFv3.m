function Images = dcm2matrix_MRFv3(acqPath)

pathPData = fullfile(acqPath, 'pdata', '1');
pathDcm = fullfile(pathPData, 'dicom');
Images=struct;
%%%%%%%%%% Commented to try to find someting simpler

% %% Get number of frames (time points)
% Images.nImages = size(dictionary,2);
% 
% %% Open first image and get its size
% Images.dossier=strcat(Images.dossier_visu,'/dicom/');
% if Images.nImages>999
%     X=dicomread(strcat(Images.dossier,'MRIm0001.dcm'));
% elseif Images.nImages>99
%     X=dicomread(strcat(Images.dossier,'MRIm001.dcm'));
% elseif Images.nImages>9
%     X=dicomread(strcat(Images.dossier,'MRIm01.dcm'));
% else
%     X=dicomread(strcat(Images.dossier,'MRIm1.dcm'));
% end
% 
% [Images.nX,Images.nY]=size(X);
% clear X;

%% Open visuPars Bruker file and read it
% visu_pars=fopen(strcat(Images.dossier_visu,'/visu_pars'),'r','ieee-le');
fidVisuPars = fopen(fullfile(pathPData, 'visu_pars'), 'r','ieee-le');
if fidVisuPars > 0 % if file opened
    texteVisuPars = fread(fidVisuPars, inf, '*char');
% texteVisuPars=char(fread(visu_pars,[inf],'int8'));
    fclose(fidVisuPars);
    texteVisuPars=texteVisuPars(:)';
else
    error('Could not open file %s', fullfile(pathPData, 'visu_pars'))
end

%% Extract parameters
Images.nImages = scan_acqp('##$VisuCoreFrameCount=',texteVisuPars,1); % nb of time points
S = scan_acqp('##$VisuCoreSize=', texteVisuPars,1)'; % image size
Images.nX = S(1); 
Images.nY = S(2);
VisuCoreDataSlope=scan_acqp('##$VisuCoreDataSlope=',texteVisuPars,1); %Needed to apply transform to data

%% Open all images in order
% Images.dossier=strcat(Images.dossier_visu,'/dicom/');
Images.Images_dicom = zeros(Images.nX,Images.nY,Images.nImages);
for i=1:Images.nImages
    if Images.nImages>999
        filename = sprintf('MRIm%04i.dcm',i);
    elseif Images.nImages>99
        filename = sprintf('MRIm%03i.dcm',i);
    elseif Images.nImages>9
        filename = sprintf('MRIm%02i.dcm',i);
    else
        filename = sprintf('MRIm%01i.dcm',i);
    end
    Images.Images_dicom(:,:,i) = dicomread(fullfile(pathDcm, filename));
end

%% Apply linear transformation
% visu_pars=fopen(strcat(Images.dossier_visu,'/visu_pars'),'r','ieee-le');
% texteVisuPars = fread(visu_pars, inf, '*char');
% % texteVisuPars=char(fread(visu_pars,[inf],'int8'));
% fclose(visu_pars);
% texteVisuPars=texteVisuPars(:)';
% clear ans visu_pars
% % Images.VisuCoreDataMax=scan_acqp('##$VisuCoreDataMax=',texteVisuPars,1);
% Images.VisuCoreDataSlope=scan_acqp('##$VisuCoreDataSlope=',texteVisuPars,1); %Needed to apply transform to data
% clear texteVisuPars filename

for i=1:Images.nImages
    Images.Images_dicom_rescaled(:,:,i)=double(Images.Images_dicom(:,:,i))*VisuCoreDataSlope(i);%/32767;%*Images.VisuCoreDataMax(i)
end
% clear i% Images.VisuCoreDataMax Images.VisuCoreDataSlope
% clear Images.Images_dicom

%% Read method bruker file and get parameters
% dossier_init=pwd;
% cd(Images.dossier_visu)
% cd ..
% cd ..
fidMethod=fopen(fullfile(acqPath, 'method'), 'r', 'ieee-le');
if fidMethod > 0
% texteMethod=char(fread(method,[inf],'int8'));
    texteMethod=fread(fidMethod, inf, '*char');
    fclose(fidMethod);
    texteMethod=texteMethod(:)';
else
    error('Could not open file %s', fullfile(acpPath, 'method'))
end
% clear ans method
Images.PVM_SliceThick=scan_acqp('##$PVM_SliceThick=',texteMethod,1);
% cd(dossier_init)
% clear Images.dossier_visu texteMethod dossier_init
end
