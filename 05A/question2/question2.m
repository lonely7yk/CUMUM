% 2004.4~2005.4
clc,clear('all');
wuranwu = 3;

k = 0.2;	% 降解系数
excel_data = xlsread('water.xlsx');	% 一共28组数据
excel_ganliu = xlsread('ganliu.xlsx','C3:I28');
data  = {};		% 每一个元胞(17*4)代表一个时刻的各地区各指标参数(13个月)
Q_gan = [];	% 各干流的水流量水流量	1.四川攀枝花 2.重庆朱沱 3.湖北宜昌 4.湖南岳阳 5.江西九江 6.安徽安庆 7.江苏南京
v_gan = [];	% 各干流的流速	(13*7)
Q_zhi = [];	% 各支流的水流量		1.四川乐山8/四川宜宾9/四川泸州10 2.无 3.湖南长沙12/湖南岳阳13 4.湖北丹江口11/湖北武汉14 5.江西南昌15/江西九江16 6.无
v_zhi = [];	% 各支流的流速
t_gan = [];	% 各干流之间流动时间(6*1)
% t_zhi = [];	% 各支流之间流动时间(6*1)
C = [];	% 各干流污水浓度
D = [];	% 各支流污水浓度
address = [0 950 1728 2123 2623 2787 3251];	% 站点间位置
L = diff(address) * 1000;	% 站点间距离

increase = {};	% 每个元胞(1*6)表示一个时刻6个干流地区的污染产生多少

C_1 = @(C_0,t) C_0 * exp(-k * t/(24 * 3600));	% 降解方程

for i = 1:13
	data{i} = [excel_data(17*i+154:17*i+170,2:4),excel_data(17*i+154:17*i+170,1)];	% 取 2004.4 到 2005.4 的数据
end

Q_gan = excel_ganliu(1:2:26,:);
v_gan = excel_ganliu(2:2:26,:);

% for i = 1:6
% 	Q_zhi(i) = (Q_gan(i+1) + Q_gan(i)) / 2;
% 	v_zhi(i) = (v_gan(i) + v_gan(i+1)) / 2;
% 	t_gan(i) = L(i) / v_zhi(i);
% end

for i = 1:13
	Cx = [];	% 各干流污水增量
	C = data{i}(:,wuranwu);	% 当前时刻各地区污染物浓度 (17*1)
	C_jiang = [];	% 各干流降解后的污染物浓度 (6*1)
	
	v_gan_temp = v_gan(i,:);
	Q_gan_temp = Q_gan(i,:);

	for j = 1:6
		Q_zhi(j) = (Q_gan_temp(j+1) + Q_gan_temp(j)) / 2;
		v_zhi(j) = (v_gan_temp(j) + v_gan_temp(j+1)) / 2;
		t_gan(j) = L(j) / v_zhi(j);
	end

	D_zong = [C_1(C(8) + C(9) + C(10),t_gan(1)),0,C_1(C(12) + C(13),t_gan(3)),C(11)+C(14),C_1(C(15)+C(16),t_gan(5)),0];	% 每两个干流之间支流污染物浓度和(1*6)
 	D_zong = zeros(1,6);

	for j = 1:6
		C_jiang(j) = C_1(C(j),t_gan(j));
	end

	for j = 1:6
		Cx(j) = (Q_zhi(j)* D_zong(j) + Q_gan_temp(j) * C_jiang(j)) / (Q_gan_temp(j+1));
		% Cx(j) = (Q_zhi(j) * v_zhi(j) * D_zong(j) + Q_gan_temp(j) * v_gan_temp(j) * C_jiang(j)) / (Q_gan_temp(j+1) * v_gan_temp(j+1));
	end

	increase{i} = Cx;
end

result = [];
for i = 1:13
	result = [result;increase{i}];
end

result

csvwrite('result.csv',result)

% for i = 1:6
% 	result([find(result(:,i) == max(result(:,i))),find(result(:,i) == min(result(:,i)))]) = 0;
% end
% 
% result

% result = result';
% [~,index] = sort(result);
% xuhao_zong = [];
% for i = 1:6
% 	xuhao = [];
% 	for j = 1:13
% 		xuhao = [xuhao,find(index(:,j)==i)];
% 	end
% 	xuhao_zong = [xuhao_zong;xuhao];
% end

% xuhao_sum = sum(xuhao_zong,2);
% [~,finalResult] = sort(xuhao_sum)

