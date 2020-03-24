function Images = fp_normalization_MRFv3(Images)  

% Images.Image_normalized_dicom=0*Images.Images_dicom_rescaled;
Images.Image_normalized_dicom = zeros(Images.nX, Images.nY, Images.nImages);
Images.norme_dicom = zeros(Images.nX, Images.nY);

for i=1:Images.nX
    for j=1:Images.nY
%         Images.norme_dicom(i,j)=norm(squeeze(Images.Images_dicom_rescaled(i,j,2:Images.nImages)));
        Images.norme_dicom(i,j) = norm(squeeze(Images.Images_dicom_rescaled(i,j,:)));
        if Images.norme_dicom(i,j) ~= 0
            Images.Image_normalized_dicom(i,j,:) = Images.Images_dicom_rescaled(i,j,:)/Images.norme_dicom(i,j);
        end
    end
end


% 
% Tube_normalized=0*Tube;
% 
% for i=1:30
%     for j=1:64
%         norme(i,j)=norm(squeeze(Tube(i,j,:)));
%         if norme(i,j)~=0
%         Tube_normalized(i,j,:)=Tube(i,j,:)/norme(i,j);
%         end
%     end
% end
% 
% figure
% imagesc(norme)
% title('Proton density (AU)')