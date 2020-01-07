% clear all
%global simu_dico_working_directory
% simu_dico_working_directory = 'C:\Users\warnking\Documents\MATLAB\simulations\fingerprint\Outils';

tmpRootDir  = fileparts(mfilename('fullpath'));
idx = strfind(tmpRootDir,'/');
rootDir = tmpRootDir(1:idx(end));

ToDo=struct;
Sequence=struct;% ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Properties=struct;
PulseProfile=struct;

%% Choix du pulse (profil de coupe)
PulseProfile.PulseShape = 'Calculated'; % 'Calculated', 'sinc3', 'sinc7', 'sinc10'         % Anciennement (à refaire ?) 'Ideal', 'Calculated_2.1ms_1mm', 'sinc3_3.1ms_1mm', 'sinc7_2.8ms_1mm', other (pop up choix de dossier)
PulseProfile.toLoad = 'dico_Test_07_01_2020';

%% Generation de nouvelles propriétés du milieu ? Ou chargement d'un jeu de données existant
ToDo.genpropertiesYesNo='No';    
if strcmp(ToDo.genpropertiesYesNo,'Yes')
    niveau = 4;
    Properties.vlist=[0];%-150 -100 -60 -40 -20 -10 -5 0 5 10 20 40 60 100 150]; % mm/s
end
% Properties=load('D:\MATLAB\MRF_v3_SliceProfile_flux\Séquences et propriétés du milieu\properties_manipflux.mat','B1rel','B1rellist','T1','T1list','T2','T2list','df','dflist','vlist');
%load('D:\MATLAB\MRF_v3_SliceProfile_flux\Dictionnaires\Dico_flux\struct_properties_flux.mat')
% load('/media/aurelien/QQCHSE/MRF_v3_SliceProfile_flux/Dictionnaires/Dico_flux/struct_properties_flux.mat')
load([rootDir 'SequencesAndProperties/struct_properties_AD_Test.mat'])
% Properties.vlist=[0];


%% Création d'une nouvelle séquence ? Ou chargement d'une séquence existante
ToDo.gensequenceYesNo='No';      
if strcmp(ToDo.gensequenceYesNo,'Yes')
    Sequence.Npulses=1800; 
end
% Sequence=load('D:\MATLAB\MRF_v3_SliceProfile_flux\Sequences et proprietes du milieu\sequence_2016-08-12_1.mat');
% Sequence=load('/media/aurelien/QQCHSE/MRF_v3_SliceProfile_flux/Séquences et propriétés du milieu/sequence_2016-08-12_1.mat');
load([rootDir 'SequencesAndProperties/sequence_Test_18_12_2019.mat']);
% Sequence.FA=abs(Sequence.FA);%(2:2:end)=-Sequence.FA(2:2:end);
% Sequence.m0(3)=1;
% Sequence.Ncycles=4;

%% Préparation du dictionnaire ?
ToDo.prepdicoYesNo='Yes';        
if strcmp(ToDo.prepdicoYesNo,'Yes')
    Sequence.v9_v10='v10'; 
end % v9 = spoiler avant l'acq, v10 = spoiler aprés l'acq

%% Calcul du dictionnaire ?
ToDo.dicoYesNo='Yes';


%% Affichage variations ?
ToDo.affvarYesNo='Yes';         
if strcmp(ToDo.affvarYesNo,'Yes')
    VariablesAff=struct;
    VariablesAff.T1aff=1500;      
    VariablesAff.T2aff=100;
    VariablesAff.dfaff=0;         
    VariablesAff.vaff=0;
    VariablesAff.B1relaff=1; 
end
%% Test de robustesse au bruit ?
ToDo.testYesNo='Yes';           
if strcmp(ToDo.testYesNo,'Yes')
    TestRobustnessToNoise=struct;
    TestRobustnessToNoise.SNR=2; 
end

%% Enregistrement de la séquence et/ou du dictionnaire ?
ToDo.savetxtYesNo='Yes';        
if strcmp(ToDo.savetxtYesNo,'Yes')
    name=strcat('sequence_Test_07_01_2020_',PulseProfile.PulseShape); 
end
% ToDo.savematYesNo='No';        if strcmp(ToDo.savemattYesNo,'Yes')
%                                   name_dico=strcat('dico_sequence_2016-07-27_1_',pulseshape); end
%%





%% Propriétés du milieu
if strcmp(ToDo.genpropertiesYesNo,'Yes')
    [Properties.T1list, Properties.T1, Properties.T2list, Properties.T2, Properties.B1rellist, Properties.B1rel, Properties.dflist, Properties.df] = genproperties_mrfv3(niveau);
    clear niveau
end

%% Creation d'une sequence
if strcmp(ToDo.gensequenceYesNo,'Yes')
    [Sequence.FA, Sequence.TE, Sequence.TR, Sequence.m0, Sequence.Ncycles] = gensequence_mrfv3(Sequence.Npulses);
    pause(0.5);
end

%% Profil de coupe
% Pulse d'excitation
[PulseProfile.Rot, PulseProfile.FAlistdeg, PulseProfile.positions_mm, PulseProfile.SliceThickness_th_mm, PulseProfile.p0, PulseProfile.Nspins, PulseProfile.flow_velocities,PulseProfile.dflist] = ...
    loadPulseProfileFAv(rootDir, PulseProfile.toLoad);
% Pulse d'inversion
if Sequence.m0(3)==-1
    %InvPulseProfile=load('D:\MATLAB\MRF_v3_SliceProfile_flux\Creation de dictionnaire\Pulse Profiles\Pulse d''inversion\matrice_de_rotation_InvPulse.mat','M0','flow_velocities');
    InvPulseProfile=load([rootDir 'DictionaryCreation/PulseProfiles/InversionPulse/matrice_de_rotation_InvPulse.mat'], 'M0', 'flow_velocities');
    %InvPulseProfile=load("/media/aurelien/QQCHSE/MRF_v3_SliceProfile_flux/Création de dictionnaire/Pulse Profiles/Pulse d'inversion/matrice_de_rotation_InvPulse.mat",'M0','flow_velocities');
