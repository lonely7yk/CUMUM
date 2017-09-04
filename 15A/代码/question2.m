%--------------------------------------------------------------------------
%             question2.m
%--------------------------------------------------------------------------

clc,clear
close all
tic
%% ******************************** 数据准备 *********************************
global earthA earthB p
earthA = 6378136;		% 地球半径长焦
earthB = 6356755;		% 地球半径短焦
p = 1;			% 折射率

data = xlsread('/Users/shengliyi/Documents/MATLAB/比赛Matlab/15A/代码/data.xlsx',1,'B4:C24');
pole.x = data(:,1);
pole.y = data(:,2);
pole.angle = atand(pole.y ./ pole.x);
pole.deltaAngle = abs(diff(pole.angle));
pole.length = sqrt(pole.x.^2 + pole.y.^2);
timeAfter12 = 2.7:0.05:3.7;		% 超过 12 时的小时数
sunLongtitude = 120 - timeAfter12 ./ 12 .* 180;		% 每个时刻太阳的直射经度
targetAngle = 105.374 - 77.772;	% 太阳经过赤道后又转了多少度
earthA = 6378136;		% 地球半径长焦
earthB = 6356755;		% 地球半径短焦

Pek_t = 6.7:0.05:7.7;
Pek_t = Pek_t';

%% ******************************** 计算太阳直射纬度 *********************************
x = earthA .* cosd(targetAngle);
y = earthA .* cosd(23.5) .* sind(targetAngle);
z = tand(23.5) .* y;
sunLatitude = atand(z ./ sqrt(x.^2 + y.^2));   % 太阳直射纬度

n = length(sunLongtitude);	% 时刻的数目


