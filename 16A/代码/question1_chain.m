clc,clear
close all
tic
% 将弧度转换为度数
tand = @(x) tan(x * pi / 180);
cosd = @(x) cos(x * pi / 180);
sind = @(x) sin(x * pi / 180);
secd = @(x) sec(x * pi / 180);
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

% alp = zeros(4,1);	% 钢管倾斜角
% belta = 0;			% 钢桶倾斜角
% gama = zeros(int16(chain_num),1); % 锚链倾斜角
% tube_cta = alp;		% 钢管受力（下）倾斜角
% tube_T = alp;
% barrel_cta = belta; % 钢桶受力（下）倾斜角
% barrel_T = belta;
% chain_cta = gama;	% 锚链受力（下）倾斜角
% chain_T = gama;

%% ******************************** 计算 h 和 cta 的关系 *********************************
% f = (1/h + 1/2) ./ (p * g * pi * h - M * g) * 0.625 * ((2 - h) * cosd(cta) * 2 + pi / 2 * sind(cta)) * v_wind.^2 - tand(cta);
% f = solve(f,h);
clear h
% h = f(1);   % 关于 cta 的sym，h 为浸没高度
load h		% 浸没高度
f = h;
syms h

% for v_wind = 24:36
v_wind = 12;

minDelta = inf;
minH = 0;
% for cta = 1.84:0.001:1.86
    % h = double(subs(f,'cta',cta));
% 	h = 0.7;
	cta = 0;
	%% ******************************** 数据准备 *********************************
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
	
	%% ******************************** 锚链（悬链线1） *********************************
% 	a = F_wind / 7;
% 	syms x
% 	alpha_up = 0;
% 	y = a * ch(x / a + log(tand(alpha_up) + secd(alpha_up))) - a * secd(alpha_up);
% 	L = a * sh(x / a + log(tand(alpha_up) + secd(alpha_up))) - a * secd(alpha_up);
% 	% x0 = solve(L-22.05,x);
% 	dy = diff(y,x);
% 	x0 = solve(dy - tand(90 - barrel_cta),x);
% 	x0 = real(abs(x0(2)));
% %     h3 = subs(y,'x',x0);
% 	h3 = double(subs(y,'x',x0));

	%% ******************************** 悬链线2 *********************************
% 	a = F_wind / 7;
% 	syms x alpha_up
% 	y = a * ch(x / a + log(tand(alpha_up) + secd(alpha_up))) - a * secd(alpha_up);
% 	L = a * sh(x / a + log(tand(alpha_up) + secd(alpha_up))) - a * secd(alpha_up);
% 	dy = diff(y,x);
% 	x0 = solve(dy - tand(90 - barrel_cta),x);
% 	x0 = real(abs(x0(2)));
%     L = subs(L,'x',x0);
% 	alpha_up0 = solve(L - 22.05,alpha_up);
%     alpha_up0 = real(abs(alpha_up0(1)));
% 	x0 = subs(x0,'alpha_up',alpha_up0);
% %     h31 = subs(y,'x',x0);
% %     h32 = subs(h31,'alpha_up',alpha_up0);
% 	h3 = double(subs(y,{'x','alpha_up'},{x0,alpha_up0}));


	
% 	h1 = tube_l .* cosd(alp);
% 	h2 = barrel_l .* cosd(belta);
% 	% h3 = chain_dl .* cosd(gama2);
% 	h_all = sum(h1) + h2 + sum(h3) + h
%     solve(h_all-18)
    
	% delta = abs(h_all - 18);
	% if delta < minDelta
	% 	minDelta = delta;
	% 	minH = h;
	% 	minCta = cta;
	% 	minGama = gama2;
	% 	minBelta = belta;
	% 	minAlp = alp;
	% end
% end

%% ******************************** 悬链线方程 *********************************
% a = F_wind / 7;
% syms x alpha
% y = a * ch(x / a + log(tand(alpha) + secd(alpha))) - a * secd(alpha);
% L = a * sh(x / a + log(tand(alpha) + secd(alpha))) - a * secd(alpha));
% x0 = solve(L-22.05,x);
% dy = diff(y,x);
% dy0 = subs(dy,x,x0);

% minH
% minDelta
% minCta

% R_all = sum(tube_l .* sind(minAlp)) + barrel_l .* sind(minBelta) + sum(chain_dl .* sind(minGama))


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