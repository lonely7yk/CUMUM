clc,clear
load data

X = allwater{3};
X = X / 100;    % 算百分比
Y = density;
[yuce,yuce_qian] = threeExp_zong(X);

k = X \ Y;

f = @(x) k(1) * x(1) + k(2) * x(2) + k(3) * x(3);

result_all = [];
for i = 1:10
	result = f(yuce(i,:));
	result_all = [result_all;result];
end

result_all

p = plot(2005:2014,result_all);
set(p,'LineWidth',1.5);
savePicture('水文年全流域废水浓度预测','时间(年)','废水浓度(吨/立方米)')

%% threeExp_zong: 批量做三次指数平滑
function [yuce,yuce_qian] = threeExp_zong(water)
	% 三个不同的指标
	vector1 = water(:,1);
	vector2 = water(:,2);
	vector3 = water(:,3);

	% 以下为预测指标
	[vector1_p,vector1_qian] = threeExp(vector1);
	[vector2_p,vector2_qian] = threeExp(vector2);
	[vector3_p,vector3_qian] = threeExp(vector3);

	yuce = [vector1_p,vector2_p,vector3_p];
	yuce_qian = [vector1_qian,vector2_qian,vector3_qian];
end
