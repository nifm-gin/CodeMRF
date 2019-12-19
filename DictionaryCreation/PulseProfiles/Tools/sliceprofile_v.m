function [Mxout, Myout, Mzout ] = sliceprofile_v(rf,grad,dT,T1,T2,pos,df,v,Min)
% simulation of Boch equations for RF pulses, including effects of relaxation and flow
% v should be a vector of flow velocities in mm/s
% dT = timestep in s

gamma = 4258;             % 1/(s*gauss)
rfrot = 2*pi*gamma*rf*dT; % Rotation in radians for each discrete RF sample

npos = length(pos);
nsteps = length(rf);
pos = pos(:)'*2*pi*gamma*(1/10)*dT;		% Make 1xN and convert to rad*cm/Gauss
dpos = v*2*pi*gamma*(1/10)*dT*dT;   % Make 1xN and convert to rad*cm/(Gauss*timestep) %v(:)'*2*pi*gamma*(1/10)*dT*dT;

% calculate matrix for relaxation processes during free precession between RF samples
[A,B] = freeprecess(1000*dT/2,T1,T2,df);
B = repmat(B,1,length(pos));

this_pos = pos;           % position spins at the beginning
M = Min;%[z;z;o];    % magnetization (Mx,My,Mz) before RF pulse for each position (1..length(pos))


   for k = 1:nsteps            % loop over gradient and RF samples, treat position in parallel
      % Strictly speaking we should simulate in the following order:
      % [gradient,relaxation],RF,[relaxation,gradient],motion.
      % lets do that. Calculation time is so long that this needs to run overnight anyway.
      Z = zrot((this_pos/2)*grad(k));
      for x = 1:npos
         M(:,x) = Z(:,:,x)*M(:,x); % some phase shift due to gradient (function of pos)
      end;
      M = A*M+B;                    % next some free precession (and relaxation)
      for x = 1:npos
         T = squeeze(throt3(abs(rfrot(k)),angle(rfrot(k))));
         M(:,x) = Z(:,:,x)*T*M(:,x);        % then RF pulse (T) and more phase shift due to gradient (function of pos)
      end;
      M = A*M+B;                    % more free precession (and relaxation)
      this_pos = this_pos+dpos;            % finally: move the flowing spins
   end;

Mxout= M(1,:)';
Myout= M(2,:)';
Mzout= M(3,:)';
end

