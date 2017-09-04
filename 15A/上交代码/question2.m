%--------------------------------------------------------------------------
%             question2_net.m
%             使用公式求解
%--------------------------------------------------------------------------

clc,clear
close all
tic
%% ******************************** 数据准备 *********************************
data = xlsread('/Users/shengliyi/Documents/MATLAB/比赛Matlab/15A/代码/data.xlsx',1,'B4:C24');
pole.x = data(:,1);
pole.y = data(:,2);
pole.angle = atand(pole.y ./ pole.x);
pole.deltaAngle = abs(diff(pole.angle));
pole.length = sqrt(pole.x.^2 + pole.y.^2);

n = 108;		% 时间序号
Pek_t = 6.7:0.05:7.7;
Pek_t = Pek_t';
% n = 295;
targetAngle = 23.45 .* sin(2 * pi * (284 + n) ./ 365);	% 赤纬角



INIT.longLeft = -180;
INIT.longRight = 180;
INIT.latLeft = -90;
INIT.latRight = 90;
INIT.stepLength = 1;
[minLongtitude,minLatitude,minDelta,minPercent,minAngle] = countDelta(INIT,targetAngle,Pek_t,pole);
toc
plot(minPercent,'o','MarkerSize',8,'LineWidth',2)
% axis([0,20,0,0.01])
axis([0,20,0,0.03])
set(gca,'XTickLabel',{'14:42','14:48','14:54','15:00','15:06','15:12','15:18','15:24','15:30','15:36','15:42'})
set(gca,'YTickLabel',{'0','0.5%' '1.0%' '1.5%' '2.0%' '2.5%' '3.0%'})
% set(gca,'YTick',0:0.1:1)
% set(gca,'YTickLabel',{'0','0.1%' '0.2%' '0.3%' '0.4%' '0.5%' '0.6%' '0.7%' '0.8%' '0.9%' '1.0%'})

% minDelta = inf;
% longLeft = -180;
% longRight = 180;
% latLeft = -90;
% latRight = 90;
% stepLength = 1;
% count = 1;
% for long = longLeft:stepLength:longRight
% 	for lat = latLeft:stepLength:latRight
% 		ts = mod(Pek_t + long ./ 15 + 24,24);	% 地方时
% 		w = 15 .* (ts - 12);			% 时间
% 		alp = asind(sind(lat) .* sind(targetAngle) + cosd(lat) .* cosd(targetAngle) .* cosd(w));	% 太阳高度角
% 		if alp <= 0
% 			result(count,:) = [inf,long,lat];
% 			count = count + 1;
% 			continue
% 		end

% 		B = (sind(targetAngle) - sind(alp) .* sind(lat)) ./ (cosd(alp) .* cosd(lat));
% 		isNe = w < 0;		% 是否为负数
% 		A = acosd(B) .* isNe + (360 - acosd(B)) .* ~isNe;
% 		A_deltaAngle = abs(diff(A));
% 		delta = sum((A_deltaAngle - pole.deltaAngle).^2);
% 		result(count,:) = [delta,long,lat];
% 		count = count + 1;
% 	end
% end
% [~,index] = sort(result(:,1));
% result = result(index,:);

%% countDelta: function description
function [minLongtitude,minLatitude,minDelta,minPercent,minAngle] = countDelta(INIT,targetAngle,Pek_t,pole)
	longtitude_left = INIT.longLeft;
	longtitude_right = INIT.longRight;
	latitude_left = INIT.latLeft;
	latitude_right = INIT.latRight;
	minDelta = inf;
	for k = 1:3
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
				if alp > 0
					delta = sum((A_deltaAngle - pole.deltaAngle).^2);
				else
					delta = inf;
				end
				
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
