clc,clear
excel_data = xlsread('water.xlsx');	% 一共28组数据
data  = {};		% 每一个元胞(17*4)代表一个时刻的各地区各指标参数
weight = {};	% 每一个元胞(17*4)代表一个时刻的各指标权重
judgeClass = {};	% 每一个元胞(17*2)代表一个时刻的各地区水质类别和决定因素序号
point = {};		% 每一个元胞(17*1)代表一个时刻各地区的分数
pointResult = [];	% (17*28) 所有时刻各地区的分数
sortResult = [];

for i = 1:28
	data{i} = [excel_data(17*i-16:17*i,2:4),excel_data(17*i-16:17*i,1)];
	weight{i} = giveWeight(data{i});
	judgeClass{i} = judgeClass2(data{i});
	point{i} = countPoint(data{i},weight{i},judgeClass{i})';	% 各组的分数
	[sr,index] = sort(point{i});			% 排序结果
	pointResult = [pointResult,point{i}];
	sortResult = [sortResult,index];
end

xuhaozong = [];	% 所有的排序结果 (17*28)
for j = 1:17
	xuhao = [];
	for i = 1:28
		xuhao = [xuhao,find(sortResult(:,i) == j)];	% 看 28 个时刻 j 号地区为第几名
	end
	xuhaozong = [xuhaozong;xuhao];
end

xuhao_sum = sum(xuhaozong,2);	% 序号横向求和
[~,finalResult] = sort(xuhao_sum)

%% countPoint: 计算各地区的分数

% input
% data : 一个时刻各地区各指标的参数(17*1)
% judgeClass : 一个时刻的各地区水质类别和决定因素序号(17*2)

% output
% point : 一个时刻各地区的得分(17*1)

function [point] = countPoint(data,weight,judgeClass)
	DO_S = [10 7.5 6 5 3 2 0];		
	CODMn_S = [0 2 4 6 10 15 inf];
	NH3_N_S = [0 0.15 0.5 1.0 1.5 2.0 inf];
	PH_S = [6 9];

	qujian = [7,7];
	lb = 6;
	ub = 9;

	basicPoint = [75 50 45 30 15 0];	% 每个水质类别的基础分，分6级，满分为90分


	classNum = judgeClass(:,1);
	determinant = judgeClass(:,2);

	point = [];

	for i = 1:17
		% bound1 = [DO_S(1) - DO_S(classNum),CODMn_S(classNum) - CODMn_S(1),NH3_N_S(classNum) - NH3_N_S(1)];
		% bound2 = [DO_S(classNum) - DO_S(classNum+1),CODMn_S(classNum+1) - CODMn_S(classNum),NH3_N_S(classNum+1) - NH3_N_S(classNum)];
		temp = data(i,:);
		a = [];

		switch determinant(i)
			case 1
				a(1) = (temp(1) - DO_S(classNum(i) + 1)) / (DO_S(classNum(i)) - DO_S(classNum(i)+1));
				a(2) = 1 - (temp(2) - CODMn_S(1)) / (CODMn_S(classNum(i) + 1) - CODMn_S(1));
				a(3) = 1 - (temp(3) - NH3_N_S(1)) / (NH3_N_S(classNum(i) + 1) - NH3_N_S(1));
				a(4) = qujianTrans(qujian,lb,ub,temp(4));
			case 2
				a(1) = (temp(1) - DO_S(classNum(i) + 1)) / (DO_S(1) - DO_S(classNum(i) + 1));
				a(2) = 1 - (temp(2) - CODMn_S(classNum(i))) / (CODMn_S(classNum(i)+1) - CODMn_S(classNum(i)));
				a(3) = 1 - (temp(3) - NH3_N_S(1)) / (NH3_N_S(classNum(i) + 1) - NH3_N_S(1));
				a(4) = qujianTrans(qujian,lb,ub,temp(4));
			case 3
				a(1) = (temp(1) - DO_S(classNum(i))) / (DO_S(1) - DO_S(classNum(i)+1));
				a(2) = 1 - (temp(2) - CODMn_S(1)) / (CODMn_S(classNum(i)+1) - CODMn_S(1));
				a(3) = 1 - (temp(3) - NH3_N_S(classNum(i))) / (NH3_N_S(classNum(i)+1) - NH3_N_S(classNum(i)));
				a(4) = qujianTrans(qujian,lb,ub,temp(4));
			case 4
				a(1) = (temp(1) - DO_S(classNum(i))) / (DO_S(1) - DO_S(classNum(i)+1));
				a(2) = 1 - (temp(2) - CODMn_S(1)) / (CODMn_S(classNum(i)+1) - CODMn_S(1));
				a(3) = 1 - (temp(3) - NH3_N_S(1)) / (NH3_N_S(classNum(i)+1) - NH3_N_S(1));
				a(4) = qujianTrans(qujian,lb,ub,temp(4));
		end		

		point(i) = basicPoint(classNum(i));
		point(i) = point(i) + sum(weight .* a) * 15;
	end
end




