%% judgeClass1: 判断水质在第几类中

% input
% DO : 溶解氧含量
% CODMn : 高锰酸盐指数
% NH3_N : 氨氮

% output
% classNum : 归为第几类
% determinant : 决定因素的序号即 1DO 2CODMn 3NH3_N 4PH
function [classNum,determinant] = judgeClass1(DO, CODMn, NH3_N, PH)
	classNum = 1;	% 初始化 classNum 和 determinant 为 1
	determinant = 1;

	% 以下为各指标的分类界限
	DO_S = [7.5 6 5 3 2 0];		
	CODMn_S = [2 4 6 10 15 inf];
	NH3_N_S = [0.15 0.5 1.0 1.5 2.0 inf];
	PH_S = [6 9];

	for i = 1:6
		if DO >= DO_S(i)
			classNum = i;
			determinant = 1;
			break;
		end
	end

	for i = 5 : -1 : classNum
		if CODMn > CODMn_S(i)
			classNum = i + 1;
			determinant = 2;
			break;
		end
	end

	for i = 5 : -1 : classNum
		if NH3_N > NH3_N_S(i)
			classNum = i + 1;
			determinant = 3;
			break;
		end
	end

	if PH > PH_S(2) || PH < PH_S(1)
		classNum = 6;
		determinant = 4;
	end

