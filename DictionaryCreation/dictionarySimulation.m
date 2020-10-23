function [dictionary, Properties, Sequence, varargout] = dictionarySimulation(input)

fprintf('Starting simulation tool... \n')

%% INIT
tmpRootDir  = fileparts(mfilename('fullpath'));
idx = strfind(tmpRootDir,'/');
rootDir = tmpRootDir(1:idx(end));

if ischar(input)
    [~, ~, inputExt] = fileparts(input);
    switch inputExt 
        case '.txt'
            [toDo, PulseProfile, Properties, Sequence, Dico] = readParameters([rootDir, 'DictionaryCreation/dicoSimParameters/', input]);
        case '.mat'
            load([rootDir, 'DictionaryCreation/dicoSimParameters/', input]); % Will load 'struct_init'
            toDo = struct_init.toDo;
            PulseProfile = struct_init.PulseProfile;
            Properties = struct_init.Properties;
            Sequence = struct_init.Sequence;
            Dico = struct_init.Dico;
    end
elseif isstruct(input)
    toDo = input.toDo;
    PulseProfile = input.PulseProfile;
    Properties = input.Properties;
    Sequence = input.Sequence;
    Dico = input.Dico;
else
    error('Input must be the path to text file containing simulation parameters, or a struct already containing them');
end

if toDo.saveDico
    if exist([rootDir, 'DictionaryCreation/Results/', Dico.saveName], 'dir')
        fprintf('!!!!!! WARNING: Saving repertory exists, confirm choice in GUI !!!!!!\n')
        fig = uifigure;
        sel = uiconfirm(fig,'Saving repertory exists, overwrite?','Saving path conflict', 'Options',{'Overwrite', 'Abort'}, 'Icon','warning', 'CancelOption', 2);
        close(fig);
        if strcmp(sel, 'Abort')
            error('Simulation aborted by user')
        end
    end
    
    assert(mkdir([rootDir, 'DictionaryCreation/Results/', Dico.saveName]))
    if ~isstruct(input)
        copyfile([rootDir, 'DictionaryCreation/dicoSimParameters/', input], [rootDir, 'DictionaryCreation/Results/',Dico.saveName, '/', input]);
        
    else
        
    end
    fprintf('  Parameter file loaded and copied\n')
end

%% PROPERTIES
fprintf('  Properties ... ')
if toDo.genProperties
    
    [Properties] = genproperties_mrfv3(Properties);
    fprintf('Generated \n')
else
    load([rootDir, 'SequencesAndProperties/', Properties.toLoad, '.mat'])
    fprintf('Loaded \n')
end

if toDo.savePropStruct
        %         save([rootDir, 'must have nPulses elementsSequencesAndProperties/', Properties.toSave, '_', PulseProfile.PulseShape, '.mat'], 'Properties')
        save([rootDir, 'DictionaryCreation/Results/', Dico.saveName, '/prop_', Dico.saveName, '.mat'], 'Properties')
        fprintf('  Properties structure saved \n')
end

%% SEQUENCE
fprintf('  Sequence ... ')
if toDo.genSequence
    
    Sequence = genSeq(Sequence);
    fprintf('Generated \n')
else
    load([rootDir, 'SequencesAndProperties/', Sequence.toLoad, '.mat']);
    fprintf('Loaded \n')
end

if toDo.saveSeqStruct
        %         save([rootDir, 'SequencesAndProperties/', Sequence.toSave, '_', PulseProfile.PulseShape, '.mat'], 'Sequence');
        save([rootDir, 'DictionaryCreation/Results/', Dico.saveName, '/seq_', Dico.saveName, '.mat'], 'Sequence')
        fprintf('  Sequence structure saved \n')
end

if toDo.dispSeq
    sequenceDisplay(Sequence);
end


%% Profil de coupe
if isempty(PulseProfile.toLoad)
    fprintf('  No pulse profile to load\n')
