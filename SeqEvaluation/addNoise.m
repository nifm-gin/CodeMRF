function noisedDictionary = addNoise(dictionary, noiseType, SNR)
% Adds noise to a given simulated dictionary. The noise can either represent aliasing artefacts or thermal noise.
% -------------------------------------------------------------------------
% Input :
% - dictionary    : nEntries * mTimePoints real-valued matrix (mandatory)
% - noiseType     : 'aliasing' or 'thermal' (mandaroty)
% - SNR           : desired SNR for noise generation, default = 4 (optional)
% Output:
% - noisedDictionary  : nEntries * mTimePoints real-valued matrix composed of dictionary + generated noise.
% -------------------------------------------------------------------------

if numel(varargin) < 3
    SNR = 4;
end

switch noiseType
    case 'aliasing'
        noise = random('Normal', 0, sqrt(dictionary / SNR));
        noise = noise ./ vecnorm(noise, 2, 2);
    case 'thermal'
%         noise =
    otherwise
        error('Please specify noise type (either "aliasing" or "thermal"')
end

noisedDictionary = dictionary + noise;

end