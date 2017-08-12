clc,clear
close all

%% ******************************** 读取数据 *********************************
% 1. red_grape : 红葡萄数据
% 2. red_wine : 红葡萄酒数据
% 3. white_grape : 白葡萄数据
% 4. white_wine : 白葡萄酒数据
load data3

white_target = [white_grape,white_wine];
[white_cor,white_p] = corrcoef(white_target);

%% ******************************** 给每组（9组）做找相关性高的指标 *********************************
[b1,num1,stats1] = ManyRegress(red_grape,red_wine)
[b2,num2,stats2] = ManyRegress(white_grape,white_wine)

%% ManyRegress: 将所有因变量和大部分自变量做回归
function [b1,num_all,stats1] = ManyRegress(red_grape,red_wine)
	m = size(red_wine,1);		% 看酒样品数量
	n = size(red_wine,2);		% 看酒有多少个指标

	red_target = [red_grape,red_wine];      % 把因变量和自变量放在一起
	[red_cor,red_p] = corrcoef(red_target);         % 计算因变量和自变量之间的相关系数

	red_cor = red_cor(31:30+n,1:30);
	red_p = red_p(31:30+n,1:30);

	for i = 1:n
		num1{i} = find(abs(red_cor(i,:)) >= 0.5);
		% num1{i} = find(red_p(i,:) <= 0.05);
	end

	% 看一共多少个指标相关性大于 0.5
	all_target = zeros(1,30);
	for i = 1:n
		all_target(num1{i}) = 1;
	end
	num_all = find(all_target == 1);
	
	X = [ones(m,1),red_grape(:,num_all),red_wine(:,1:n-1)];
	Y = red_wine(:,n);
	[b1,~,r,rint,stats1] = regress(Y,X);
	yhat = sum(repmat(b1',size(X,1),1) .* X,2);
	eplison = abs((yhat - Y) ./ Y)
    figure
	rcoplot(r,rint)
%     figure
%     plot(1:m,eplison,'o')
end