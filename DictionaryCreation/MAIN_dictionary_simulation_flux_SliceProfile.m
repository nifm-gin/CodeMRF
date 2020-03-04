fprintf('Starting simulation tool... \n')

toRead = 'testGenSeqProp.txt';

%% INIT
tmpRootDir  = fileparts(mfilename('fullpath'));
idx = strfind(tmpRootDir,'/');
rootDir = tmpRootDir(1:idx(end));

[toDo, PulseProfile, Properties, Sequence, Dico] = readParameters([rootDir, 'DictionaryCreation/dicoSimParameters/', toRead]);

fprintf('  Parameter file loaded \n')

%% PROPERTIES
fprintf('  Properties ... ')
% toDo.genpropertiesYesNo='No';
if toDo.genProperties
    %     niveau = Properties.niveau; %%%%%%%%%%%%%%%%%%%% à changer
    
    %     Properties.vlist = 0;% [-150 -100 -60 -40 -20 -10 -5 0 5 10 20 40 60 100 150]; % mm/s
    [Properties] = genproperties_mrfv3(Properties);
    fprintf('Generated \n')
    if toDo.savePropStruct
        save([rootDir, 'SequencesAndProperties/', Properties.toSave, '_', PulseProfile.PulseShape, '.mat'], 'Properties')
        fprintf('  Properties structure saved \n')
    end
else
    load([rootDir, 'SequencesAndProperties/', Properties.toLoad, '.mat'])
    fprintf('Loaded \n')
end

%% SEQUENCE
fprintf('  Sequence ... ')
% toDo.gensequenceYesNo='Yes';
if toDo.genSequence
    %     Sequence.Npulses = 500;
    %     Sequence.v9_v10 = 'v10'; %v9 = spoiler before Acq, v10 = spoiler after Acq
    %     Sequence.Ncycles = 4; % Dephasing cycles
    %     Sequence.m0 = [0, 0, 1]; % No inversion, [0,0,-1] if inversion
    %
    %     dispFlag = 1; % 1 to plot seq time course
    Sequence = gensequence_mrfv3(Sequence);
    fprintf('Generated \n')
    if toDo.saveSeqStruct
        save([rootDir, 'SequencesAndProperties/', Sequence.toSave, '_', PulseProfile.PulseShape, '.mat'], 'Sequence');
        fprintf('  Sequence structure saved \n')
    end
else
    % Sequence=load('D:\MATLAB\MRF_v3_SliceProfile_flux\Sequences et proprietes du milieu\sequence_2016-08-12_1.mat');
    % Sequence=load('/media/aurelien/QQCHSE/MRF_v3_SliceProfile_flux/Séquences et propriétés du milieu/sequence_2016-08-12_1.mat');
    load([rootDir, 'SequencesAndProperties/', Sequence.toLoad, '.mat']);
    fprintf('Loaded \n')
end

if toDo.dispSeq
    sequenceDisplay(Sequence);
end

%% Calcul du dictionnaire ?
% toDo.dicoYesNo='Yes';

%% Affichage variations ?
% toDo.affvarYesNo='Yes';
% if strcmp(toDo.affvarYesNo,'Yes')
%     VariablesAff=struct;
%     VariablesAff.T1aff=1500;
%     VariablesAff.T2aff=100;
%     VariablesAff.dfaff=0;
%     VariablesAff.vaff=0;
%     VariablesAff.B1relaff=1;
% end
%% Test de robustesse au bruit ?
% toDo.testYesNo='Yes';
% if strcmp(toDo.testYesNo,'Yes')
%     TestRobustnessToNoise=struct;
%     TestRobustnessToNoise.SNR=2;
% end

%% Enregistrement de la séquence et/ou du dictionnaire ?
% toDo.savetxtYesNo='Yes';
%  if strcmp(toDo.savetxtYesNo,'Yes')
%      name=strcat('sequence_14_02_2020_',PulseProfile.PulseShape);
%  end
% ToDo.savematYesNo='No';        if strcmp(ToDo.savemattYesNo,'Yes')
%                                   name_dico=strcat('dico_sequence_2016-07-27_1_',pulseshape); end

%% Propriétés du milieuToDo.savetxtYesNo='Yes';

%% Creation d'une sequence

%% Profil de coupe
% Pulse d'excitation
PulseProfile = loadPulseProfileFAv([rootDir, 'DictionaryCreation/PulseProfiles/PulseDictionaries/', PulseProfile.toLoad], PulseProfile);

% [PulseProfile.Rot, PulseProfile.FAlistdeg, PulseProfile.positions_mm, PulseProfile.SliceThickness_th_mm, PulseProfile.p0, PulseProfile.Nspins, PulseProfile.flow_velocities,PulseProfile.dflist] = ...
%     loadPulseProfileFAv([rootDir, 'DictionaryCreation/PulseProfiles/PulseDictionaries/',PulseProfile.toLoad]);

