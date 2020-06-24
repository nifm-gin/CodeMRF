pathToTR = 'D:\Utilisateur\Bureau\Optim\optimal_TRs_noinv_100it_T1T2rat.txt';
pathToFA = 'D:\Utilisateur\Bureau\Optim\optimal_FAs_noinv_100it_T1T2rat.txt';

TR = importdata(pathToTR);
FA = importdata(pathToFA);
N = numel(TR);
TE = TR/2;

fidPV = fopen('seqOptim_100it_PV6.txt', 'w');
fprintf(fidPV, '%i\n', N);
fprintf(fidPV, '%i\n', 0);
fprintf(fidPV, '%i\n', 2);
for i = 1:N
   fprintf(fidPV, '+%9.6f %9.6f %9.6f\n', FA(i), TR(i), TE(i)) ;
end