clc,clear
load data
yuce = threeExp_zong(allwater{3})

II = yuce(:,2);
III = yuce(:,3);

II = II - 20;
II(find(II < 0)) = 0;

M = (II * (k(2)-k(1)) + III * (k(3)-k(1))) .* flux/100


%% threeExp_zong: 批量做三次指数平滑
function yuce = threeExp_zong(water)
	% 三个不同的指标
	vector1 = water(:,1);
	vector2 = water(:,2);
	vector3 = water(:,3);

	% 以下为预测指标
	vector1_p = threeExp(vector1);
	vector2_p = threeExp(vector2);
	vector3_p = threeExp(vector3);

	yuce = [vector1_p,vector2_p,vector3_p];
end