end

%% Preparation du dictionnaire
if strcmp(ToDo.prepdicoYesNo,'Yes')
    if strcmp(Sequence.v9_v10,'v9')
        Parameters = prepdico_v9_gradmom1_mrfv3(Sequence, PulseProfile);
    elseif strcmp(Sequence.v9_v10,'v10')
        Parameters = prepdico_v10_gradmom1_mrfv3(Sequence, PulseProfile);
    end
end


%% Calcul du dictionnaire
if strcmp(ToDo.dicoYesNo,'Yes')
    clear dico_flux dictionary
    
    if length(Properties.vlist)==1
        indicev=find(abs(PulseProfile.flow_velocities(:)-Properties.vlist)==min(abs(PulseProfile.flow_velocities(:)-Properties.vlist)));
        PulseProfile.Rot=PulseProfile.Rot(:,:,:,:,indicev(1),:);
        if Sequence.m0(3)==-1
            indicevinv=find(abs(InvPulseProfile.flow_velocities(:)-Properties.vlist)==min(abs(InvPulseProfile.flow_velocities(:)-Properties.vlist)));
            InvPulseProfile.M0=InvPulseProfile.M0(:,:,indicevinv);
            dictionary = calculdico_1v_gradmom1_mrfvc(Parameters, Properties,PulseProfile, Sequence,InvPulseProfile);
        else
            dictionary = calculdico_1v_gradmom1_mrfv3(Parameters, Properties,PulseProfile, Sequence);
        end
        clear indicev indicevinv
    else
        vlist_svg=Properties.vlist;
        Rot_svg=PulseProfile.Rot;
        if Sequence.m0(3)==-1
            M0_svg=InvPulseProfile.M0;
        end
        for kv=1:length(vlist_svg)
            disp(strcat('debut du n',num2str(kv),' sur ',num2str(length(vlist_svg))))
            Properties.vlist=vlist_svg(kv);
            indicev=find(abs(PulseProfile.flow_velocities(:)-Properties.vlist)==min(abs(PulseProfile.flow_velocities(:)-Properties.vlist)));
            PulseProfile.Rot=Rot_svg(:,:,:,:,indicev(1),:);
            if Sequence.m0(3)==-1
                indicevinv=find(abs(InvPulseProfile.flow_velocities(:)-Properties.vlist)==min(abs(InvPulseProfile.flow_velocities(:)-Properties.vlist)));
                InvPulseProfile.M0=M0_svg(:,:,indicevinv);
                dico_flux(:,:,kv) = calculdico_1v_gradmom1_mrfv3(Parameters, Properties,PulseProfile, Sequence,InvPulseProfile);
            else
                dico_flux(:,:,kv) = calculdico_1v_gradmom1_mrfv3(Parameters, Properties,PulseProfile, Sequence);
            end
        end
        Properties.vlist=vlist_svg;
        clear vlist_svg kv indicev Rot_svg
    end
end


%% Affichage des variations du signal avec les différents paramètres
if strcmp(ToDo.affvarYesNo,'Yes')
    if length(Properties.vlist)>1
        affichage_variations_dicoflux_mrfv3;
    else
        affichage_variations_dictionary_mrfv3;
    end
end


%% Test de robustesse au bruit
if strcmp(ToDo.testYesNo,'Yes')
    if length(Properties.vlist)==1
        Robustness=testrobustness_mrfv3(TestRobustnessToNoise.SNR,dictionary,Properties.T1list,Properties.T2list,Properties.dflist,Properties.vlist,Properties.B1rellist,Parameters,50);
    else
        Robustness=testrobustness_mrfv3(TestRobustnessToNoise.SNR,dico_flux,Properties.T1list,Properties.T2list,Properties.dflist,Properties.vlist,Properties.B1rellist,Parameters,50);
    end
    disp(['Mean relative error on T1 : ', num2str(0.1*round(Robustness.ErrorT1_rel*1000)), ' %'])
    disp(['Mean relative error on T2 : ', num2str(0.1*round(Robustness.ErrorT2_rel*1000)), ' %'])
    disp(['Mean relative error on B1 : ', num2str(0.1*round(Robustness.ErrorB1_rel*1000)), ' %'])
    disp(['Mean relative error on PD : ', num2str(0.1*round(Robustness.ErrorPD_rel*1000)),' %'])
    disp(['Mean absolute error on df : ', num2str(Robustness.Errordf_abs), ' Hz'])
    if length(Properties.vlist)==1
        disp(['Mean absolute error on v : ', num2str(Robustness.Errorv_abs), ' mm/s'])
    end
    
end


%% Enregistrement du dictionnaire et de la sequence en .txt
if strcmp(ToDo.savetxtYesNo,'Yes')
    fprintf('Saving the dictionary and exporting the sequence to a .txt file...\n')
    if exist(strcat(name,'.mat'),'file')==2
        name=strcat(name,datestr(now,'HH-MM-SS'),pulseshape);
        display(strcat('Le fichier existe deja, le nouveau fichier est renomme en ',name))
    end
    sequence2txt_mrfv3(rootDir, name, Sequence);
    fprintf('Done\n')
end

% if strcmp(ToDo.savematYesNo,'Yes')
%     save(name_dico,'-v7.3')
% end

%clear ToDo

%% Display 'Finiii ! :)'
disp(sprintf('\n\n\n                 Finiii ! :) '));
clear simu_dico_working_directory