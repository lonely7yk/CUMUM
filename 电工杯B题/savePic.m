function m_savePicture(titleName,xlabelName,ylabelName)
title(titleName,'fontname','Microsoft YaHei UI');
xlabel(xlabelName,'fontname','Microsoft YaHei UI');
ylabel(ylabelName,'fontname','Microsoft YaHei UI');
%保存
path=['/Users/shengliyi/Documents/MATLAB/比赛/电工杯B题'];
saveas(gcf,strcat(path,'\',titleName,'.png'));