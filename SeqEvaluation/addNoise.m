function noisedDictionary = addNoise(dictionary, noiseType, SNR)
% Adds noise to a given simulated dictionary. The noise can either represent aliasing artefacts or thermal noise.
% -------------------------------------------------------------------------
% Input :
% - dictionary    : nEntries * mTimePoints real-valued matrix. Mandatory
% - noiseType     : 'aliasing' or 'thermal'. Mandatory
% - SNR           : desired Signal-to-Noise Ratio for noise generation, computed as SNR = mean(signal)/sigma,
%                   where sigma is the noise standard deviation. Optional,
%                   default = 4
% Output:
% - noisedDictionary  : nEntries * mTimePoints real-valued matrix composed of dictionary + generated noise.
% -------------------------------------------------------------------------

if nargin < 3
    SNR = 4;
end

switch noiseType
    case 'aliasing'
        % Noise generation
        noiseRealPart = random('Normal', 0, sqrt(abs(dictionary).^2 / SNR));
        if ~isreal(dictionary)
            noiseImagPart = random('Normal', 0, sqrt(abs(dictionary).^2 / SNR));
        else
            noiseImagPart = zeros(size(dictionary));
        end
        
        % Noise addition
        noisedDictionary = dictionary + noiseRealPart + 1i*noiseImagPart;

    case 'thermal'
        noiseRealPart = randn(size(dictionary)) .* ( mean(abs(dictionary), 'all')/ SNR );
        if ~isreal(dictionary)
            noiseImagPart = randn(size(dictionary)) .* ( mean(abs(dictionary), 'all')/ SNR );
        else
            noiseImagPart = zeros(size(dictionary));
        end
        
        % Noise addition
        noisedDictionary = dictionary + noiseRealPart + 1i*noiseImagPart;
    otherwise
        error('Please specify noise type (either "aliasing" or "thermal"')
end

end