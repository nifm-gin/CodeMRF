function [Images, Reconstruction, dictionary, Properties] = MRFv3_Reconstruction(acqPath, pathToDico, flagCallGUI, lastEcho)
% Performs MRF reconstruction of data from acqPath with dictionary from
% pathToDico, optionnaly calls dataVsMatch GUI
% -------------------------------------------------------------------------
% - acqPath: Path to scan ex: "/home/data/yyyymmdd_scan_/1", this directory
% should contain the method file and pdata/ dir
% - pathToDico: path to directory containing result from dictionary
% generation, should contain dico_*.mat and prop_*.mat files
% - flagCallGUI: optional flag to launch dataVsMatch GUI at the end of
% process, default 1
% - lastEcho: optional, indicates the last echo to consider. Default is to
% use all echoes
%
% - Images: struct containing Image (loaded) data
% - Reconstruction: struct containing data from Reco such as score map and
% index map
% - dictionary: full dictionary used for MRF reconstruction
% - Properties: struct loaded from prop_*.mat file
% -------------------------------------------------------------------------
%%
fprintf('')
fprintf('================================================================\n')
fprintf('Starting reconstruction tool... \n')

if nargin < 2
    error('At least two input arguments needed')
end

if nargin < 4
    lastEcho = 0;
end

if nargin < 3
    flagCallGUI = 1;
end
%% Load images 
% Images=struct;
% Images.nImages=500;
% Images.dossier_visu='/SUMOONE/delphin/Data/20200310_144251_tube_lego_1_1/4/pdata/1';
% Images.dossier_visu = '~/Data/IRM/20200310_144251_tube_lego_1_1/4/pdata/1';
% Images.dossier_visu='/SUMOONE/delphin/Data/20200310_144251_tube_lego_1_1/4/pdata/1';

% acqPath = '~/Data/IRM/20200310_144251_tube_lego_1_1/4';
% acqPath = '~/Data/IRM/20200311_103846_AVC_HP1_R1_1_1/10';
%% Check lastEcho parameter
lastEcho = round(lastEcho);
assert(lastEcho >= 0, 'lastEcho must be positive, can be 0 to consider all echoes');

%% Load Dico
fprintf('Loading dictionary and corresponding parameters... ')
% pathToDico = '/home/aurelien/Installations/CodeMRF/DictionaryCreation/Results/ad1000Calculated_v9_ph0_v2';

pathSplit = split(pathToDico, filesep);
load(fullfile(pathToDico, ['dico_', pathSplit{end}, '.mat']), 'dictionary')
% load([pathToDico, filesep, 'dico_', pathSplit{end}, '.mat'], 'dictionary')
% load([pathToDico, filesep, 'prop_', pathSplit{end}, '.mat'], 'Properties')
load(fullfile(pathToDico, ['prop_', pathSplit{end}, '.mat']), 'Properties')

if lastEcho == 0 %if 0, last echo is relaly the last echo provided
    lastEcho = size(dictionary, 2);
end

dictionary = dictionary(:, 1:lastEcho);
fprintf('Done\n')
%% Read dicom files in order
fprintf('Reading dicom files... ')
Images = dcm2matrix_MRFv3(acqPath, lastEcho);
assert(Images.nImages == size(dictionary,2), sprintf('Signal size differs between data (%i) and dictionary (%i)', Images.nImages, size(dictionary,2))) 
fprintf('Done\n')
%% renormalization
fprintf('Normalizing signals and dictionary... ')
Images = fp_normalization_MRFv3(Images);
dictionary = abs(dictionary);
normDictionary = vecnorm(dictionary, 2, 2); % needed to compute proton density
dictionary = dictionary./ normDictionary;
fprintf('Done\n')

%% Load dico
% load('D:\MATLAB\MRF_v3_SliceProfile_flux\Dictionnaires\sinus_5_lobes_invOnOff_FAaltOnOff\dico_5lobessinus1_v10_4cycles_inv_FApos_prop20170519_fulldf.mat')
% dictionary = D.Dictionary;
% Rescale vlist if experimental SliceThickness different from the dictionary slice thickness (usually 1mm)
% Properties.vlist=Properties.vlist*Images.PVM_SliceThick/Parameters.SliceThickness;


%% Reco without B1 input
fprintf('Matching process... ')
Reconstruction=struct;
Reconstruction.treshholdOnOff='Off';
if strcmp(Reconstruction.treshholdOnOff,'On')
    Reconstruction.seuil=0.5;
end
if isfield(Properties, 'vlist') && length(Properties.vlist)>1
    
    analyse_flux_MRFv3;
    for kx=1:Images.nX
        for ky=1:Images.nY
            Reconstruction.PDmap(kx,ky)=Images.norme_dicom(kx,ky)./norm(abs(squeeze(dico_flux(Reconstruction.t_exp_T1T2dfB1(kx,ky),:,Reconstruction.t_exp_v(kx,ky)))));
        end
    end
    affichage_resultats_MRFv3;
    plot_data_et_match_MRFv3;
else
    
    [Reconstruction.innerproduct, Reconstruction.idxMatch]= mrfMatching(dictionary, Images.Image_normalized_dicom);
    Reconstruction = extractMaps(Reconstruction, Images, Properties, dictionary, normDictionary);
    
    
end
fprintf('Complete\n')
%% Open reco result in dataVsMatch GUI
fprintf('----------------------------------------------------------------\n')
fprintf('Reconstruction complete\n')
if flagCallGUI
    fprintf('Displaying results in GUI\n')
    dataVsMatch(Images, Reconstruction, Properties);
end
fprintf('================================================================\n')



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