% PulseProfile = load([rootDir, 'DictionaryCreation/PulseProfiles/PulseDictionaries/',PulseProfile.toLoad]);

% Pulse d'inversion
if Sequence.m0(3)==-1 %%%%%%%%%%%%  /!\ Not Tested %%%%%%%%%%%%%%%%%%%%%%
    
    %InvPulseProfile=load('D:\MATLAB\MRF_v3_SliceProfile_flux\Creation de dictionnaire\Pulse Profiles\Pulse d''inversion\matrice_de_rotation_InvPulse.mat','M0','flow_velocities');
    InvPulseProfile=load([rootDir 'DictionaryCreation/PulseProfiles/InversionPulse/matrice_de_rotation_InvPulse.mat'], 'M0', 'flow_velocities');
    %InvPulseProfile=load("/media/aurelien/QQCHSE/MRF_v3_SliceProfile_flux/Création de dictionnaire/Pulse Profiles/Pulse d'inversion/matrice_de_rotation_InvPulse.mat",'M0','flow_velocities');
end

%% Preparation du dictionnaire
if toDo.prepDico
    if strcmp(Sequence.v9_v10,'v9')
        Parameters = prepdico_v9_gradmom1_mrfv3(Sequence, PulseProfile);
    elseif strcmp(Sequence.v9_v10,'v10')
        Parameters = prepdico_v10_gradmom1_mrfv3(Sequence, PulseProfile);
    end
end


%% Calcul du dictionnaire
if toDo.computeDico
    fprintf('  Generating dictionary ... ')
    clear dico_flux dictionary
    
    if length(Properties.vlist) == 1 % If one flow velocity in vox properties
        saveAsFlux = 0; %Determines the variable to save in the end
        
        % Find values in PulseProfile.flow_velocities that are the closest
        % to Properties.vlist
        %         indicev = find( abs(PulseProfile.flow_velocities(:)-Properties.vlist) == min(abs(PulseProfile.flow_velocities(:)-Properties.vlist)) );
        %         PulseProfile.Rot = PulseProfile.Rot(:,:,:,:,indicev(1),:);
        [ ~, indicev ] = min(abs(PulseProfile.flow_velocities-Properties.vlist));
        PulseProfile.Rot = PulseProfile.Rot(:,:,:,:,indicev,:);
        
        if Sequence.m0(3) == -1
%             indicevinv = find(abs(InvPulseProfile.flow_velocities(:)-Properties.vlist) == min(abs(InvPulseProfile.flow_velocities(:)-Properties.vlist)));
            [ ~, indicevinv ] = min(abs(InvPulseProfile.flow_velocities(:)-Properties.vlist));
            InvPulseProfile.M0=InvPulseProfile.M0(:,:,indicevinv);
%             dictionary = calculdico_1v_gradmom1_mrfvc(Parameters, Properties, PulseProfile, Sequence,InvPulseProfile);
            dictionary = calculdico_1v_gradmom1_mrfv3(Parameters, Properties, PulseProfile, Sequence,InvPulseProfile);
        else
            dictionary = calculdico_1v_gradmom1_mrfv3(Parameters, Properties, PulseProfile, Sequence);
        end
        fprintf('Done \n')
        fprintf('    Saving the dictionary... ')
        save([rootDir, 'Dictionaries/', Dico.saveName], 'dictionary',  '-v7.3')
        fprintf('Done \n')
        clear indicev indicevinv
    else
        saveAsFlux = 1;
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
        fprintf('Done \n')
        fprintf('  Saving the dictionary... ')
        save([rootDir, 'Dictionaries/', Dico.saveName], 'dico_flux','-v7.3')
        fprintf('Done \n')
        
        clear vlist_svg kv indicev Rot_svg
    end
end


%% Affichage des variations du signal avec les différents paramètres
if toDo.dispVar
    if length(Properties.vlist)>1
        affichage_variations_dicoflux_mrfv3;
    else
        affichage_variations_dictionary_mrfv3;
    end
end


%% Test de robustesse au bruit
if toDo.testRobustness
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
if toDo.exportSeqPV6
    fprintf('  Exporting the sequence to a .txt file... ')
    name = strcat(Sequence.toSave,PulseProfile.PulseShape);
    
    if exist(strcat(name,'.mat'),'file')==2
        name=strcat(name,datestr(now,'HH-MM-SS'),pulseshape);
        display(strcat('Le fichier existe deja, le nouveau fichier est renomme en ',name, ' '))
    end
    sequence2txt_mrfv3(rootDir, name, Sequence);
    fprintf('Done \n')
end


%% Display 'Finiii ! :)'
fprintf('----------------Done----------------\n');