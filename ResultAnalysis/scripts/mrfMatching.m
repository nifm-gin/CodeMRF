function [score,idxMatch] = mrfMatching(dict,sig)
% Function for MRF matching by dot-product
% -------------------------------------------------------------------------
% - sig: acquired signals, shaped as [X, Y, Z, time], already normalized
% - dict: dictionary shapes as [nEntries, time], already normalized
%
% - score: best dot-product in each space point [X, Y, Z]
% - idxMatch: index of dico entry corresponding to score, [X, Y, Z]
% -------------------------------------------------------------------------

if nargin<2 
    disp('Error - 2 inputs are required!'); 
    return 
end

S = size(sig);
spaceDimProd = prod(S(1:end-1));
score      = nan(spaceDimProd, S(end));
idxMatch    = nan(spaceDimProd, S(end));

% reshape sig to be [spaceDimProd, nPulses]
% dot product with dico
[score,idxMatch] = max(reshape(sig, spaceDimProd, S(end)) * dict', [], 2) ;

score = reshape(score, S(1:end-1));
idxMatch = reshape(idxMatch, S(1:end-1));

end