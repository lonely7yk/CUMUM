clc,clear('all');
close all;
tic
%% ******************************** 引入变量 *********************************
% 第一列为每次出油量，第二列为油位高度，第三列为油量容积
% 1. bias_before : 在加油前的倾斜数据
% 2. bias_after : 加油后倾斜数据
load data2


%% ******************************** 未倾斜情况下的高度对应的体积 *********************************
h = [bias_before(:,2);bias_after(:,2)];
volume_standard = [];		% 倾斜前油位对应的体积
v1_standard = [];
v2_standard = [];
for i = 1:length(h)
	[volume_standard(i),v1_standard(i),v2_standard(i)] = Volume_all([0,0],h(i));
end

volume_standard = volume_standard';
v1_standard = v1_standard';
v2_standard = v2_standard';
eplison = volume_standard - [bias_before(:,3);bias_after(:,3)];

%% ******************************** 穷举法最小二次拟合 *********************************
h1 = bias_before(1:end-1,2);
h2 = bias_before(2:end,2);
h_bias = [h1,h2];
delta_fact1 = bias_before(2:end,1);
minDelta = inf;
bias = [0,0];
for alp = 0:0.1:10
	for belta = 0:0.1:10
		delta_idea = Delta2([alp,belta],h_bias);
		del = sum((delta_idea - delta_fact1).^2);
		if minDelta > del
			minDelta = del;
			bias(1) = alp;
			bias(2) = belta;
		end
	end
end

%% ******************************** 前300组倾斜的尝试 *********************************
h1 = bias_before(1:end-1,2);
h2 = bias_before(2:end,2);
h_bias = [h1,h2];
delta_fact1 = bias_before(2:end,1);
delta_idea1 = Delta2(bias,h_bias);
del1 = abs(delta_idea1 - delta_fact1) ./ delta_fact1;
maxDel1 = max(del1);

%% ******************************** 后300组误差检测 *********************************
h1 = bias_after(1:end-1,2);
h2 = bias_after(2:end,2);
h_bias = [h1,h2];
delta_fact2 = bias_after(2:end,1);
delta_idea2 = Delta2(bias,h_bias);
del2 = abs(delta_idea2 - delta_fact2) ./ delta_fact2;
maxDel2 = max(del2);
h = plot(505:803,del2,'ro');
set(h,'markersize',6)

%% ******************************** 每 10 cm 的罐容表标定值 *********************************
ruler_bias = zeros(30,1);
for i = 1:30
	high = 0.1 * i;
	ruler_bias(i) = Volume_all(bias,high);
end

%% ******************************** 非线性拟合（失败） *********************************
% bias = [0 0];
% bias = lsqcurvefit(@Delta2,[0,0],h_bias,delta_fact,[0,0],[90,90])
% delta = Volume_all(bias,h(:,1)) - Volume_all(bias,h(:,2));

toc

% Delta2: 批量出油量
function [delta] = Delta2(bias,h)
	for i = 1:length(h)
		delta(i) = Delta(bias,h(i,:));
	end
	delta = delta';
end


%% Delta: 出油量

% input
% bias : 倾斜角度，alp = bias(1)，belta = bias(2) （拟合参数）
% h : 游标高度  h1 = h(1), h2 = h(2);

% output
% delta : 出油量

function [delta] = Delta(bias,h)
	delta = Volume_all(bias,h(1)) - Volume_all(bias,h(2));
	% delta = Volume_all(bias,h(1));
end


%% Volume_all : 求总体的油体积

% input
% bias : 倾斜角度，alp = bias(1)，belta = bias(2) （拟合参数）
% h : 游标高度（相当与自变量 x）

% output
% volume : 油的体积

function [volume,v1,v2] = Volume_all(bias,h)
	%% ******************************** 数据初始化 *********************************
	r = 1.5;		% 截面圆的半径
	l_before = 2;	% 圆柱的前一段
	l_after = 6;	% 圆柱长的后一段
	l = l_before + l_after;		% 圆柱的长度
	sphere_r = 3.25 / 2;		% 球的半径

	alp = bias(1);
	belta = bias(2);
	h_vertical = High_Trans(h,r,l_before,belta);

	v1 = Volume_Cylinder(h_vertical,alp,r,l,l_before);	% 圆筒内体积
	v2 = Volume_Sphere(h_vertical,alp,r,l,l_before);	% 球内体积
	volume = v1 + v2;
end


