function Images = fp_normalization_MRFv3(Images)  
% Computes norm of time vectors in rescaled image and normalizes image
% -------------------------------------------------------------------------
% Images struct must contain fields:
% - nX, nY, nZ, nImages (dimensions of acq in space and time)
% - Images_dicom_rescaled (rescaled signal)

% New fields in Images struct:
% - Image_normalized_dicom: normalized image
% - norme_dicom: norms of time signals
% -------------------------------------------------------------------------

% Allow memory
Images.Image_normalized_dicom = zeros(Images.nX, Images.nY, Images.nZ, Images.nImages);
Images.norme_dicom = zeros(Images.nX, Images.nY, Images.nZ);

% Compute norm on the last dimension of rescaled image (= time dimension)
Images.norme_dicom = vecnorm(Images.Images_dicom_rescaled,2, numel(size(Images.Images_dicom_rescaled)));

% Apply norm
Images.Image_normalized_dicom = Images.Images_dicom_rescaled ./ Images.norme_dicom;


