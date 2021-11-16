function Images = dcm2matrix_MRFv3(acqPath, lastEcho)
% Fetch useful parameters from Bruker Files (e.g. method, visu_pars) and
% reads dicom files accordingly
% -------------------------------------------------------------------------
% - acqPath: BRUKER : Path to scan ex: "/home/data/yyyymmdd_scan_/1", this directory
% should contain the method file and pdata/ directory
%            PHILIPS : Path to scan ex /home/data/ExamName/ProtocoleName/, this 
% directory should contain the DICOM directory
% - lastEcho: optional, indicates the last echo to consider. By default all
% echoes are used.
%
% - Images: Structure containing image data and metadata
% -------------------------------------------------------------------------

if nargin < 2
    lastEcho = 0;
end

if isfolder(fullfile(acqPath, 'pdata', '1'))
    %% Set paths
    % visu_pars is read in pdata/1 (or reco number)
    pathPData = fullfile(acqPath, 'pdata', '1');
    pathDcm = fullfile(pathPData, 'dicom');
    Images=struct;
    
    %% Read method bruker file and get parameters
    fidMethod=fopen(fullfile(acqPath, 'method'), 'r', 'ieee-le');
    if fidMethod > 0
        texteMethod=fread(fidMethod, inf, '*char');
        fclose(fidMethod);
        texteMethod=texteMethod(:)';
    else
        error('Could not open file %s', fullfile(acqPath, 'method'))
    end
    
    try
        % read number of pulses /!\ ONLY WORKS FOR MRF TAGGED SEQUENCES
        Images.nImages = scan_acqp('##$MRF_NPulses=',texteMethod,1);
    catch
        error('"MRF_NPulses" not found in method file. The scan must be "MRF-tagged"')
    end
    
    % read slice thickness
    Images.PVM_SliceThick = scan_acqp('##$PVM_SliceThick=',texteMethod,1);
    
    %% Open visuPars Bruker file and read it
    % visu_pars=fopen(strcat(Images.dossier_visu,'/visu_pars'),'r','ieee-le');
    fidVisuPars = fopen(fullfile(pathPData, 'visu_pars'), 'r','ieee-le');
    if fidVisuPars > 0 % if file opened
        texteVisuPars = fread(fidVisuPars, inf, '*char');
        fclose(fidVisuPars);
        texteVisuPars=texteVisuPars(:)';
    else
        error('Could not open file %s', fullfile(pathPData, 'visu_pars'))
    end
    
    %% Extract parameters
    % image size on X and Y
    S = scan_acqp('##$VisuCoreSize=', texteVisuPars,1);
    Images.nX = S(1);
    Images.nY = S(2);
    
    % Slice number (position of each slice in 3D) -> divide number by 3
    %Could be size(Z,1) but unsure about behavior with slice packages
    Z = scan_acqp('##$VisuCorePosition=', texteVisuPars,1);
    Images.nZ = numel(Z)/3;
    % nb of time points /!\ UNSURE ABOUT ROBUSTNESS
    frameCount = scan_acqp('##$VisuCoreFrameCount=',texteVisuPars,1);
    Images.nImages = frameCount/Images.nZ;
    
    %"Data Slope" needed to apply transform to data to "real" values
    VisuCoreDataSlope=scan_acqp('##$VisuCoreDataSlope=',texteVisuPars,1);
    
    if lastEcho == 0
        lastIdx = Images.nImages;
    else
        lastIdx = lastEcho;
    end
    
    %% Open all images in order
    
    Images.Images_dicom = zeros(Images.nX, Images.nY, Images.nZ, lastIdx);
    nDcm = Images.nImages*Images.nZ;
    
    for slice = 1 : Images.nZ
        for pulse = 0: lastIdx-1
            if nDcm > 999
                filename = sprintf('MRIm%04i.dcm', pulse*Images.nZ +1 + (slice-1));
            elseif nDcm > 99
                filename = sprintf('MRIm%03i.dcm', pulse*Images.nZ +1 + (slice-1));
            elseif nDcm > 9
                filename = sprintf('MRIm%02i.dcm', pulse*Images.nZ +1 + (slice-1));
            else
                filename = sprintf('MRIm%01i.dcm', pulse*Images.nZ +1 + (slice-1));
            end
            Images.Images_dicom(:, :, slice, pulse + 1) = dicomread(fullfile(pathDcm, filename));
        end
    end
    
    
    %% Apply linear transformation
    for z = 1 : Images.nZ
        for i=1:lastIdx
            Images.Images_dicom_rescaled(:,:,z, i) = double(Images.Images_dicom(:,:, z, i))*VisuCoreDataSlope(i);
        end
    end
    
    Images.nImages = lastIdx;
elseif isfolder(fullfile(acqPath, 'DICOM'))
    dicomPath = fullfile(acqPath, 'DICOM');
    d = dir(dicomPath);
    d = {d.name};
    idxIm = contains(d, 'IM_');
%     fprintf('Loading dicom...')
    allImages = dicomread(fullfile(dicomPath, d{idxIm}));
    S = size(allImages);
    Images.Images_dicom_rescaled = permute(reshape(permute(allImages, [1,2,4,3]), [S(1), S(2), lastEcho, S(4)/lastEcho]), [1,2,4,3]);
    Images.Images_dicom_rescaled = double(Images.Images_dicom_rescaled);
    Images.Images_dicom = Images.Images_dicom_rescaled;
%     fprintf(' Done!\n')
%     Images.Images_dicom_rescaled = Images.Images_dicom_rescaled(:,:,1,1:lastEcho);
    Images.nX = S(1);
    Images.nY = S(2);
    Images.nZ = S(4)/lastEcho;
    Images.nImages = size(Images.Images_dicom_rescaled, 4);
else
    error('File structure not identified')
end
end
