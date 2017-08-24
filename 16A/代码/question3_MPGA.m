%--------------------------------------------------------------------------
%             用遗传算法来解问题三
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
% 锚链的种类
global MODE
MODE = 1;

global cta v_wind seaHeight belta0 belta1 H0 H1 R0 R1

p = 1.025 * 10^3;	% 海水密度
g = 9.8;			% 重力加速度
M = 1000;			% 浮标重量
% v_wind = 36;		% 风速
buoy_G = M * g;		% 浮标的重力
F_allFloat = pi * 1^2 * 2 * p * g;		% 浮标最大浮力
% 锚链属性
chain_alldl = [0.078 0.105 0.120 0.150 0.180];
chain_alldm = [3.2 7 12.5 19.5 28.12];
chain_dl = chain_alldl(MODE);	% 锚链的每节链环长度
chain_dm = chain_alldm(MODE) * chain_dl;		% 锚链的每节质量
% chain_L = 22.05;	% 锚链总长
% chain_num = chain_L ./ chain_dl;	% 锚链个数
% 钢管属性
tube_m = 10;		% 钢管质量
tube_l = 1;			% 钢管长度
tube_d = 0.05;		% 钢管直径
tube_allG = 4 * tube_m * g;	% 钢管总重力
tube_allFloat = 4 * pi * (tube_d / 2)^2 * tube_l * p * g;	% 所有钢管的浮力和
% 钢桶属性
barrel_m = 100;		% 钢桶的质量
barrel_l = 1;		% 钢桶长度
barrel_d = 0.3;		% 钢桶直径
barrel_G = barrel_m * g;	% 钢桶总重力
barrel_allFloat = pi * (barrel_d / 2)^2 * barrel_l * p * g;	% 钢桶的浮力
% 标准化中间量
belta0  = 3.8973;
belta1 = 13.6020;
H0 = 0.7553;
H1 = 1.8871;
R0 = 10.3100;
R1 = 29.2537;

%% ******************************** 使用遗传算法计算 *********************************
seaHeight = 16;		% 海水深度
v_wind = 36;		% 风速
minTarget = inf;
allFloat = tube_allFloat + barrel_allFloat + F_allFloat;	% 所有最大浮力和
cta = 0;			% 浮标倾斜角

% counti = 1;
% for seaHeight = 16:0.1:20
% for chain_L = 25:1:28		% 取不同长度的锚链
	% chain_num = ceil(chain_L ./ chain_dl);	% 锚链环的数量
	% chain_G = chain_num * chain_dm * g;		% 锚链总质量
	% allG = chain_G + tube_allG + barrel_G + buoy_G;		% 总重力
	% sphere_maxM = (allFloat - allG) ./ g;	% 金属球允许的最大质量

	% sphere_maxBian = min(sphere_maxM,4500);		% 遍历最大值

	% countj = 1;
	% for sphere_m = 3700:100:4000
		
		% [R_all,minDelta,minAlp,minBelta,minGama,minH] = judgeHeight(chain_num,sphere_m,cta,v_wind,seaHeight);

		% noteGama(countj,counti) = 90 - minGama(end);
		% noteBelta(countj,counti) = minBelta;

	
    	%% ******************************** 找目标最小值 *********************************
 		% anchor_angle = 90 - minGama(end);
 		% barrel_angle = minBelta;
 		% if anchor_angle > 16 || barrel_angle > 5
 		% 	curTarget(countj,counti) = inf;
 		% else
 		% 	standize_belta = standize(minBelta,belta0,belta1);
 		% 	standize_H = standize(minH,H0,H1);
 		% 	standize_R = standize(R_all,R0,R1);
 		% 	curTarget(countj,counti) = 0.25*standize_belta + 0.5*standize_H + 0.25*standize_R;
 		% 	% curTarget(countj,1) = standize(minBelta,belta0,belta1) + standize(minH,H0,H1) + standize(R_all,R0,R1);
 		% 	% curTarget = minBelta * minH * R_all;
 		% end
	
 		% curBelta(countj,counti) = minBelta;
 		% curH(countj,counti) = minH;
 		% curR(countj,counti) = R_all;
	
 		% if curTarget(countj,counti) < minTarget
 		% 	minTarget = curTarget(countj,counti);
 		% 	minSphere = sphere_m;
 		% 	minChainL = chain_L;
 		% end
	
%     	countj = countj + 1;
%  	end
%  	counti = counti + 1;
% end	
% end

