clc,clear
close all;

%% ******************************** 读取数据 *********************************
load data2
load miu

%% ******************************** 红酒聚类 *********************************
category1 = RJuLeiAnalysis(red, 4, 'average');

red_get = [1 38 19 54];
category2 = QJuLeiAnalysis(red, 3, red_get,'euclidean','complete');
l1 = category2{1};
l2 = category2{2};
l3 = category2{3};
red_mean1 = mean(red2_miu(l1));
red_mean2 = mean(red2_miu(l2));
red_mean3 = mean(red2_miu(l3));

%% ******************************** 白酒聚类 *********************************
category1 = RJuLeiAnalysis(white, 4, 'average');

white_get = [1 20 42 46];
category2 = QJuLeiAnalysis(white, 3, white_get,'euclidean','complete');
l1 = category2{1};
l2 = category2{2};
l3 = category2{3};
white_mean1 = mean(white2_miu(l1));
white_mean2 = mean(white2_miu(l2));
white_mean3 = mean(white2_miu(l3));

%% 计算 R 型聚类 : 分析变量之间的相关性，调用将打印聚类结果，并画出聚类图
% 输入
% gj : 数据矩阵， 每一行代表一组数据
% num : 分类数量
% way : 聚类方法
function category = RJuLeiAnalysis(gj, num, way)

	if nargin < 3
		way = 'complete';
	end
	% a = textread('?') % 对相关系数矩阵 a 进行赋值
	
	% 如果相关系数矩阵没有直接给你，而是给的样本矩阵 gj ，可以
	% 通过 corrcoef(gj) 来得到相关系数，注意 corrcoef 计算
	% 的是列与列之间的相关系数矩阵

    gj = zscore(gj);
%% ******************************** 改 *********************************
	
	% a = corrcoef(gj);
	
	% d = 1 - abs(a); % 计算距离
	% d = tril(d); % 取下三角
	% nd = nonzeros(d); % 取不是 0 的值
	% nd = nd'; % 化成行向量

	nd = pdist(gj','correlation');

	z = linkage(nd, way) % 产生等级聚类树，并选择聚类方法
	% num = ?;  % 表示分多少类
	T = cluster(z,'maxclust',num) % 第一个参数表示生成聚类的阈值（一般为 maxclust），第二个参数表示分为多少类，y 为 n 行 1 列的矩阵（n 为指标数目）
	for i = 1:num	
		tm = find(T == i); % 求第 i 类的对象
		category{i} = tm';
		tm = reshape(tm,1,length(tm)); % 变成行向量，方便输出
		fprintf('第 %d 类的有 %s\n',i, int2str(tm)); % 打印分类结果
	end
	h = dendrogram(z,100); % 画聚类图
	set(h, 'Color', 'k', 'LineWidth', 1.3); % 设置图的线宽和颜色
end

%% 在 R 型聚类的基础上进行 Q 型聚类，最终打印聚类结果，并画出聚类图（分类时可以多分几次）
% 输入
% gj : 数据矩阵， 每一行代表一组数据
% remove : 通过 R 型聚类可将去掉相似度高的分析指标的列的索引
% method : 两两对象距离的取值方式 (pdist)
% way : 聚类方法
function category = QJuLeiAnalysis(gj, num, get, method, way)

	if nargin < 3
		remove = [];
		method = 'euclidean'
		way = 'single';
	elseif nargin < 4
		method = 'euclidean'
		way = 'single';
	elseif nargin < 5
		way = 'single';
	end
	
	% gj = load('?'); % 得到样本矩阵 gj
	gj = gj(:,get); % 通过 R 型聚类可将去掉相似度高的分析指标
	gj = zscore(gj); % 数据标准化
	y = pdist(gj, method); % 求对象间的距离
	z = linkage(y, way) % 产生等级聚类树，并选择聚类方法
	% num = ?;  % 表示分多少类
	% 可以多次分不同的类数来分析不同情况
	T = cluster(z,'maxclust',num) % 第一个参数表示生成聚类的阈值（一般为 maxclust），第二个参数表示分为多少类，y 为 n 行 1 列的矩阵（n 为指标数目）
	
	for i = 1:num	
		tm = find(T == i); % 求第 i 类的对象
		category{i} = tm';
		tm = reshape(tm,1,length(tm)); % 变成行向量，方便输出
		fprintf('第 %d 类的有 %s\n',i, int2str(tm)); % 打印分类结果
	end
	h = dendrogram(z); % 画聚类图
	set(h, 'Color', 'k', 'LineWidth', 1.3); % 设置图的线宽和颜色
end

