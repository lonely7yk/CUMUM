%--------------------------------------------------------------------------
%             question3_net.m
%             通过公式求解
%--------------------------------------------------------------------------

clc,clear,close all 
tic

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

for n = 1:365
	Pek_t = 4+41/60:0.05:5+41/60;
	% Pek_t = 5.15:0.05:6.15;
	Pek_t = Pek_t';
	targetAngle = 23.45 .* sin(2 * pi * (284 + n) ./ 365);	% 赤纬角

	INIT.longLeft = -180;
	INIT.longRight = 180;
	INIT.latLeft = -90;
	INIT.latRight = 90;
	INIT.stepLength = 1;

	[minLongtitude,minLatitude,minDelta,minPercent,minAngle] = countDelta(INIT,targetAngle,Pek_t,pole1);

	result(n,:) = [n,minLongtitude,minLatitude,minDelta];
end

[~,index] = sort(result(:,4));
result = result(index,:);

% INIT.longLeft = -180;
% INIT.longRight = 180;
% INIT.latLeft = -90;
% INIT.latRight = 90;
% INIT.stepLength = 1;
% targetAngle = 23.45 .* sin(2 * pi * (284 + 141) ./ 365);	% 赤纬角
% % Pek_t = 4+41/60:0.05:5+41/60;
% Pek_t = 5.15:0.05:6.15;
% Pek_t = Pek_t';
% [minLongtitude,minLatitude,minDelta,minPercent,minAngle] = countDelta(INIT,targetAngle,Pek_t,pole2);

toc

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
