%--------------------------------------------------------------------------
%             question1_12.m  风速 12 m/s 时的各参数
%--------------------------------------------------------------------------

clc,clear
close all
tic
% 将弧度转换为度数
tand = @(x) tan(x * pi / 180);
cosd = @(x) cos(x * pi / 180);
sind = @(x) sin(x * pi / 180);
atand = @(x) atan(x) * 180 / pi;
acosd = @(x) acos(x) * 180 / pi;
asind = @(x) asin(x) * 180 / pi;
sh = @(x) (exp(x) - exp(-x)) ./ 2;
ch = @(x) (exp(x) + exp(-x)) ./ 2; 

%% ******************************** 数据初始化 *********************************
syms cta
syms h

p = 1.025 * 10^3;	% 海水密度
g = 9.8;			% 重力加速度
M = 1000;			% 浮标重量
% v_wind = 36;		% 风速
F_float = 0;		% 浮标浮力
% 锚链属性
chain_dl = 0.105;	% 锚链的每节链环长度
chain_dm = 7 * chain_dl;		% 锚链的每节质量
chain_L = 22.05;	% 锚链总长
chain_num = chain_L ./ chain_dl;	% 锚链个数
% 钢管属性
tube_m = 10;		% 钢管质量
tube_l = 1;			% 钢管长度
tube_d = 0.05;		% 钢管直径
% 钢桶属性
barrel_m = 100;		% 钢桶的质量
barrel_l = 1;		% 钢桶长度
barrel_d = 0.3;		% 钢桶直径
% 重物球属性
sphere_m = 1200;	% 重物球的质量

clear h
load h		% 浸没高度
f = h;

% for v_wind = 24:36
v_wind = 12;

minDelta = inf;
minH = 0;
for cta = 1.84:0.001:1.86
    h = double(subs(f,'cta',cta));
	% h = 0.769888;
	% cta = 0;
	%% ******************************** 数据准备 *********************************
	% V_inWater = p * g * h * pi;	% 浮标浸没体积
	F_float = p * g * pi * h;			% 浮力
	tube_float = p * g * pi * (tube_d / 2)^2 * tube_l;
	barrel_float = p * g * pi * (barrel_d / 2)^2 * barrel_l;
	S_wind = (2 - h) * cosd(cta) * 2 + pi / 2 * sind(cta);	% 风投影面积
	F_wind = 0.625 * S_wind * v_wind^2;		% 风力
	cta0 = atand(F_wind ./ (F_float - M * g));	% 浮标所受拉力的倾斜角度
	T0 = F_wind ./ sind(cta0);				% 浮标所受拉力大小
	
	%% ******************************** 钢管 *********************************
	tube_cta(1) = atand(T0 * sind(cta0) ./ (T0 * cosd(cta0) + tube_float - tube_m * g));
	tube_T(1) = T0 * sind(cta0) / sind(tube_cta(1));
	alp(1) = countAngle(T0,tube_T(1),cta0,tube_cta(1));
	
	for i = 2:4
		tube_cta(i) = atand(tube_T(i-1) * sind(tube_cta(i-1)) ./ (tube_T(i-1) * cosd(tube_cta(i-1)) + tube_float - tube_m * g));
		tube_T(i) = tube_T(i-1) * sind(tube_cta(i-1)) / sind(tube_cta(i));
		alp(i) = countAngle(tube_T(i-1),tube_T(i),tube_cta(i-1),tube_cta(i));
	end
	
	%% ******************************** 钢桶 *********************************
	barrel_cta = atand(tube_T(4) * sind(tube_cta(4)) ./ (tube_T(4) * cosd(tube_cta(4)) + barrel_float - (barrel_m + sphere_m) * g));
	barrel_T = tube_T(4) * sind(tube_cta(4)) / sind(barrel_cta);
	belta = countAngle(tube_T(4),barrel_T,tube_cta(4),barrel_cta,sphere_m * g);
	
	%% ******************************** 锚链 *********************************
	chain_cta(1) = atand(barrel_T * sind(barrel_cta) ./ (barrel_T * cosd(barrel_cta) - chain_dm * g));
	chain_T(1) = barrel_T * sind(barrel_cta) / sind(chain_cta(1));
	gama(1) = countAngle(barrel_T,chain_T(1),barrel_cta,chain_cta(1));
	gama2(1) = gama(1);
	
	for i = 2:chain_num
		chain_cta(i) = atand(chain_T(i-1) * sind(chain_cta(i-1)) ./ (chain_T(i-1) * cosd(chain_cta(i-1)) - chain_dm * g));
		chain_T(i) = chain_T(i-1) * sind(chain_cta(i-1)) / sind(chain_cta(i));
		gama(i) = countAngle(chain_T(i-1),chain_T(i),chain_cta(i-1),chain_cta(i));
	    gama2(i) = gama(i) * (gama(i) > 0) + 90 * (gama(i) < 0);
	end

	h1 = tube_l .* cosd(alp);
	h2 = barrel_l .* cosd(belta);
	h3 = chain_dl .* cosd(gama2);
	h_all = sum(h1) + h2 + sum(h3) + h;

	delta = abs(h_all - 18);
	if delta < minDelta
		minDelta = delta;
		minH = h;
		minCta = cta;
		minGama = gama2;
		minBelta = belta;
		minAlp = alp;
        minFwind = F_wind;
	end
end

a = F_wind ./ (7 * g);
minH
minDelta
minCta

R_all = sum(tube_l .* sind(minAlp)) + barrel_l .* sind(minBelta) + sum(chain_dl .* sind(minGama))

temp_x = 0;
temp_y = 0;
temp_Gama = fliplr(minGama);
point = 90 - temp_Gama;
figure;
hold on;
for i = 1:length(point)
	k = tand(point(i));
	temp_f = @(x) k * (x - temp_x) + temp_y;
	ax1 = fplot(temp_f,[temp_x,temp_x + chain_dl * sind(temp_Gama(i))],'LineWidth',1.5,'Color','r');
	temp_x = temp_x + chain_dl * sind(temp_Gama(i));
	temp_y = temp_y + chain_dl * cosd(temp_Gama(i));
end

a = F_wind ./ (7 * g);
x_left = sum(temp_Gama == 90) * chain_dl;
x_right = temp_x;
f_Xuan = @(x) a * (ch((x - x_left) / a) - 1);
ax2 = fplot(f_Xuan,[x_left,x_right],'--','LineWidth',2,'Color','b')

legend([ax1,ax2],'分段函数','悬链线函数')

hold off;

% end

minAlp = minAlp';
minBelta = minBelta';
minGama = minGama';

toc

%% countAngle: 通过两个矢量立 来计算角度（力矩）
function [a] = countAngle(T0,T1,cta0,cta1,G)
	cosd = @(x) cos(x * pi / 180);
	sind = @(x) sin(x * pi / 180);
	atand = @(x) atan(x) * 180 / pi;
	Fx = T1 * sind(cta1) + T0 * sind(cta0);
	if nargin < 5
		Fy = T1 * cosd(cta1) + T0 * cosd(cta0);
	else
		Fy = T1 * cosd(cta1) + T0 * cosd(cta0) + G;
	end
	a = atand(Fx / Fy);
end