[Y,X] = MPGA_Sheffield(2,[16 1200],[30 4500],0)

toc

%% countHeight: 根据 h 计算总高
function [h_all,alp,belta,gama2] = countHeight(h,chain_num,sphere_m,cta,v_wind)
	
	% alp = zeros(4,1);	% 钢管倾斜角
	% belta = 0;			% 钢桶倾斜角
	% gama = zeros(int16(chain_num),1); % 锚链倾斜角
	% tube_cta = alp;		% 钢管受力（下）倾斜角
	% tube_T = alp;
	% barrel_cta = belta; % 钢桶受力（下）倾斜角
	% barrel_T = belta;
	% chain_cta = gama;	% 锚链受力（下）倾斜角
	% chain_T = gama;
	global MODE
	p = 1.025 * 10^3;	% 海水密度
	g = 9.8;			% 重力加速度
	M = 1000;			% 浮标重量
	% v_wind = 36;		% 风速
	buoy_G = M * g;		% 浮标的重力
	F_allFloat = pi * 1^2 * 2 * p * g;		% 浮标最大浮力
	% 锚链属性
	chain_alldl = [0.078 0.105 0.120 0.150 0.180];
	chain_alldm = [3.2 7 12.5 19.5 28.12];
	chain_dl = chain_alldl(MODE);	% 锚链的每节链环长度
	chain_dm = chain_alldm(MODE) * chain_dl;		% 锚链的每节质量
	% 钢管属性
	tube_m = 10;		% 钢管质量
	tube_l = 1;			% 钢管长度
	tube_d = 0.05;		% 钢管直径
	tube_allG = 4 * tube_m * g;	% 钢管总重力
	tube_allFloat = 4 * pi * (tube_d / 2)^2 * tube_l * p * g;	% 所有钢管的浮力和
	% 钢桶属性
	barrel_m = 100;		% 钢桶的质量
	barrel_l = 1;		% 钢桶长度
	barrel_d = 0.3;		% 钢桶直径
	barrel_G = barrel_m * g;	% 钢桶总重力
	barrel_allFloat = pi * (barrel_d / 2)^2 * barrel_l * p * g;	% 钢桶的浮力

	v_water = 1.5;

	%% ******************************** 数据准备 *********************************
	% V_inWater = p * g * h * pi;	% 浮标浸没体积
	F_float = p * g * pi * h;			% 浮力
	tube_float = p * g * pi * (tube_d / 2)^2 * tube_l;
	barrel_float = p * g * pi * (barrel_d / 2)^2 * barrel_l;
	S_wind = (2 - h) * cosd(cta) * 2 + pi / 2 * sind(cta);	% 风投影面积
	S_water = h * cosd(cta) * 2 + pi / 2 * sind(cta);	% 风投影面积
	F_wind = 0.625 * S_wind * v_wind^2;		% 风力
	F_water = 374 * S_water * v_water^2;	% 水流力
	F_x = F_wind + F_water;
	cta0 = atand(F_x ./ (F_float - M * g));	% 浮标所受拉力的倾斜角度
	T0 = F_x ./ sind(cta0);				% 浮标所受拉力大小
	
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
	gama2(1) = gama(1) * (gama(1) > 0) + 90 * (gama(1) < 0);
	
	for i = 2:chain_num
		chain_cta(i) = atand(chain_T(i-1) * sind(chain_cta(i-1)) ./ (chain_T(i-1) * cosd(chain_cta(i-1)) - chain_dm * g));
		chain_T(i) = chain_T(i-1) * sind(chain_cta(i-1)) / sind(chain_cta(i));
		gama(i) = countAngle(chain_T(i-1),chain_T(i),chain_cta(i-1),chain_cta(i));
	    gama2(i) = gama(i) * (gama(i) > 0) + 90 * (gama(i) < 0);
	end
	
	%% ******************************** 计算总高度 *********************************
	h1 = tube_l .* cosd(alp);
	h2 = barrel_l .* cosd(belta);
	h3 = chain_dl .* cosd(gama2);
	h_all = sum(h1) + h2 + sum(h3) + h;
end


