%--------------------------------------------------------------------------
%             question1_earth.m
% 以地球为坐标系，找到 10 月 22 太阳直射点对应的纬度，并通过该点法平面和给定地点法平面，确定太阳高度角
%--------------------------------------------------------------------------

clc,clear
close all
tic

%% ******************************** 数据准备 *********************************
% targetAngle = 286.207 - 77.772;		% 太阳经过赤道后又转了多少度
% targetAngle = 276.277 - 77.772;
targetAngle = 296.191 - 77.772;

% targetAngle = 167.108 - 77.772;	% 夏天的度数
earthA = 6378136;		% 地球半径长焦
earthB = 6356755;		% 地球半径短焦

PekLatitude = 39.91;	% 北京的纬度
% PekLatitude = 39.91 * 0.95;
% PekLatitude = 39.91 * 1.05;

PekLongtitude = 116.39;	% 北京的经度
% PekLongtitude = 116.39 * 0.95;
% PekLongtitude = 116.39 * 1.05;

sun_startLongtitude = 161.39 - 3.61;	% 9 点太阳直射的经度
sun_endLongtitude = 71.39 - 3.61;		% 15 点太阳直射的经度
sun_stepLongtitude = (sun_startLongtitude - sun_endLongtitude) ./ 360;	% 画 360 个高度，每步的步长

%% ******************************** 计算太阳直射纬度 *********************************
x = earthA .* cosd(targetAngle);
y = earthA .* cosd(23.5) .* sind(targetAngle);
z = tand(23.5) .* y;
sunLatitude = atand(z ./ sqrt(x.^2 + y.^2));   % 太阳直射纬度

%% ******************************** 极坐标 *********************************
x_polar = @(rho,cta,phi) rho .* cosd(cta) .* cosd(phi);
y_polar = @(rho,cta,phi) rho .* sind(cta) .* cosd(phi);
z_polar = @(rho,cta,phi) rho .* sind(phi);

Pek_x = x_polar(earthA,PekLongtitude,PekLatitude);
Pek_y = y_polar(earthA,PekLongtitude,PekLatitude);
Pek_z = z_polar(earthB,PekLongtitude,PekLatitude);

n1 = [Pek_x ./ earthA.^2,Pek_y ./ earthA.^2,Pek_z ./ earthB.^2];	% 北京对应的法向量

%% ******************************** 计算 361 个时刻的影子长度 *********************************
for i = 1:361
	sun_curLongtitude = (i - 1) .* sun_stepLongtitude + sun_endLongtitude;
	sunLongtitude(i) = sun_curLongtitude;
	sun_x = x_polar(earthA,sun_curLongtitude,sunLatitude);
	sun_y = y_polar(earthA,sun_curLongtitude,sunLatitude);
	sun_z = z_polar(earthB,sun_curLongtitude,sunLatitude);
	n2 = [sun_x ./ earthA.^2,sun_y ./ earthA.^2,sun_z ./ earthB.^2];	% 太阳直射点对应的法向量
	includeAngle = acosd(abs(n1 * n2') ./ (norm(n1) .* norm(n2)));
	sunHighAngle(i) = 90 - includeAngle;
	shadowLength(i) = 3 ./ tand(sunHighAngle(i));
	
end

[miny,minx] = min(shadowLength);
hold on
p = plot(shadowLength,'LineWidth',3);
plot(minx,miny,'o','MarkerSize',8,'LineWidth',2);
text(minx-20,miny+0.2,strcat(['（12:14, ',num2str(miny),'）']),'Color','r','FontSize',20)
set(gca,'XTick',0:60:360)
set(gca,'XTickLabel',{'9:00','10:00','11:00','12:00','13:00','14:00','15:00'})
hold off

sunLongtitude = fliplr(sunLongtitude)';
sunHighAngle = sunHighAngle';
shadowLength = shadowLength';

toc