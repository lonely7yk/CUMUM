clc,clear
close all

%% ******************************** 读取 *********************************
% 1. position : 1列编号、2列 x 坐标、3列 y 坐标、4列海拔、5列功能区
% 2. density : 1列编号、2列 As、3列 Cd、4列 Cr、5列 Cu、6列 Hg、7列 Ni、8列 Pb、9列 Zn
load Q1

%% ******************************** 初始化 *********************************
density = density(:,2:end);		% 除去第一列序号
background = [3.6	130	31	13.2	35	12.3	31	69];	% 各种金属的背景值
delta = [0.9	30	9	3.6	8	3.8	6	14];		% 标准差
T = [10	30	2	5	40	5	5	1];			% 各指标的毒性系数

%% ******************************** 计算每一个样本的 RI *********************************
% Cr = density ./ background;		% 污染指数
% Er = Cr .* T;					% 各指标的风险值
% RI = sum(Er,2);					% 风险系数

%% ******************************** 主成分分析调用 *********************************
[vec,lamda,rate] = ZhuChengFenAnalysis(density);

%% ******************************** 相关性分析 *********************************
gj = zscore(density);
[r,p] = corrcoef(gj);

%% ******************************** 验证 *********************************
pollute_average = mean(density,1);
pollute_std = std(density,0,1);
exceed_rate = (pollute_average - background) ./ pollute_average;

%% 主成分分析：只要输入数据矩阵 gj ，即可得到 gj 的主成分分析，注意如果 gj 不是相关系数矩阵
function [vec2,lamda,rate] = ZhuChengFenAnalysis(gj)
	% 输入
	% gj : 数据矩阵，gj 每行代表一组数据 （不要包含数据的索引）
	% （num 通过 contr 的贡献百分比决定，键盘输入）
	% 输出
	% stf : 从高到低的综合得分
	% ind : 综合得分对应的索引

	% gj = load('?'); % 读取文件数据
	gj = zscore(gj);	% 数据标准化
	r = corrcoef(gj); % 计算相关系数矩阵
	% 下面利用相关系数阵进行主成分分析，vec1 的列为 r 的特征向量，即主成分系数
	[vec1, lamda, rate] = pcacov(r);
	f = repmat(sign(sum(vec1)), size(vec1,1), 1);
	vec2 = vec1.*f;
	contr = cumsum(rate) / sum(rate);
	% num = input('num='); % num 为选取的主成分的个数
	index = find(contr >= 0.85);
	num = index(1);
	df = gj*vec2(:,1:num); % 计算各个主成分的得分
	tf = df*rate(1:num) / 100; % 计算综合得分
	[stf,ind] = sort(tf,'descend');
	stf = stf';ind = ind';
	
	% git结果
end