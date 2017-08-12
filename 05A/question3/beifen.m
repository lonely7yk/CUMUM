%% GM11: 灰色预测 GM(1,1)，适用于具有较强指数规律的序列
% 输入
% x0 : 原始数据（列向量）
% x0 = [71.1 72.4 72.4 72.1 71.4 72 71.6]
% 输出
% yuce : 预测值
% epsilon : 残差		(<0.2一般要求 <0.1较高要求)
% delta : 相对误差
% rho : 级比偏差值 （<0.2可以接受 <0.1较好）
function [yuce,epsilon,delta,rho] = GM11(x0)
	if size(x0,1) < size(x0,2)
		error('请将 x0 转换为列向量\n');
		return;
	end
	n = length(x0);	% 原始数据的长度

	% lambda = x0(1:n-1) ./ x0(2:n);	% 级比
	% range = minmax(lambda');	% 级比范围
	% % if range(1) < exp(-2/(n+1)) || range(2) > exp(2/(n+2))	% 本来应该这么写判断级比范围，这里我封装成了函数
	% if ~JudgeJiBi(x0)
	% 	error('级比范围不合适，请做适当平移');
	% else
	% 	disp('      ');
	% 	disp('可用GM11建模');
	% end
	
	x1 = cumsum(x0);	% 累加计算	
	B = [-0.5 * (x1(1:n-1) + x1(2:n)), ones(n-1,1)];
	Y = x0(2:n);
	u = B \ Y	% 拟合参数 u(1) = a, u(2) = b
	x = dsolve('Dx + a * x = b','x(0) = x0');	% 求微分方程的符号解
	x = subs(x, {'a','b','x0'}, {u(1),u(2),x0(1)});	% 代入估计参数值和初始解
	yuce1 = subs(x, 't', [n-1:2*n]);	% 求已知数据的预测值
	y = vpa(x,6)	% 显示 6 位数字的 x 表达式
	% 由于 yuce1 是 sym 数组不能直接用 diff 差分
	% yuce = [x0(1), diff(yuce1)]	% 差分运算，还原数据
	% yuce(1) = x0(1);
	for i = 1:10
		yuce(i) = yuce1(i+1) - yuce1(i);
	end
	yuce = double(yuce);
	% epsilon = x0' - yuce;	% 计算残差
	% delta = abs(epsilon ./ x0');
	% rho = 1 - (1 - 0.5 * u(1)) / (1 + 0.5 * u(1)) * lambda';	% 级比偏差值	
end