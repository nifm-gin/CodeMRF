function  newPulseProfile = loadPulseProfileFAv(toLoad, PulseProfile)
%   LOADPULSEPROFILEFAV Loads pre-generated pulse profile dictionary and
%   orders its content 
%   toLoad = name of the file to load

% load(strcat('D:\MATLAB\MRF_v3_SliceProfile_flux\Cr�ation de dictionnaire\Pulse Profiles\Dictionnaire\dictionary_SliceProfiles_FAv_',num2str(pulseshape),'.mat'))
% load('D:\MATLAB\MRF_v3_SliceProfile_flux\Cr�ation de dictionnaire\Pulse Profiles\Dictionnaire\dico_vnegposx10_deg.mat') ;%
% load('D:\MATLAB\MRF_v3_SliceProfile_flux\Cr�ation de dictionnaire\Pulse Profiles\Dictionnaire\dico_df_10blocscte_aveccorr.mat');% 
% load('/media/aurelien/QQCHSE/MRF_v3_SliceProfile_flux/Création de dictionnaire/Pulse Profiles/Dictionnaire/dico_vnegposx10_tenthdeg.mat');% -----------------------------------------------------------------------------
% load('/media/aurelien/QQCHSE/MRF_v3_SliceProfile_flux/Création de dictionnaire/Pulse Profiles/Dictionnaire/dico_Test_18_12_2019.mat');
% load([rootDir 'DictionaryCreation/PulseProfiles/PulseDictionaries/' toLoad '.mat'])
newPulseProfile = load(toLoad);
newPulseProfile.PulseShape = PulseProfile.PulseShape;
newPulseProfile.toLoad = PulseProfile.toLoad ;
newPulseProfile.Nspins = numel(newPulseProfile.positions_mm); % à inclure directement dedans ?
% Nspins=length(positions_mm);
% 
% 
%  varargout{1}=Rot;
%  varargout{2}=FAlist;
%  varargout{3}=positions_mm;
%  varargout{4}=SliceThickness_th_mm;
%  varargout{5}=p0;
%  varargout{6}=Nspins;
%  varargout{7}=flow_velocities;
% if nargout==8
%     varargout{8}=dflist;
% end

end

