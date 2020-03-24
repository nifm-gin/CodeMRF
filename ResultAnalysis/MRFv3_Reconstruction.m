%clear all
% Properties.vlist=0;
%% Load images 
% Images=struct;
% Images.nImages=500;
acqPath = '~/Data/IRM/20200310_144251_tube_lego_1_1/4';
% Images.dossier_visu='/SUMOONE/delphin/Data/20200310_144251_tube_lego_1_1/4/pdata/1';
% Images.dossier_visu = '~/Data/IRM/20200310_144251_tube_lego_1_1/4/pdata/1';
% Images.dossier_visu='/SUMOONE/delphin/Data/20200310_144251_tube_lego_1_1/4/pdata/1';

% Images.dossier_visu='/SUMOONE/delphin/Data/20200311_103846_AVC_HP1_R1_1_1/10/pdata/1';
%% Load Dico
pathToDico = '/home/aurelien/Installations/CodeMRF/DictionaryCreation/Results/ad100Calculated_v9_ph0_v2';

pathSplit = split(pathToDico, filesep);
load(fullfile(pathToDico, ['dico_', pathSplit{end}, '.mat']), 'dictionary')
% load([pathToDico, filesep, 'dico_', pathSplit{end}, '.mat'], 'dictionary')
% load([pathToDico, filesep, 'prop_', pathSplit{end}, '.mat'], 'Properties')
load(fullfile(pathToDico, ['prop_', pathSplit{end}, '.mat']), 'Properties')

%% Read dicom files in order
Images = dcm2matrix_MRFv3(acqPath);

%% renormalization
Images = fp_normalization_MRFv3(Images);

%% Load dico
% load('D:\MATLAB\MRF_v3_SliceProfile_flux\Dictionnaires\sinus_5_lobes_invOnOff_FAaltOnOff\dico_5lobessinus1_v10_4cycles_inv_FApos_prop20170519_fulldf.mat')
% dictionary = D.Dictionary;
% Rescale vlist if experimental SliceThickness different from the dictionary slice thickness (usually 1mm)
% Properties.vlist=Properties.vlist*Images.PVM_SliceThick/Parameters.SliceThickness;


%% Reco sans a priori sur B1 & affichage des r�sultats
Reconstruction=struct;
Reconstruction.treshholdOnOff='Off';
if strcmp(Reconstruction.treshholdOnOff,'On')
    Reconstruction.seuil=0.5;
end
if length(Properties.vlist)>1
    analyse_flux_MRFv3;
    for kx=1:Images.nX
        for ky=1:Images.nY
            Reconstruction.PDmap(kx,ky)=Images.norme_dicom(kx,ky)./norm(abs(squeeze(dico_flux(Reconstruction.t_exp_T1T2dfB1(kx,ky),:,Reconstruction.t_exp_v(kx,ky)))));
        end
    end
    affichage_resultats_MRFv3;
    plot_data_et_match_MRFv3;
else
    for k=1:Images.nY/2 % BOUCLE COUPEE EN DEUX SINON MATRICE TROP GROSSE ----------------------------
        [Reconstruction.innerproduct(:,k),Reconstruction.idxMatch(:,k)]= templatematch_MRFv3(abs(dictionary(:,(2:end))),squeeze(Images.Image_normalized_dicom(:,k,2:end)));
    end
    for k=(Images.nY/2+1):Images.nY %
        [Reconstruction.innerproduct(:,k),Reconstruction.idxMatch(:,k)]= templatematch_MRFv3(abs(dictionary(:,(2:end))),squeeze(Images.Image_normalized_dicom(:,k,2:end)));
    end
    for kx=1:Images.nX
        for ky=1:Images.nY
            Reconstruction.PDmap(kx,ky)=Images.norme_dicom(kx,ky)./norm(abs(squeeze(dictionary(Reconstruction.idxMatch(kx,ky),:))));
        end
    end
    affichage_resultats_MRFv3_sansflux;
    plot_data_et_match_MRFv3_sansflux;
end

clear h filename k




%% Reco avec a priori sur B1 (UNIQUEMENT SI UNE SEULE VITESSE !)
% load('D:\MATLAB\MRF_v3_SliceProfile_flux\Data\2017-01-11\Cartes de r�f�rence\allmaps.mat', 'B1relMap')
% Reconstruction=struct;
%
% Reconstruction.treshholdOnOff='On'; if strcmp(Reconstruction.treshholdOnOff,'On')
%                                         Reconstruction.seuil=0.5;
%                                     end
% for j=1:Images.nX
%     j
% for k=1:Images.nY
%     B1tmp=Properties.B1rel(find(abs(Properties.B1rel-B1relMap(j,k))==min(abs(Properties.B1rel-B1relMap(j,k)))));
%     indices=find(Properties.B1rellist(:)==B1tmp);
%         [Reconstruction.innerproduct(j,k),Reconstruction.idxMatch(j,k)]= templatematch_MRFv3(abs(dictionary(indices,(2:end))),squeeze(Images.Image_normalized_dicom(j,k,2:end))');
%         Reconstruction.idxMatch(j,k)=indices(Reconstruction.idxMatch(j,k));
% end
% end
%     for kx=1:Images.nX
%         for ky=1:Images.nY
%     Reconstruction.PDmap(kx,ky)=Images.norme_dicom(kx,ky)./norm(abs(squeeze(dictionary(Reconstruction.idxMatch(kx,ky),:))));
%         end
%     end
%     affichage_resultats_MRFv3_sansflux;
%     plot_data_et_match_MRFv3_sansflux;
%
%
% clear h filename k j