function [varargout]=zrot(phi)
% function Rz=zrot(phi)
% function [Z1,Z2,Z3] = zrot(phi)
%
% Calculate matrix representing a 3D rotation by an angle phi around the
% z-axis. Angles are in units of radians.
% If called with three output arguments, separately returns the lines of
% the matrix in column vectors.
% Outputs are of size 3x3xN (Rz) or 3xN (Zi), where N is the number of
% elements in phi.
%
% based on code from http://www-mrsrl.stanford.edu/~brian/bloch/
%
% copyright Jan Warnking, INSERM U836, Grenoble, France
%

nout = max(nargout,1);

n_phi = numel(phi);

if n_phi > 1,
    if nout>1,
        phi = reshape(phi,[1,n_phi,1]);
    else
        phi = reshape(phi,[1,1,n_phi]);
    end;
end;

c = cos(phi);
s = sin(phi);

switch nout
    case 1,
        O = zeros([1,1,n_phi]);
        l = ones ([1,1,n_phi]);
        varargout(1) = {[c -s O;s c O;O O l]};
    case 2,
        varargout(1) = {[c;-s]};
        varargout(2) = {[s; c]};
    case 3,
        O = zeros([1,n_phi,1]);
        l = ones ([1,n_phi,1]);
        varargout(1) = {[c;-s; O]};
        varargout(2) = {[s; c; O]};
        varargout(3) = {[O; O; l]};
end;