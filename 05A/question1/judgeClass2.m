%% judgeClass2 : 直接输入一个时刻的矩阵即可得到各地区的水质类别和决定因素

% input
% data : 一个时刻各地区各指标的参数	(17*4)

% output
% classNum : 归为第几类(17*1)
% determinant : 决定因素的序号即 1DO 2CODMn 3NH3_N 4PH	(17*1)

function [result] = judgeClass2(data)
	classNum = [];
	determinant = [];
	DO = data(1:17,1);
	CODMn = data(1:17,2);
	NH3_N = data(1:17,3);
	PH = data(1:17,4);
	for i = 1:17
		[classNum_t,determinant_t] = judgeClass1(DO(i),CODMn(i),NH3_N(i),PH(i));
		classNum = [classNum;classNum_t];
		determinant = [determinant;determinant_t];
	end

	result = [classNum,determinant];
