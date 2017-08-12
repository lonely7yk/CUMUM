%% savePicture: 保存图片到当前文件路径
function savePicture(titleName,xlabelName,ylabelName)

	path = '/Users/shengliyi/Documents/MATLAB/比赛/04B/question1/picture';

	set(gcf,'position',[0,0,1080,720]);
	set(gca,'FontSize',20);%先修改所有字体大小，包括刻度字体
	title(titleName,'fontsize',36,'fontname','Microsoft YaHei UI');
	xlabel(xlabelName,'fontsize',36,'fontname','Microsoft YaHei UI');
	ylabel(ylabelName,'fontsize',36,'fontname','Microsoft YaHei UI');
	%set(pic,'linewidth',3.5);修改线条粗细
	%set(gca,'xtick',1:21);
	%变成百分制
	%set(gca,'yticklabel',labels_modif);
	%去除白边
	ax = gca;
	outerpos = ax.OuterPosition;
	ti = ax.TightInset;
	left = outerpos(1) + ti(1);
	bottom = outerpos(2) + ti(2);
	ax_width = outerpos(3) - ti(1) - ti(3);
	ax_height = outerpos(4) - ti(2) - ti(4);
	ax.Position = [left bottom ax_width ax_height];
	saveas(gcf,strcat(path,'/',titleName,'.png'));
	saveas(gcf,strcat(path,'/',titleName,'.fig'));
% 	close all
end