minDelta = [];
minLongtitude = [];
minLatitude = [];
count = 1;
for i = -180:1:180
	ts = mod(Pek_t + i ./ 15 + 24,24);	% 地方时
	w = 15 .* (ts - 12);
	isNe = w < 0;
	for j = -90:1:90
		temp_highAngle = countAllHighAngle(i * ones(n,1),j * ones(n,1),sunLongtitude',sunLatitude * ones(n,1));	% 太阳高度角
		B = (sind(sunLatitude) - sind(temp_highAngle) .* sind(j)) ./ (cosd(temp_highAngle) .* cosd(j));
		temp_angle = isNe .* acosd(B) + ~isNe .* (360 - acosd(B));
		diff_angle = abs(diff(temp_angle));
		delta = sum((diff_angle - pole.deltaAngle).^2);

		% if delta < minDelta
		% 	minDelta = delta;
		% 	minPercent = abs((diff_angle - pole.deltaAngle) ./ pole.deltaAngle);
		% 	minAngle = diff_angle;
		% 	minLongtitude = i;
		% 	minLatitude = j;
		% end
		result(count,:) = [delta,i,j];
		count = count + 1;
	end
end
[~,index] = sort(result(:,1));
result = result(index,:);

% INIT.longtitude_left = 100;
% INIT.longtitude_right = 160;
% INIT.latitude_left = -10;
% INIT.latitude_right = 30;
% INIT.stepLength = 1;



% for i = 1:100
% 	p = 1 - 0.01 * (i - 1);
% 	[temp_longtitude(i),temp_latitude(i)] = countDelta(INIT,sunLongtitude,sunLatitude,pole);
% end
% [minLongtitude,minLatitude,minDelta,minPercent,maxPercent] = countDelta(INIT,sunLongtitude,sunLatitude,pole);
% figure
% p1 = plot(temp_longtitude)
% figure
% p2 = plot(temp_latitude)

% a = [temp_longtitude',temp_latitude'];
% b = [115.401 -2.249];
% c = pdist2(b,a);
% plot(c)


toc



%% countHighAngle: 计算某一经纬度的太阳高度角度
function [belta] = countHighAngle(poleLongtitude,poleLatitude,sunLongtitude,sunLatitude)
	global earthA earthB p
	x_polar = @(rho,cta,phi) rho .* cosd(cta) .* cosd(phi);
	y_polar = @(rho,cta,phi) rho .* sind(cta) .* cosd(phi);
	z_polar = @(rho,cta,phi) rho .* sind(phi);

	% 正常情况下杆的法向量
	pole_x = x_polar(earthA,poleLongtitude,poleLatitude);
	pole_y = y_polar(earthA,poleLongtitude,poleLatitude);
	pole_z = z_polar(earthB,poleLongtitude,poleLatitude);
	n1 = [pole_x ./ earthA.^2,pole_y ./ earthA.^2,pole_z ./ earthB.^2];	% 杆对应的法向量

	%% 太阳直射点对应的法向量
	sun_x = x_polar(earthA,sunLongtitude,sunLatitude);
	sun_y = y_polar(earthA,sunLongtitude,sunLatitude);
	sun_z = z_polar(earthB,sunLongtitude,sunLatitude);
	n2 = [sun_x ./ earthA.^2,sun_y ./ earthA.^2,sun_z ./ earthB.^2];	% 太阳直射点对应的法向量

	belta = 90 - acosd(p .* abs(n1 * n2') ./ (norm(n1) .* norm(n2)));
end

%% countAllHighAngle: 计算批量角度
function [beltas] = countAllHighAngle(poleLongtitudes,poleLatitudes,sunLongtitudes,sunLatitudes)
	n = size(poleLongtitudes,1);
    beltas = zeros(n,1);
	for i = 1:n
		beltas(i,1) = countHighAngle(poleLongtitudes(i,1),poleLatitudes(i,1),sunLongtitudes(i,1),sunLatitudes(i,1));
	end
end

%% countLengthAndAngle: 计算角度
function [belta] = countAngle(poleLongtitude,poleLatitude,sunLongtitude,sunLatitude)
	global earthA earthB p
	x_polar = @(rho,cta,phi) rho .* cosd(cta) .* cosd(phi);
	y_polar = @(rho,cta,phi) rho .* sind(cta) .* cosd(phi);
	z_polar = @(rho,cta,phi) rho .* sind(phi);

	% 正常情况下杆的法向量
	pole_x = x_polar(earthA,poleLongtitude,poleLatitude);
	pole_y = y_polar(earthA,poleLongtitude,poleLatitude);
	pole_z = z_polar(earthB,poleLongtitude,poleLatitude);
	n1 = [pole_x ./ earthA.^2,pole_y ./ earthA.^2,pole_z ./ earthB.^2];	% 杆对应的法向量

	%% 杆平移到太阳直射经度后的法向量
	pole_x1 = x_polar(earthA,sunLongtitude,poleLatitude);
	pole_y1 = y_polar(earthA,sunLongtitude,poleLatitude);
	pole_z1 = z_polar(earthB,sunLongtitude,poleLatitude);
	n11 = [pole_x1 ./ earthA.^2,pole_y1 ./ earthA.^2,pole_z1 ./ earthB.^2];	% 杆对应的法向量

	%% 杆平移到太阳直射经度后的法向量
	pole_x2 = x_polar(earthA,poleLongtitude,sunLatitude);
	pole_y2 = y_polar(earthA,poleLongtitude,sunLatitude);
	pole_z2 = z_polar(earthB,poleLongtitude,sunLatitude);
	n12 = [pole_x2 ./ earthA.^2,pole_y2 ./ earthA.^2,pole_z2 ./ earthB.^2];	% 杆对应的法向量

	%% 太阳直射点对应的法向量
	sun_x = x_polar(earthA,sunLongtitude,sunLatitude);
	sun_y = y_polar(earthA,sunLongtitude,sunLatitude);
	sun_z = z_polar(earthB,sunLongtitude,sunLatitude);
	n2 = [sun_x ./ earthA.^2,sun_y ./ earthA.^2,sun_z ./ earthB.^2];	% 太阳直射点对应的法向量

	includeAngle1 = acosd(p .* abs(n11 * n2') ./ (norm(n11) .* norm(n2)));
	% includeAngle11 = (p .* cosd(includeAngle1))
	includeAngle2 = acosd(p .* abs(n12 * n2') ./ (norm(n12) .* norm(n2)));
	belta = atand(tand(includeAngle1) ./ tand(includeAngle2));

	% if acosd(n1 * n2' ./ (norm(n1) * norm(n2))) <= 0.001
    if n1 * n2' <= 0
		belta = inf;
	end
end

%% countAllAngle: 计算批量角度
function [beltas] = countAllAngle(poleLongtitudes,poleLatitudes,sunLongtitudes,sunLatitudes)
	n = size(poleLongtitudes,1);
    beltas = zeros(n,1);
	for i = 1:n
		beltas(i,1) = countAngle(poleLongtitudes(i,1),poleLatitudes(i,1),sunLongtitudes(i,1),sunLatitudes(i,1));
	end
end

%% countDelta: 计算误差
function [minLongtitude,minLatitude,minDelta,minPercent,maxPercent] = countDelta(INIT,sunLongtitude,sunLatitude,pole)
	longtitude_left = INIT.longtitude_left;
	longtitude_right = INIT.longtitude_right;
	latitude_left = INIT.latitude_left;
	latitude_right = INIT.latitude_right;
	minDelta = inf;
	n = length(sunLongtitude);
	for k = 1:4
		stepLength = INIT.stepLength .* 0.1^(k - 1);
		for i = longtitude_left:stepLength:longtitude_right
			for j = latitude_left:stepLength:latitude_right
				temp_angle = countAllAngle(i * ones(n,1),j * ones(n,1),sunLongtitude',sunLatitude * ones(n,1));
				diff_angle = abs(diff(temp_angle));
				delta = sum((diff_angle - pole.deltaAngle).^2);
		
				if delta < minDelta
					minDelta = delta;
					minPercent = abs((diff_angle - pole.deltaAngle) ./ pole.deltaAngle);
					minAngle = diff_angle;
					minLongtitude = i;
					minLatitude = j;
				end
			end

		end
		longtitude_left = max(minLongtitude - stepLength,-180);
		longtitude_right = min(minLongtitude + stepLength,180);
		latitude_left = max(minLatitude - stepLength,-90);
		latitude_right = min(minLatitude + stepLength,90);
	end
	maxPercent = max(minPercent);
end