else
    PulseProfile = loadPulseProfileFAv([rootDir, 'DictionaryCreation/PulseProfiles/PulseDictionaries/', PulseProfile.toLoad], PulseProfile);
    fprintf('  Pulse profile loaded\n')
end

%% Pulse d'inversion
if Sequence.m0(3)==-1 %%%%%%%%%%%%  /!\ Not Tested %%%%%%%%%%%%%%%%%%%%%%
    InvPulseProfile=load([rootDir 'DictionaryCreation/PulseProfiles/InversionPulse/matrice_de_rotation_InvPulse.mat'], 'M0', 'flow_velocities');
end

%% Preparation du dictionnaire
if toDo.prepDico
    if strcmp(Sequence.spoilType, 'Echo')
        Parameters = prepdico_v9_gradmom1_mrfv3(Sequence, PulseProfile);
    elseif strcmp(Sequence.spoilType, 'FID')
        Parameters = prepdico_v10_gradmom1_mrfv3(Sequence, PulseProfile);
    end
end


%% Calcul du dictionnaire
if toDo.computeDico
    switch Dico.method
        case 'EPG'
            fprintf('  EPG computation... \n')      
            % Call epg overlay function
            [dictionary, tF, ~] = EpgOverlay(Properties, Sequence);            
%             [~, tF, dictionary] = EpgOverlay(Properties, Sequence); % phase demodulated 
            fprintf('  Computation completed in %i s\n', tF)            
            
            % Saving the dictionary if asked to
            if toDo.saveDico
                fprintf('  Saving the dictionary... ')
                save([rootDir, 'DictionaryCreation/Results/', Dico.saveName, '/dico_', Dico.saveName], 'dictionary',  '-v7.3')
            end
            fprintf('Done \n')
            
        case 'Bloch'
            fprintf('  Bloch computation... \n')      
            % Call epg overlay function
            [dictionary, tF] = BlochOverlay(Properties, Sequence);            
            fprintf('  Computation completed in %i s\n', tF)            
            
            % Saving the dictionary if asked to
            if toDo.saveDico
                fprintf('  Saving the dictionary... ')
                save([rootDir, 'DictionaryCreation/Results/', Dico.saveName, '/dico_', Dico.saveName], 'dictionary',  '-v7.3')
            end
            fprintf('Done \n')
            
        otherwise
            
            fprintf("  Generating dictionary with Sandra's method ... ")
            clear dico_flux dictionary
            
            if length(Properties.vlist) == 1 % If one flow velocity in vox properties
                saveAsFlux = 0; %Determines the variable to save in the end
                
                % Find values in PulseProfile.flow_velocities that are the closest
                % to Properties.vlist
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
                % Saving the dictionary if asked to
                if toDo.saveDico
                    fprintf('  Saving the dictionary... ')
                    save([rootDir, 'DictionaryCreation/Results/', Dico.saveName, '/dico_', Dico.saveName], 'dictionary',  '-v7.3')
                end
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
                % Saving the dictionary if asked to
                if toDo.saveDico
                    fprintf('  Saving the dictionary... ')
                    save([rootDir, 'DictionaryCreation/Results/', Dico.saveName, '/dico_', Dico.saveName], 'dico_flux','-v7.3')                    
                end
                fprintf('Done \n')
            end
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
    %     name = strcat(Sequence.toSave,PulseProfile.PulseShape);
    %     name = saveName
    if exist(strcat([Dico.saveName, '_PV6'],'.txt'),'file')==2
        Dico.saveName=strcat(Dico.saveName, datestr(now,'HH-MM-SS'));
        display(strcat('Le fichier existe deja, le nouveau fichier est renomme en ', Dico.saveName, ' '))
    end
    sequence2txt_mrfv3([rootDir, 'DictionaryCreation/Results/', Dico.saveName, '/'], [Dico.saveName, '_PV6'], Sequence);
    fprintf('Done \n')
end

if length(Properties.vlist) == 1
    varargout = {'dictionary'};
else
    varargout = {'dico_flux'};
end


%% Display 'Finiii ! :)'
fprintf('----------------Done----------------\n');
end