%% High_Trans: 浮标的高度转换（出去水平倾斜的影响）

% input
% biao_bias : 未做任何变化的倾斜浮标高度
% r : 横截面圆的半径
% l_before : 圆柱前半段长度
% alp : 竖直倾斜角度
% belta : 水平倾斜角度

% output
% h1 : 水平面在侧面的高度

function [h1] = High_Trans(biao_bias,r,l_before,belta)
	biao = r - (r - biao_bias) .* cos(belta * pi / 180);
	h1 = biao;
	% h1 = biao + l_before * tan(alp * pi / 180);
end


%% Volume_Cylinder: 倾斜的体积

% input
% h : 浮标高度
% alp : 竖直倾斜角度，计算不倾斜的只需要 alp = 0，或不加 alp
% n : 油在倾斜的一面上的坐标（高度 - 1.5）
% r : 截面圆的半径
% l : 圆柱的长度
% l_before : 圆柱前半段长度

% output
% volume : 油体积

function [volume] = Volume_Cylinder(h,alp,r,l,l_before)
	n = h + l_before * tan(alp * pi / 180) - r;		% 侧面水平面对应的纵坐标

	w = @(y) 2 * sqrt(r.^2 - y.^2);	% 油位对应圆柱横截面宽度
	if alp == 0
		z = l;
        dv = @(y) z .* w(y);
	else
	% 分段函数
		z = @(y) (n - y) ./ tan(alp * pi / 180) .* (y >= (-tan(alp * pi / 180) * l + n)) + ...		% y = -tan4° * z + h 反解 z
			l .* (y < (-tan(alp * pi / 180) * l + n));			% 如果 z = l，则 z 不取反解结果
        dv = @(y) z(y) .* w(y);
    end
    
	if n > r
		n1 = r;
	else
		n1 = n;
    end
	volume = quadl(dv,-r,n1);
	
	% 改1
	% for i = 1:length(n1)
	% 	volume(i) = quadl(dv,-r,n1(i));
	% end

	
	% volume = volume';
%  	volume = integral(dv,0,h);
end

%% Volume_Sphere: 球内的体积

% input
% h : 浮标高度
% alp : 竖直倾斜角度
% l : 圆柱的长度
% l_before : 圆柱前半段长度

% output
% volume : 球内体积

function [volume] = Volume_Sphere(h,alp,r,l,l_before)
	n = h + l_before * tan(alp * pi / 180) - r;
	y = @(z) -tan(alp * pi / 180) * z + n;

	%% ******************************** 左半球 *********************************
	tana = tan(alp * pi / 180);
	cosa = cos(alp * pi / 180);
	sina = sin(alp * pi / 180);

	if y(0) < r
		h0 = (h + 2 * tana) * cosa;
		% b = -(-3/2 + h + 13/8 * tana) / sqrt(1 + tana.^2);
		% R = @(h1) sqrt((13/8)^2 - (b + h1).^2);
		% % d = @(h1) sqrt((-5/8 + (b + h1) * sina).^2 + (3/2 - h1 - 2 * tana + h1 /cosa - (b + h1) * cosa).^2);
		% d = @(h1) abs(-5/8 + tana * (3 /2 - h1 - 2 * tana + h1 / cosa)) / sqrt(1 + tana.^2);
		% S = @(h1) R(h1).^2 .* acos(d(h1) ./ R(h1)) - d(h1) .* sqrt(R(h1).^2 - d(h1).^2);
	
		OA = @(h1) sqrt((-5/8).^2 + (-2 * tana + 3/2 - h + h1 / cosa).^2);
		b = @(h1) abs(3/2 - h - 11/8 * tana + h1 / cosa) / sqrt(1 + tana.^2);
		d = @(h1) sqrt(OA(h1).^2 - b(h1).^2);
		R = @(h1) sqrt((13/8)^2 - b(h1).^2);
		S = @(h1) R(h1).^2 .* acos(d(h1) ./ R(h1)) - d(h1) .* sqrt(R(h1).^2 - d(h1).^2);
		v1 = quadl(S,0,h0);
	else
		v1 = 4.0579;
	end
    
	% % 改1
	% for i = 1:length(h0)
	% 	v1(i) = quadl(S,0,h0(i));
	% end
	% v1 = v1';
	%% ******************************** 右半球 *********************************
	if y(l) > -r
		h02 = h * cosa - 6 * sina;
		% b2 = -(-3/2 + h - 43/8 * tana) / sqrt(1 + tana.^2);
