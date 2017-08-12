clc,clear
close all

%% ******************************** 导入数据 *********************************
% 1. red_grape : 红葡萄数据
% 2. red_wine : 红葡萄酒数据
% 3. white_grape : 白葡萄数据
% 4. white_wine : 白葡萄酒数据
% 5. red_grape_s : 红葡萄芳香物质
% 6. red_wine_s : 红葡萄酒芳香物质
% 7. white_grape_s : 白葡萄芳香物质
% 8. white_wine_s : 白葡萄酒芳香物质
% 9. red2_miu : 每个红酒样本的平均分
% 10. white2_miu : 每个白酒样本的平均分
% 11. red_target : 一行代表一个红酒样本，每个有 x 列，代表 x 个指标的平均分
% 12. white_target
load data3
load data4
load miu
load target

red_odor = sum(red_target(:,3:5),2);
white_odor = sum(white_target(:,3:5),2);

%% ******************************** 直接找相关系数大的参数回归 *********************************
% x_red = [red2_miu,red_grape,red_wine];		% 所有变量，第一列为因变量，其他为自变量
x_red1 = [red2_miu,red_grape,red_wine];		% 因变量得分和理化指标
x_red2 = [red2_miu,red_grape,red_wine,red_grape_s,red_wine_s];	% 因变量得分和理化指标和芳香物质
x_white1 = [white2_miu,white_grape,white_wine];
x_white2 = [white2_miu,white_grape,white_wine,white_grape_s,white_wine_s];

[red1_R,num1] = BigRegress(x_red1)
[red2_R,num2,b1] = BigRegress(x_red2)
[white1_R,num3] = BigRegress(x_white1)
[white2_R,num4,b2] = BigRegress(x_white2)

%% 找相关系数大的指标进行回归: function description
function [red_R,num1,red_b] = BigRegress(x_red)
	alpha = 0.05;
	n = size(x_red,1);
	[red_cor,red_p] = corrcoef(x_red);			% 计算相关系数和显著性水平
	red_cor = red_cor(1,:);						% 取第一列（看自变量和因变量的关系）
	red_p = red_p(1,:);
	num1 = [];
	% 找出显著性水平通过的变量
	for i = 2:length(red_cor)
		if red_p(i) < alpha && red_cor(i) > 0.3
			num1 = [num1,i];
		end
	end
	% 构造因变量矩阵
	X_red = [ones(size(x_red,1),1) x_red(:,num1)];
	% 构造自变量矩阵
	Y_red = x_red(:,1);
	% 标准化
	% X_red(:,2:end) = zscore(X_red(:,2:end));
	% Y_red = zscore(Y_red);
	% 做回归
	[red_b,red_brint,red_r,red_rrint,red_stats1] = regress(Y_red,X_red);
    red_R = red_stats1(1);
	red_b = red_b';4
	Y_red_hat = sum(red_b .* X_red,2);
	% 看误差
	delta_red = abs((Y_red_hat - Y_red) ./ Y_red);
    figure
	f = plot(1:n,delta_red,'o');
	% max(abs(delta_red))
	% red_stats1
end
	
