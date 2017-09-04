%--------------------------------------------------------------------------
%             question1_sum.m
%             以太阳为坐标系，找到地球转过的角度
%--------------------------------------------------------------------------
clc,clear
close all
tic

tand = @(x) tan(x * pi / 180);
cosd = @(x) cos(x * pi / 180);
sind = @(x) sin(x * pi / 180);
atand = @(x) atan(x) * 180 / pi;
acosd = @(x) acos(x) * 180 / pi;
% asind = @(x) asin(x) * 180 / pi;

%% ******************************** 数据初始化 *********************************
a = 149600000 * 10^3;
b = 149580000 * 10^3;   
springAngle = 77.772;

%% ******************************** r 和 cta 的关系式 *********************************
syms r cta
% r 是太阳到轨道的半径
% cta 是太阳到轨道的光线与 x 轴的夹角
r_cta = ((-r * cosd(cta) - sqrt(a.^2 - b.^2)) ./ a).^2 + (r .* sind(cta) ./ b).^2 - 1; % r 和 cta 的关系式
r = solve(r_cta,r);
r = r(1);
r_num = @(cta) double(subs(r,'cta',cta));

%% ******************************** 对时间微分的计算 *********************************
x = -r .* cosd(cta);		% x 极坐标
y = r .* sind(cta);			% y 极坐标
dx = diff(x);				% x 导数
dy = diff(y);				% y 导数
kk = dy ./ dx;				% 切点对应的斜率
alp = abs(cta + atand(kk));	% 矢径与速度方向的夹角
alp_num = @(cta) double(subs(alp,'cta',cta));
Y = @(theta) (r_num(theta).^2);			
k = integral(Y,0,360) ./ (365);		% 常数（不是开普勒常数）
dt = @(cta) r_num(cta).^2 ./ k;		% 时间的微分
func = @(a,b) integral(dt,a,b);


[springAngle,minDelta1] = StepTraverse(70,90,77,func);	% 计算春分对应的角度
[targetAngle1,minDelta2] = StepTraverse(280,310,292,func);	% 计算 10 月 22 号对应的角度
[targetAngle11,minDelta5] = StepTraverse(270,295,282,func);	% 计算 10 月 22 号对应的角度
[targetAngle12,minDelta6] = StepTraverse(290,315,302,func);	% 计算 10 月 22 号对应的角度
[summerAngle,minDelta3] = StepTraverse(160,180,169,func);
[targetAngle2,minDelta4] = StepTraverse(90,110,105,func);			% 计算 4 月 18 号对应的角度

% for i = 1:179		% 计算每一度矢径和速度的夹角
% 	belta = alp_num(i);
% end

% for i = 1:4
% 	step_length = 0.1^(i-1);
% 	for j = cta_left:step_length:cta_right
% 		curDays = integral(dt,0,j);		% j 角度对应的天数
% 		curDelta = abs(curDays - 77);		% 天数的差距

% 		if curDelta < minDelta
% 			minDelta = curDelta;
% 			minAngle = j;
% 			cta_left = j - step_length;
% 			cta_right = j + step_length;
% 		end
% 	end
% end

toc

%% StepTraverse: 逐步遍历（找差距最小值）
function [minTarget,minDelta] = StepTraverse(left,right,best,func)
	% input
	% left : 初始左边界
	% right : 初始右边界
	% best : 最优解
	% func : 函数句柄（需要补充）
	% output
	% minTarget : best 对应的自变量
	% minDelta : 与最优解的误差

	minDelta = inf;
	for i = 1:4
		step_length = 0.1^(i-1);
		for j = left:step_length:right
			curDays = func(0,j);		% 这里需要补充		
			curDelta = abs(curDays - best);		% 当前的差距
	
			if curDelta < minDelta
				minDelta = curDelta;
				minTarget = j;
				left = j - step_length;
				right = j + step_length;
			end
		end
	end
	if minDelta > 0.1		% 如果误差过大抛出异常
		error('误差过大\n');
	end
end