% 		R2 = @(h1) sqrt((13/8)^2 - (b2 + h1).^2);
% % 		d2 = @(h1) sqrt((59/8 + (b2 + h1) * sina - 27/4).^2 + (3/2 - h1 + 6 * tana + h1 /cosa - (b2 + h1) * cosa).^2);
%         d2 = @(h1) abs(59/8 + tana * (h1 / cosa + 3/2 -h1 + 6 * tana) - 27/4) / sqrt(1 + tana.^2);
% 		S2 = @(h1) R2(h1).^2 .* acos(d2(h1) ./ R2(h1)) - d2(h1) .* sqrt(R2(h1).^2 - d2(h1).^2);
		
		OA2 = @(h1) sqrt((5/8).^2 + (6 * tana + 3/2 - h + h1 / cosa).^2);
		b2 = @(h1) abs(3/2 - h + 43/8 * tana + h1 / cosa) / sqrt(1 + tana.^2);
		d2 = @(h1) sqrt(OA2(h1).^2 - b2(h1).^2);
		R2 = @(h1) sqrt((13/8)^2 - b2(h1).^2);
		S2 = @(h1) R2(h1).^2 .* acos(d2(h1) ./ R2(h1)) - d2(h1) .* sqrt(R2(h1).^2 - d2(h1).^2);
		v2 = quadl(S2,0,h02);

		% % 改1
		% for i = 1:length(h02)
		% 	v2(i) = quadl(S2,0,h02(i));
		% end
		% v2 = v2';
	else
		v2 = 0;

		% 改1
		% v2 = zeros(length(h02),1);
    end

    %% ******************************** 显示 *********************************
    % S(0)
    % S(h0)
    % S2(0)
    % S2(h02)
	volume = real(v1 + v2);
end

%% Volume_all2: 通过蒙特卡洛来求的总体积
function [volume,v1,v2] = Volume_all2(bias,h)
	%% ******************************** 数据初始化 *********************************
	r = 1.5;		% 截面圆的半径
	l_before = 2;	% 圆柱的前一段
	l_after = 6;	% 圆柱长的后一段
	l = l_before + l_after;		% 圆柱的长度
	sphere_r = 3.25 / 2;		% 球的半径

	alp = bias(1);
	belta = bias(2);
	h_vertical = High_Trans(h,r,l_before,belta);

	v1 = Volume_Cylinder(h_vertical,alp,r,l,l_before);	% 圆筒内体积
	v2 = Mengte_V(h_vertical,l,sphere_r,alp);	% 球内体积
	volume = v1 + v2;

end

%% Mengte_V: 用蒙特卡洛法来计算球体积
function [volume] = Mengte_V(h,l,sphere_r,alp)
	r = 1.5;
	l_before = 2;
	n = h + l_before * tan(alp * pi / 180) - r;
	y = @(z) -tan(alp * pi / 180) * z + n;
	if y(0) < r
		% figure(1)
		hold on;
		count = 0;
		for i = 1:4000000
			x1 = (-2 * rand + 1) * sphere_r;		% [-sphere_r,sphere_r];
			y1 = sqrt(1 - x1.^2) * (-2 * rand + 1);
			z1 = 0.625 + sqrt(1 - x1.^2 - y1.^2) * (-2 * rand + 1);
			if z1 < 0 && y1 < y(z1)
				count = count + 1;
			end
	
			% if mod(i,10000) == 0
			% 	plot(i / 10000,count / i,'o');
			% end
		end
		hold off;
		v1 = count / i * 4 / 3 * pi * sphere_r.^3;

	else
		v1 = 4.0579;
	end

	if y(l) > 0
% 		figure(2)
		hold on;
		count = 0;
		for i = 1:4000000
			x1 = (-2 * rand + 1) * sphere_r;		% [-sphere_r,sphere_r];
			y1 = sqrt(1 - x1.^2) * (-2 * rand + 1);
			z1 = 7.375 + sqrt(1 - x1.^2 - y1.^2) * (-2 * rand + 1);
			if z1 > 8 && y1 < y(z1)
				count = count + 1;
			end
	
% 			if mod(i,10000) == 0
% 				plot(i / 10000,count / i,'o');
% 			end
		end
		hold off;
		v2 = count / i * 4 / 3 * pi * sphere_r.^3;
	else
		v2 = 0;
	end
	volume = v1 + v2;
end