%% judgeHeight: 判断 h 对应总高等于水深时的各个参数
function [R_all,minDelta,minAlp,minBelta,minGama,minH] = judgeHeight(chain_num,sphere_m,cta,v_wind,seaHeight)
	global MODE
	barrel_l = 1;		% 钢桶长度
	tube_l = 1;			% 钢管长度
	chain_alldl = [0.078 0.105 0.120 0.150 0.180];
	chain_dl = chain_alldl(MODE);	% 锚链的每节链环长度

	h_left = 0;
	h_right = 2;
	for i = 1:4
		minDelta = inf;
		minH = 0;
		stepLength = 0.1^i;
		for h = h_left:stepLength:h_right
		    % h = double(subs(f,'cta',cta));
			% h = 0.769888;
			[h_all,alp,belta,gama2] = countHeight(h,chain_num,sphere_m,cta,v_wind);
		
			%% ******************************** 找到总高度最接近 18 的 *********************************
			delta = abs(h_all - seaHeight);
			if delta < minDelta
				minDelta = delta;
				minH = h;
				% minCta = cta;
				h_left = minH - stepLength;
				h_right = minH + stepLength;
				minGama = gama2;
				minBelta = belta;
				minAlp = alp;
			end
		end
	end
	if minDelta > 0.1
		error('最小误差大于 0.1\n');
	end
	R_all = sum(tube_l .* sind(minAlp)) + barrel_l .* sind(minBelta) + sum(chain_dl .* sind(minGama));	
end


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

