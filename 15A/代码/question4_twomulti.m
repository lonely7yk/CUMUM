%--------------------------------------------------------------------------
%             question4_towmulti.m
%             最小二乘遍历找时间地点
%--------------------------------------------------------------------------

clc,clear,close all 
tic

load question4_hough2

pole.x = x2';
pole.y = y2';
pole.angle = atand(pole.y ./ pole.x);
pole.deltaAngle = abs(diff(pole.angle));
pole.length = 2;
pole.shadowLength = sqrt(pole.x.^2 + pole.y.^2) ./ 240 .* 2;
n = 209;	% 7 月 13 日的时间号

% for n = 1:365
	step_t = 1/60;
	Pek_t = 0.9+1/60:step_t:1+34/60;
	% % Pek_t = 5.15:0.05:6.15;
	Pek_t = Pek_t';
	targetAngle = 23.45 .* sin(2 * pi * (284 + n) ./ 365);	% 赤纬角

	INIT.longLeft = 110;
	INIT.longRight = 114;
	INIT.latLeft = 22;
	INIT.latRight = 24;
	INIT.stepLength = 1;

	[minLongtitude,minLatitude,minDelta,minPercent,minAngle] = countDelta(INIT,targetAngle,Pek_t,pole);

% 	result4(n,:) = [n,minLongtitude,minLatitude,minDelta];
% end

% [~,index] = sort(result4(:,4));
% result4 = result4(index,:);

% result1 = countAngle(Pek_t,targetAngle,pole);
% result2 = countHeight(Pek_t,targetAngle,pole);
result3 = countHeightAndAngle(Pek_t,targetAngle,pole);

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
					delta1 = sum(((A_deltaAngle - pole.deltaAngle) ./ A_deltaAngle).^2);
					Height = pole.length ./ tand(alp);
					delta2 = sum(((Height - pole.shadowLength) ./ Height).^2);
					delta = delta1 + delta2;
				else
					delta = inf;
				end
				
				if delta < minDelta
					minDelta = delta;
					minPercent{1} = abs((A_deltaAngle - pole.deltaAngle) ./ pole.deltaAngle);
					minPercent{2} = abs((Height - pole.shadowLength) ./ Height);
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

%% countAngle: 角度最小二乘
function [result] = countAngle(Pek_t,targetAngle,pole)

	minDelta = inf;
	longLeft = -180;
	longRight = 180;
	latLeft = -90;
	latRight = 90;
	stepLength = 1;
	count = 1;
	for long = longLeft:stepLength:longRight
		for lat = latLeft:stepLength:latRight
			ts = mod(Pek_t + long ./ 15 + 24,24);	% 地方时
			w = 15 .* (ts - 12);			% 时间
			alp = asind(sind(lat) .* sind(targetAngle) + cosd(lat) .* cosd(targetAngle) .* cosd(w));	% 太阳高度角
			if alp <= 0
				result(count,:) = [inf,long,lat];
				count = count + 1;
				continue
			end
	
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

%% countHeight: 影子高度最小二乘
function [result] = countHeight(Pek_t,targetAngle,pole)

	minDelta = inf;
	longLeft = -180;
	longRight = 180;
	latLeft = -90;
	latRight = 90;
	stepLength = 1;
	count = 1;
	for long = longLeft:stepLength:longRight
		for lat = latLeft:stepLength:latRight
			ts = mod(Pek_t + long ./ 15 + 24,24);	% 地方时
			w = 15 .* (ts - 12);			% 时间
			alp = asind(sind(lat) .* sind(targetAngle) + cosd(lat) .* cosd(targetAngle) .* cosd(w));	% 太阳高度角
			if alp <= 0
				result(count,:) = [inf,long,lat];
				count = count + 1;
				continue
			end
			
			Height = pole.length ./ tand(alp);
			shadowHeight = pole.shadowLength;
			delta = sum((Height - shadowHeight).^2);
			result(count,:) = [delta,long,lat];
			count = count + 1;
		end
	end
	[~,index] = sort(result(:,1));
	result = result(index,:);
end

%% countHeightAndAngle: 影子高度和角度最小二乘
function [result] = countHeightAndAngle(Pek_t,targetAngle,pole)

	minDelta = inf;
	longLeft = -180;
	longRight = 180;
	latLeft = -90;
	latRight = 90;
	stepLength = 1;
	count = 1;
	for long = longLeft:stepLength:longRight
		for lat = latLeft:stepLength:latRight
			ts = mod(Pek_t + long ./ 15 + 24,24);	% 地方时
			w = 15 .* (ts - 12);			% 时间
			alp = asind(sind(lat) .* sind(targetAngle) + cosd(lat) .* cosd(targetAngle) .* cosd(w));	% 太阳高度角
			if alp <= 0
				result(count,:) = [inf,long,lat];
				count = count + 1;
				continue
			end
			
			Height = pole.length ./ tand(alp);
			shadowHeight = pole.shadowLength;

			B = (sind(targetAngle) - sind(alp) .* sind(lat)) ./ (cosd(alp) .* cosd(lat));
			isNe = w < 0;		% 是否为负数
			A = acosd(B) .* isNe + (360 - acosd(B)) .* ~isNe;
			A_deltaAngle = abs(diff(A));
			delta1 = sum(((A_deltaAngle - pole.deltaAngle) ./ A_deltaAngle).^2);

			delta2 = sum(((Height - shadowHeight) ./ Height).^2);
			delta = delta1 + delta2;
			result(count,:) = [delta,long,lat];
			count = count + 1;
		end
	end
	[~,index] = sort(result(:,1));
	result = result(index,:);
end