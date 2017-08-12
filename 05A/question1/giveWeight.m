%% giveWeight: 通过所给时间段的各地区指标参数来给各指标赋权值

% input
% data : 各地区各指标参数

% output
% weight : 权值
function [weight] = giveWeight(data)
	max_t = max(data);
	min_t = min(data);
	max_min = max_t - min_t;
	data(:,1) = (data(:,1) - min_t(1)) ./ max_min(1);
	data(:,2) = (max_t(2) - data(:,2)) ./ max_min(2);
	data(:,3) = (max_t(3) - data(:,3)) ./ max_min(3);
	f = @(qujian,lb,ub,x) (1 - (qujian(1) - x) ./ (qujian(1) - lb)) .* (x >= lb & x < qujian(1)) + ...
	(x >= qujian(1) & x <= qujian(2)) + ...
	(1 - (x - qujian(2)) ./ (ub - qujian(2))) .* (x > qujian(2) & x <= ub);

	qujian = [7,7]; lb = 6; ub = 9;
	data(:,4) = f(qujian,lb,ub,data(:,4));

	% temp_data = data;
	% temp_data(find(data==0))=1;

	n = size(data,1);	% 一共有多少个对象
	m = size(data,2);	% 一共有多少个指标
	k = 1 / log(n);		% log(x) 是 ln(x) 的意思，这里的 k 在下面需要使用
	p = data ./ repmat(sum(data,1),n,1);

	p(find(p == 0)) = 1;	% 当 p = 0 时规定 p*ln(p) = 0 所以直接可以给 p = 0 的值赋值为 1

	I = -k .* sum(p .* log(p),1);
	r = 1 - I;
	
	weight = r ./ sum(r);
end

