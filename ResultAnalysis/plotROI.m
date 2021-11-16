lastEcho = 150;
I = dcm2matrix_MRFv3('/SUMMER/projects/Share/Data pour Aurélien/20210505_112732_20210428_Gi_R4_J2D0pre_20210428_Gi_R4_J2D0p_1_1/3', lastEcho);
Image = I.Images_dicom_rescaled;
%%
figure();
imagesc(mean(Image(:,:,1,1:end),4))
% imagesc(Image(:,:,1,100))
msk = roipoly;
%%
im = I.Images_dicom_rescaled;
toMatch = zeros(1, lastEcho);
count = 0;
for i = 1:size(im,1)
    for j = 1:size(im,2)
        if msk(i,j)
            toMatch = toMatch + squeeze(Image(i,j,1,:))';
            count = count +1;
        end
    end
end
if count > 0
    toMatch = toMatch ./ count;
end

%%
% TE = 10:10:lastEcho * 3;
TE = 1:1:lastEcho;
figure();
plot(TE, toMatch)
% figure();
% plot(TE, log(toMatch))