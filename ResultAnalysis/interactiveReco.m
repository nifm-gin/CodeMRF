% This script loads MRF dicoms from PV6 and a dictionary (dico_ prop_ seq_ format)
% and displays the image at one time point. 
% When an ROI is drawn on the image, the signals in the corresponding voxels are averaged and matched against the dictionary

% path to data (exported to DCM from PV6) "/home/data/yyyymmdd_scan_/1"
acqPath = '/home/aurelien/Data/IRM/20200311_103846_AVC_HP1_R1_1_1/10';
% path to dico, directory must contain dico_, prop_
pathToDico = '/home/aurelien/Installations/CodeMRF/DictionaryCreation/Results/ad1000_v9_ph0_B1_df_v2';
pathSplit = split(pathToDico, filesep);
% Last Echo to use
lastEcho = 500;

%%
load(fullfile(pathToDico, ['dico_', pathSplit{end}, '.mat']), 'dictionary');
load(fullfile(pathToDico, ['prop_', pathSplit{end}, '.mat']), 'Properties');
dictionary = dictionary(:, 1:lastEcho);
Images = dcm2matrix_MRFv3(acqPath, lastEcho);
Images = fp_normalization_MRFv3(Images);
dictionary = abs(dictionary(:,1:lastEcho));
normDictionary = vecnorm(dictionary, 2, 2);
dictionary = dictionary./ normDictionary;

%%
Image = squeeze(Images.Image_normalized_dicom);
im = squeeze(Image(:,:,25));

%%
f = figure;
subplot(1,3,1)
% hold on
I = imagesc(im);
pbaspect([1,1,1]);
hold on 
msk = roipoly;
% msk = repmat(msk, [1,1, size(Image, 3)]);
M = imagesc(~msk, 'AlphaData', 0.5);
toMatch = zeros(1, lastEcho);
count = 0;
for i = 1:size(im,1)
    for j = 1:size(im,2)
        if msk(i,j)
            toMatch = toMatch + squeeze(Image(i,j,:))';
            count = count +1;
        end
    end
end
if count > 0
    toMatch = toMatch ./ count;
end
Reconstruction=struct;
Reconstruction.treshholdOnOff='Off';
[Reconstruction.innerproduct, Reconstruction.idxMatch]= mrfMatching(dictionary, toMatch);

subplot(1,3,[2,3])
hold on
plot(toMatch, '-b')
plot(dictionary(Reconstruction.idxMatch,:), '-r')
legend('ROI', 'Match')
xlim([1, lastEcho ])
pbaspect([3,1,1])
