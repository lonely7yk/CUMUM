%% qujianTrans: 区间型属性变换
function [result] = qujianTrans(qujian,lb,ub,x)
	f = @(qujian,lb,ub,x) (1 - (qujian(1) - x) ./ (qujian(1) - lb)) .* (x >= lb & x < qujian(1)) + ...
	(x >= qujian(1) & x <= qujian(2)) + ...
	(1 - (x - qujian(2)) ./ (ub - qujian(2))) .* (x > qujian(2) & x <= ub);

	result = f(qujian,lb,ub,x);
