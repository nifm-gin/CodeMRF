function [] = sequenceDisplay(Seq)

figure('Name','MRI Sequence','units','normalized','outerposition',[0 1/2 1/2 1/2])

subplot(2,1,1)
plot(Seq.FA*180/pi);
title('Flip angles')
% xlabel('TR index')
ylabel('Flip angle (deg)')

subplot(2,1,2)
plot(Seq.TR);
hold on
plot(Seq.TE)
title('Repetition times and echo times')
% xlabel('TR index')
ylabel('TR (blue) and TE (red) (ms)')

set(gcf,'color','w')

end