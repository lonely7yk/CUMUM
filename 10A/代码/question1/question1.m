clc,clear
close all

%% ******************************** 引入变量 *********************************
% 第一列为累积进油量，第二列为油位高度
% 1. standard_in : 未倾斜进油数据
% 2. standard_out : 未倾斜出油数据
% 3. bias_in : 倾斜进油数据
% 4. bias_out : 倾斜出油数据
load data1

%% ******************************** 数据初始化 *********************************
a = 0.89;		% 长轴长
b = 0.6;		% 短轴长
l_before = 0.4;	% 圆柱的前一段
l_after = 2.05;	% 圆柱长的后一段
l = l_before + l_after;		% 圆柱的长度
alp = 4.1;        % 倾斜角度

initial_standard = 0.262;	% 未倾斜进油初始油量
initial_bias = 0.215;		% 倾斜进油初始油量
% Volume_standard(b,a,b,l)
% Volume_bias(b,a,b,l,alp)

%% ******************************** 未倾斜数据 *********************************
for i = 1:length(standard_in)
	volume_in_standard(i) = Volume_standard(standard_in(i,2),a,b,l);
end
for i = 1:length(standard_out)
	volume_out_standard(i) = Volume_standard(standard_out(i,2),a,b,l);
end

hold on;
volume_in_standard = volume_in_standard';				% 高度对应油体积的理论值
volume_in_standard_idea = volume_in_standard - initial_standard;		% 累积进油油体积的理论值
volume_in_standard_fact = standard_in(:,1);              % 累积进油油体积的实际值
elipson_in_standard = volume_in_standard_idea - volume_in_standard_fact;	% 累积进油差值

% 将排开油的体积与高度做一次线性回归
[xishu_standard,xishu_standard_rint,R_standard,R_standard_rint,stats_standard] = regress(elipson_in_standard,[standard_in(:,2) ones(length(standard_in),1)]);
plot(standard_in(:,2),elipson_in_standard,'o');
f = @(x) xishu_standard(1) .* x + xishu_standard(2);		% 排开油的体积随高度的变化
fplot(f);

% [xishu_standard,xishu_standard_rint,R_standard,R_standard_rint,stats_standard] = regress(elipson_in_standard,[standard_in(:,2).^3 standard_in(:,2).^2 standard_in(:,2) ones(length(standard_in),1)]);
% plot(standard_in(:,2),elipson_in_standard,'o');
% fplot(@(x) xishu_standard(1) * x.^3 + xishu_standard(2) * x.^2 + xishu_standard(3) * x + xishu_standard(4));

axis([0.14,1.21,0.00,0.15])
hold off;

% 残差分析图
figure
rcoplot(R_standard,R_standard_rint);

ruler_standard = [];	% 标尺对应的体积，共 120 个数据
for i = 1:120
	high = i * 0.01;
	ruler_standard(i) = Volume_standard(high,a,b,l) - f(high);
end
ruler_standard = ruler_standard';

volume_out_standard = volume_out_standard';		% 高度对应油体积的理论值

%% ******************************** 倾斜数据 *********************************
% 把浮标高度转化为有水平面在侧面的高度
bias_in_h = bias_in(:,2) + l_before * tan(alp * pi / 180);		
bias_out_h = bias_out(:,2) + l_before * tan(alp * pi / 180);

for i = 1:length(bias_in_h)
	volume_in_bias(i) = Volume_bias(bias_in_h(i),a,b,l,alp);
	volume_in_bias2(i) = volume_in_bias(i) - f(bias_in(i,2));
end
for i = 1:length(bias_out_h)
	volume_out_bias(i) = Volume_bias(bias_out_h(i),a,b,l,alp);
end

volume_in_bias = volume_in_bias';				% 高度对应油体积的理论值
volume_in_bias2 = volume_in_bias2';				
volume_in_bias_idea = volume_in_bias - initial_bias;		% 累积进油油体积的理论值
volume_in_bias_idea2 = volume_in_bias2 - initial_bias;		% 排油后累积进油油体积的理论值（使用未倾斜的模型）
volume_in_bias_fact = bias_in(:,1);              % 累积进油油体积的实际值
elipson_in_bias = volume_in_bias_idea - volume_in_bias_fact;	% 累积进油差值

ruler_bias = [];	% 标尺对应的体积，共 120 个数据
for i = 1:120
	high = i * 0.01;
	high2 = high + tan(alp * pi / 180) * l_before;
	ruler_bias(i) = Volume_bias(high2,a,b,l,alp) - f(high);
end
ruler_bias = ruler_bias';

volume_out_bias = volume_out_bias';		% 高度对应油体积的理论值


%% Volume_standard: 未倾斜的体积

% input
% h : 油位高度
% a : 长轴长
% b : 短轴长
% l : 圆柱的长度

% output
% volume : 油体积

function [volume] = Volume_standard(h,a,b,l)
	w = @(y) 2 * a * sqrt(1 - (y - b).^2 / b.^2);	% 油位对应椭圆柱横截面宽度
	volume = quadl(w,0,h) .* l;			% 积分求得油的体积
end

%% Volume_bias: 倾斜的体积

% input
% h : 油在倾斜的一面上的高度
% a : 长轴长
% b : 短轴长
% l : 圆柱的长度
% alp : 竖直倾斜角度

% output
% volume : 油体积

function [volume] = Volume_bias(h,a,b,l,alp)
	w = @(y) 2 * a * sqrt(1 - (y - b).^2 / b.^2);	% 油位对应椭圆柱横截面宽度
	% 分段函数
	z = @(y) (h - y) / tan(alp * pi / 180) .* (y >= (-tan(alp * pi / 180) * l + h)) + ...		% y = -tan4° * z + h 反解 z
		l .* (y < (-tan(alp * pi / 180) * l + h));			% 如果 z = l，则 z 不取反解结果
    dv = @(y) z(y) .* w(y);
    if h > 2 * b
        h1 = 2 * b;
    else
        h1 = h;
    end
    volume = quadl(dv,0,h1);
%  	volume = integral(dv,0,h);
end
