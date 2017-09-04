%--------------------------------------------------------------------------
%             question1_net.m
%             通过公式求解
%--------------------------------------------------------------------------

clc,clear
% close all
tic

n = 295;	% 10 月 22 距离 1 月 1 日的天数
n = 285;
n = 305;

Pek.Long = 116.39;
% Pek.Long = 116.39 * 0.95;
% Pek.Long = 116.39 * 1.05;

Pek.Lat = 39.91;
% Pek.Lat = 39.91 * 0.95;
% Pek.Lat = 39.91 * 1.05;


Pole.Length = 3;
fts = @(t) mod((t - (120 - Pek.Long) ./ 180 * 12 + 24),24);

delta = 23.45 .* sin(2 * pi * (284 + n) ./ 365);	% 赤纬角

count = 1;
for t = linspace(9,15,361)
	ts = fts(t);		% 地方时
	w = 15 * (ts - 12);	% 时角
	alp(count) = asind(sind(Pek.Lat) .* sind(delta) + cosd(Pek.Lat) .* cosd(delta) .* cosd(w));	% 高度角
	count = count + 1;
end

shadowLength = Pole.Length ./ tand(alp);
[miny,minx] = min(shadowLength);
alp = alp';
shadowLength = shadowLength';

hold on
p = plot(shadowLength,'LineWidth',3);
% plot(minx,miny,'o','MarkerSize',8,'LineWidth',2);
% text(minx-20,miny+0.2,'(12:14, 3.84)','Color','r','FontSize',18)
% set(gca,'XTick',0:60:360)
% set(gca,'XTickLabel',{'9:00','10:00','11:00','12:00','13:00','14:00','15:00'})
hold off