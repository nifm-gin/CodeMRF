clear all

PulseProfile.PulseShape = 'Calculated';

% Loads properties such as T1, T2, B1Rel, df and Vlist
load('/home/aurelien/Installations/CodeMRF/SequencesAndProperties/struct_properties_AD_Test.mat');

% Create sequence parameters on 1000 pulses
Sequence.nPulses = 1000;
[FA, TE, TR, m0, Ncycles] = gensequence_mrfv3(Sequence.nPulses);
Sequence.FA = FA;
Sequence.TE = TE;
Sequence.TR = TR;
Sequence.m0 = m0;
Sequence.Ncycles = Ncycles;

% Compute pulse profile
% flow_velocity = 0; 
% [Rot, FAlist, positions_mm, SliceThickness_th_mm, p0] = calculatePulseProfileFAv('Calculated', FA, flow_velocity, Properties.df);


kdf=1;
%[ Rot(:,:,:,:,:,kdf), FAlist, positions_mm, SliceThickness_th_mm, p0 ] = calculatePulseProfileFAv(PulseProfile.PulseShape, Sequence.FA, Properties.vlist, Properties.df(kdf));
% The line above loses the shape of Rot
[ Rot, FAlist, positions_mm, SliceThickness_th_mm, p0 ] = calculatePulseProfileFAv(PulseProfile.PulseShape, Sequence.FA, Properties.vlist, Properties.df(kdf));
for kdf=2:length(Properties.df)
    disp(kdf)
%     tic
    [ Rot(:,:,:,:,:,kdf), FAlist, positions_mm, SliceThickness_th_mm, p0 ] = calculatePulseProfileFAv(PulseProfile.PulseShape, Sequence.FA, Properties.vlist, Properties.df(kdf));
%     toc
end
FA = Sequence.FA;
dflist = Properties.df;
flow_velocities = Properties.vlist;
Nspins = length(positions_mm);

save('/home/aurelien/Installations/CodeMRF/DictionaryCreation/PulseProfiles/PulseDictionaries/dico_Test_07_01_2020.mat', ...
    'Rot', 'FAlist', 'positions_mm', 'SliceThickness_th_mm', 'p0', 'FA', 'dflist', 'flow_velocities')
%%