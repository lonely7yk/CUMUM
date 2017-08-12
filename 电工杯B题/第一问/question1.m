clc,clear
load data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P = [];		% 当前时刻分性别各年龄段人口数 (列向量)，前半段是女性，后半段是男性
p_save= [];		% 保存各时刻各年龄段的人口数
% d_save = [];	% 保存各时刻各年龄段的死亡率
d = death_2010;		% 各年龄段的死亡率（根据 2010 年）
% d = DeathPredict(d_save,[2017,2030],[?,?]);		% 当前时刻各年龄段死亡率
m = 0;		% 各年龄段迁出率
% h = [0.1038 0.1483 0.1571 0.1335 0.1329 0.1656 0.1589]';		% 各年龄段女性生育加权因子
% h = [zeros(3,1);h;zeros(10,1)];
h = [];
h_temp = 0;
for i = 1:100
	h_temp = h_temp + h_yinzi(i);
	if mod(i,5) == 0
		h(end+1) = h_temp;
		h_temp = 0;
	end
end
h = h';
% belta0 = birth_2015 ./ h;
belta0 = [zeros(3,1);1.0 * ones(7,1);zeros(10,1)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sex = sex_2010;    % 各年龄段女性占总人口的比率
b = belta0 .* h;			% 各年龄段总人口增长率
P = [temp_P .* sex;temp_P .* (1 - sex)];	
n = length(P) / 2;	% 分组数目 n = 20
p_save(:,1) = P;	% 第一列为2015年的分性别各年龄段人数
t = 2016;           % 当前时刻
x0 = [2016 2030 2045 2050];
y0 = [1.45 2 1.65 1.65];
pp = csape(x0,y0);
for i = 2:4
	L1 = zeros(n);	% 用于女性记录繁殖率和存活率的矩阵
	L2 = zeros(n);	% 用于男性记录... 
	u = d + m;		% 人口流失率
	s = 1 - u;		% 人口存活率
	for i = 1:n-1
		L1(i+1,i) = s(i,1);
		L2(i+1,i) = s(i,2);
	end
	L1(end,end) = s(end,1);
	L2(end,end) = s(end,2);
	M1 = L1;
	M1(1,:) = b .* sex;
	M2 = zeros(size(M1));
	M3 = M2;
	M3(1,:) = b .* (1 - sex);
	M4 = L2;
	M = [M1,M2;M3,M4];	% 区分男女的繁殖率和存活率矩阵
	P = M * P;
	p_save = [p_save,P];    % 存储当前时刻分性别各年龄段人数
    % 更新时刻以及此时的 belta0 和 b 矩阵
    t = t + 5;
    belta0(10) = 0;     % 第十位年龄段失去生育能力
    belta0 = [belta(t);belta0(1:end-1)];
    b = belta0 .* h;
end
peo_sum = sum(p_save,1)
t = 2015:5:2030;
pp2 = csape(t,peo_sum);
peo_sum_m = ppval(pp2,[2015:2030])
plot([2015:2030],peo_sum_m);
%% 通过线性回归预测 n 年的死亡率
% 输入
% d_save : 已知序列(列向量)
% n : 年数
% ageLimit : 预测年限
% range : 已知年数范围 一行二列的矩阵
% 输出
% y : 预测序列
function y = DeathPredict(d_save,ageLimit,range)
	row = size(d_save,1);
	y = zeros(row,n);
	for i = 1:n
		p = polyfit([range(1):range(2)],d_save(i),1);
		y(i,:) = polyval(p, ageLimit(1), ageLimit(2));
	end
end
	
%% 每个女生在当前时刻的生育意向
% 输入
% t : 时刻，即哪一年
% 输出
% y : 一个列向量，表示每一年分性别个年龄段的生育率
function y = belta(t)
	% syms bb;		% belta大
	% syms bs;		% belta稳
	% syms b0;		% belta0
	syms x;
	% 下面写每个年龄段女性生育意向的方程形式，然后带入初值求得系数，以便把未来的生育意向方程求出
	% a = 1/exp(1) * (b0 - bs) / (bb - bs);
	f = 2-0.35*(1-exp(-(x-2030)/18.46)).^2;
	y = subs(f,'x',t);
end

%% 生育加权因子
% 输入
% r : 年龄
% 输出
% h : 生育加权因子
function y = h_yinzi(r)
    a = 7;
	if r < 15 || r > 50
		y = 0;
    else
		y = (r - 15).^(a-1) * exp(-(r-15)/2) / (2^a * factorial(a-1));
	end
end