%% standize: 标准化
function [result] = standize(belta,belta0,belta1)
	result = (belta - belta0) ./ (belta1 - belta0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 遗传算法工具箱 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MPGA_Sheffield: 多种群遗传算法
% 注意改写 Fitness 函数
function [Y,X] = MPGA_Sheffield(NVAR,lb,ub,command)
	% input
	% NVAR = 2;		% 变量的维数
	% lb = [-3 4.1]; 	变量下限
	% ub = [12.1 5.8]; 	变量上限
	% command : 0 表示最小，1 表示最大
	% output
	% Y : 最优 Y
	% X : 最优 Y 对应的 X

	% 遗传参数（请根据具体情况修改！！）
	NIND = 40;		% 种群大小
	MAXGEN = 20;	% 最大遗传代数
	PRECI = 20;		% 个体长度
	GGAP = 0.9;		% 代沟
	MP = 10;		% 种群数目
	% 区域描述器 1：个体长度 2、3：上下界 4：编码方式（1为二进制 0为格雷码）
	% 5：子串使用刻度（0为算数 1为对数） 6、7：范围是否包含边界（1为是 0为否）
	FiledD = [repmat(PRECI,1,NVAR);lb;ub; repmat([1;0;1;1],[1,NVAR])];
	for i = 1:MP
		Chrom{i} = crtbp(NIND,NVAR * PRECI);
	end
	pc = 0.7 + (0.9 - 0.7) * rand(MP,1);		% 交叉概率在 [0.7,0.9]
	pm = 0.001 + (0.05 - 0.001) * rand(MP,1);	% 变异概率在 [0.001,0.05]
	gen = 0;
	gen0 = 0;
	MAXGEN = 10;
	if command == 1
		extremY = 0;
	else
		extremY = inf;
	end
	for i = 1:MP
		X = bs2rv(Chrom{i},FiledD);	
		ObjV{i} = Fitness(X);
	end
	ExtremObjV = zeros(MP,1);
	ExtremChrom = zeros(MP,PRECI * NVAR);
	while gen0 <= MAXGEN
		gen = gen + 1;
		for i = 1:MP
			if command == 1
				temp_ObjV = -ObjV{i};
			else
				temp_ObjV = ObjV{i};
			end
			FitnV{i} = ranking(temp_ObjV);
			SelCh{i} = select('sus',Chrom{i},FitnV{i},GGAP);	% 选择操作
			SelCh{i} = recombin('xovsp',SelCh{i},pc(i));		% 交叉操作
			SelCh{i} = mut(SelCh{i},pm(i));						% 变异操作
			X = bs2rv(SelCh{i},FiledD);	
			ObjVSel = Fitness(X);		% 子代目标函数值
			[Chrom{i},ObjV{i}] = reins(Chrom{i},SelCh{i},1,1,ObjV{i},ObjVSel);	% 重插入
		end
		[Chrom,ObjV] = immigrant(Chrom,ObjV,command);		% 移民操作
		[ExtremObjV,ExtremChrom] = EliteInduvidual(Chrom,ObjV,ExtremObjV,ExtremChrom,command);	% 人工选择精华种群
		if command == 1
			YY(gen) = max(ExtremObjV);						% 找出精华种群中的最优的个体
			% 判断当前优化值是否与前一次优化值相同
			if YY(gen) > extremY
				extremY = YY(gen);
				gen0 = 0;
			else
				gen0 = gen0 + 1;
			end
		else
			YY(gen) = min(ExtremObjV);
			if YY(gen) < extremY
				extremY = YY(gen);
				gen0 = 0;
			else
				gen0 = gen0 + 1;
			end
		end
		
	end
	plot(1:gen,YY)	% 进化图
	xlabel('进化代数')
	ylabel('最优解变化')
	title('进化过程')
	xlim([1,gen])
	
	if command == 1
		[Y,I] = max(ExtremObjV);		% 找出精华种群最优个体
	else
		[Y,I] = min(ExtremObjV);		% 找出精华种群最优个体
	end
	X = bs2rv(ExtremChrom(I,:),FiledD);		% 最优个体的解码解
end

%% Fitness: 适应度函数
function [ObjV] = Fitness(X)
	global MODE
	global cta;
	global v_wind;
	global seaHeight;
	global belta0 belta1 H0 H1 R0 R1;
	chain_alldl = [0.078 0.105 0.120 0.150 0.180];
	chain_dl = chain_alldl(MODE);	% 锚链的每节链环长度
	for i = 1:size(X,1)
		chain_L = X(i,1);
		sphere_m = X(i,2);
		chain_num = ceil(chain_L ./ chain_dl);	% 锚链环的数量
		[R_all,minDelta,minAlp,minBelta,minGama,minH] = judgeHeight(chain_num,sphere_m,cta,v_wind,seaHeight);
		anchor_angle = 90 - minGama(end);		% 起锚角
		barrel_angle = minBelta;				% 钢桶的倾斜角
		if anchor_angle > 16 || barrel_angle > 5
			standize_belta = standize(minBelta,belta0,belta1);
			standize_H = standize(minH,H0,H1);
			standize_R = standize(R_all,R0,R1);
			ObjV(i,1) = 0.25*standize_belta + 0.5*standize_H + 0.25*standize_R;
		else
			ObjV(i,1) = 1;
		end
	end
end

%% EliteInduvidual: 人工选择算子
function [ExtremObjV,ExtremChrom] = EliteInduvidual(Chrom,ObjV,ExtremObjV,ExtremChrom,command)
	MP = length(Chrom);
	for i = 1:MP
		if command == 1
			[ExtremO,ExtremI] = max(ObjV{i});		% 找出第 i 种群中最优的个体
			if ExtremO > ExtremObjV(i)
				ExtremObjV(i) = ExtremO;				% 记录各种群的精华个体
				ExtremChrom(i,:) = Chrom{i}(ExtremI,:);	% 记录各种群精华个体的编码
			end
		else
			[ExtremO,ExtremI] = min(ObjV{i});		% 找出第 i 种群中最优的个体
			if ExtremO < ExtremObjV(i)
				ExtremObjV(i) = ExtremO;				% 记录各种群的精华个体
				ExtremChrom(i,:) = Chrom{i}(ExtremI,:);	% 记录各种群精华个体的编码
			end
		end

	end
end

%% immigrant: 移民算子
function [Chrom,ObjV] = immigrant(Chrom,ObjV,command)
	MP = length(Chrom);
	for i = 1:MP
		if command == 1
			[ExtremO,ExtremI] = max(ObjV{i});		% 找出第 i 种群中最优的个体
			next_i = i + 1;
			if next_i > MP
				next_i = mod(next_i,MP);
			end
			[MinO,minI] = min(ObjV{next_i});	% 找出目标种群中最劣的个体
			% 目标种群最劣个体替换为源种群最优个体
			Chrom{next_i}(minI,:) = Chrom{i}(ExtremI,:);
			ObjV{next_i}(minI) = ObjV{i}(ExtremI);
		else
			[ExtremO,ExtremI] = min(ObjV{i});		% 找出第 i 种群中最优的个体
			next_i = i + 1;
			if next_i > MP
				next_i = mod(next_i,MP);
			end
			[MinO,minI] = max(ObjV{next_i});	% 找出目标种群中最劣的个体
			% 目标种群最劣个体替换为源种群最优个体
			Chrom{next_i}(minI,:) = Chrom{i}(ExtremI,:);
			ObjV{next_i}(minI) = ObjV{i}(ExtremI);
		end
	end
end