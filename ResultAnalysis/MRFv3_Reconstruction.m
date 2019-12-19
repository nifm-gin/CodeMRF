clear all

%% Load images + renormalization
Images=struct;
Images.Nimages=500;
Images.dossier_visu='D:\Experiments\2016\Novembre\2016-11-16\20161116_091617_2016_11_16_1_1\19\pdata\1';

dcm2matrix_MRFv3;
fp_normalization_MRFv3;

%% Load dico
% load('D:\MATLAB\MRF_v3_SliceProfile_flux\Dictionnaires\sinus_5_lobes_invOnOff_FAaltOnOff\dico_5lobessinus1_v10_4cycles_inv_FApos_prop20170519_fulldf.mat')
load('D:\MATLAB\MRF_v3_SliceProfile_flux\Dictionnaires\Dico_flux\dico_2016-06-01-2_v9_4cycles_FApos_prop20170519_flux.mat')

% Rescale vlist if experimental SliceThickness different from the dictionary slice thickness (usually 1mm)
% Properties.vlist=Properties.vlist*Images.PVM_SliceThick/Parameters.SliceThickness;
 

%% Reco sans a priori sur B1 & affichage des résultats
Reconstruction=struct;
Reconstruction.treshholdOnOff='On'; if strcmp(Reconstruction.treshholdOnOff,'On')
                                        Reconstruction.seuil=0.95;
                                    end
if length(Properties.vlist)>1
    analyse_flux_MRFv3;
    for kx=1:Images.Nx
        for ky=1:Images.Ny
    Reconstruction.PDmap(kx,ky)=Images.norme_dicom(kx,ky)./norm(abs(squeeze(dico_flux(Reconstruction.t_exp_T1T2dfB1(kx,ky),:,Reconstruction.t_exp_v(kx,ky)))));
        end
    end
    affichage_resultats_MRFv3;
    plot_data_et_match_MRFv3;
else
    for k=1:Images.Ny/2 % BOUCLE COUPEE EN DEUX SINON MATRICE TROP GROSSE ----------------------------
        [Reconstruction.innerproduct(:,k),Reconstruction.t_exp_dicom(:,k)]= templatematch_MRFv3(abs(dictionary(:,(2:end))),squeeze(Images.Image_normalized_dicom(:,k,2:end)));
    end
    for k=(Images.Ny/2+1):Images.Ny % 
        [Reconstruction.innerproduct(:,k),Reconstruction.t_exp_dicom(:,k)]= templatematch_MRFv3(abs(dictionary(:,(2:end))),squeeze(Images.Image_normalized_dicom(:,k,2:end)));
    end
    for kx=1:Images.Nx
        for ky=1:Images.Ny
    Reconstruction.PDmap(kx,ky)=Images.norme_dicom(kx,ky)./norm(abs(squeeze(dictionary(Reconstruction.t_exp_dicom(kx,ky),:))));
        end
    end
    affichage_resultats_MRFv3_sansflux;
    plot_data_et_match_MRFv3_sansflux;
end    

clear h filename k




%% Reco avec a priori sur B1 (UNIQUEMENT SI UNE SEULE VITESSE !)
% load('D:\MATLAB\MRF_v3_SliceProfile_flux\Data\2017-01-11\Cartes de référence\allmaps.mat', 'B1relMap')
% Reconstruction=struct;
% 
% Reconstruction.treshholdOnOff='On'; if strcmp(Reconstruction.treshholdOnOff,'On')
%                                         Reconstruction.seuil=0.5;
%                                     end
% for j=1:Images.Nx
%     j
% for k=1:Images.Ny
%     B1tmp=Properties.B1rel(find(abs(Properties.B1rel-B1relMap(j,k))==min(abs(Properties.B1rel-B1relMap(j,k)))));
%     indices=find(Properties.B1rellist(:)==B1tmp);
%         [Reconstruction.innerproduct(j,k),Reconstruction.t_exp_dicom(j,k)]= templatematch_MRFv3(abs(dictionary(indices,(2:end))),squeeze(Images.Image_normalized_dicom(j,k,2:end))');
%         Reconstruction.t_exp_dicom(j,k)=indices(Reconstruction.t_exp_dicom(j,k));
% end
% end
%     for kx=1:Images.Nx
%         for ky=1:Images.Ny
%     Reconstruction.PDmap(kx,ky)=Images.norme_dicom(kx,ky)./norm(abs(squeeze(dictionary(Reconstruction.t_exp_dicom(kx,ky),:))));
%         end
%     end
%     affichage_resultats_MRFv3_sansflux;
%     plot_data_et_match_MRFv3_sansflux;
% 
% 
% clear h filename k j