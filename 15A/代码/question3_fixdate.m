%--------------------------------------------------------------------------
%             question3_fixdate.m
%             固定天数
%--------------------------------------------------------------------------

clc,clear
close all
tic
%% ******************************** 数据准备 *********************************
data1 = xlsread('/Users/shengliyi/Documents/MATLAB/比赛Matlab/15A/代码/data.xlsx',2,'B4:C24');
data2 = xlsread('/Users/shengliyi/Documents/MATLAB/比赛Matlab/15A/代码/data.xlsx',3,'B4:C24');
pole1.x = data1(:,1);
pole1.y = data1(:,2);
pole1.angle = atand(pole1.y ./ pole1.x);
pole1.deltaAngle = abs(diff(pole1.angle));
pole1.length = sqrt(pole1.x.^2 + pole1.y.^2);
pole2.x = data2(:,1);
pole2.y = data2(:,2);
pole2.angle = atand(pole2.y ./ pole2.x);
pole2.deltaAngle = abs(diff(pole2.angle));
pole2.length = sqrt(pole2.x.^2 + pole2.y.^2);

pole = pole2;

n = 21;		% 时间序号
% Pek_t = 4+41/60:0.05:5+41/60;
Pek_t = 5.15:0.05:6.15;
Pek_t = Pek_t';
% n = 295;
targetAngle = 23.45 .* sin(2 * pi * (284 + n) ./ 365);	% 赤纬角

% result = countResult(-180,180,-90,90,1,Pek_t,targetAngle,pole);

INIT.longLeft = 109;
INIT.longRight = 111;
INIT.latLeft = 28;
INIT.latRight = 30;
INIT.stepLength = 0.1;
[minLongtitude,minLatitude,minDelta,minPercent,minAngle] = countDelta(INIT,targetAngle,Pek_t,pole);
toc
plot(minPercent,'o','MarkerSize',8,'LineWidth',2)
axis([0,20,0,0.01])
% axis([0,20,0,0.03])
set(gca,'XTickLabel',{'12:41' '12:47' '12:53' '12:59' '13:05' '13:11' '13:17' '13:23' '13:29' '13:35' '13:41'})
% set(gca,'YTickLabel',{'0','0.5%' '1.0%' '1.5%' '2.0%' '2.5%' '3.0%'})
set(gca,'YTickLabel',{'0','0.1%' '0.2%' '0.3%' '0.4%' '0.5%' '0.6%' '0.7%' '0.8%' '0.9%' '1.0%'})


%% countResult: 计算三个地点的大致坐标
function [result] = countResult(longLeft,longRight,latLeft,latRight,stepLength,Pek_t,targetAngle,pole)
	count = 1;
	for long = longLeft:stepLength:longRight
		for lat = latLeft:stepLength:latRight
			ts = mod(Pek_t + long ./ 15 + 24,24);	% 地方时
			w = 15 .* (ts - 12);			% 时间
			alp = asind(sind(lat) .* sind(targetAngle) + cosd(lat) .* cosd(targetAngle) .* cosd(w));	% 太阳高度角
			B = (sind(targetAngle) - sind(alp) .* sind(lat)) ./ (cosd(alp) .* cosd(lat));
			isNe = w < 0;		% 是否为负数
			A = acosd(B) .* isNe + (360 - acosd(B)) .* ~isNe;
			A_deltaAngle = abs(diff(A));
			delta = sum((A_deltaAngle - pole.deltaAngle).^2);
			result(count,:) = [delta,long,lat];
			count = count + 1;
		end
	end
	[~,index] = sort(result(:,1));
	result = result(index,:);
end


%% countDelta: 地点的精确坐标
function [minLongtitude,minLatitude,minDelta,minPercent,minAngle] = countDelta(INIT,targetAngle,Pek_t,pole)
	longtitude_left = INIT.longLeft;
	longtitude_right = INIT.longRight;
	latitude_left = INIT.latLeft;
	latitude_right = INIT.latRight;
	minDelta = inf;
	for k = 1:2
		stepLength = INIT.stepLength .* 0.1^(k - 1);
		for long = longtitude_left:stepLength:longtitude_right
			for lat = latitude_left:stepLength:latitude_right
				ts = mod(Pek_t + long ./ 15 + 24,24);	% 地方时
				w = 15 .* (ts - 12);			% 时间
				alp = asind(sind(lat) .* sind(targetAngle) + cosd(lat) .* cosd(targetAngle) .* cosd(w));	% 太阳高度角
				B = (sind(targetAngle) - sind(alp) .* sind(lat)) ./ (cosd(alp) .* cosd(lat));
				isNe = w < 0;		% 是否为负数
				A = acosd(B) .* isNe + (360 - acosd(B)) .* ~isNe;
				A_deltaAngle = abs(diff(A));
				delta = sum((A_deltaAngle - pole.deltaAngle).^2);
				
				if delta < minDelta
					minDelta = delta;
					minPercent = abs((A_deltaAngle - pole.deltaAngle) ./ pole.deltaAngle);
					minAngle = A_deltaAngle;
					minLongtitude = long;
					minLatitude = lat;
				end
			end

		end
		longtitude_left = max(minLongtitude - stepLength,-180);
		longtitude_right = min(minLongtitude + stepLength,180);
		latitude_left = max(minLatitude - stepLength,-90);
		latitude_right = min(minLatitude + stepLength,90);
	end
end
