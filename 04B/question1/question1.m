clc,clear('all');
load data1

a = {};	% 每一个元胞(1*8)表示一条线路所对应变量的次数的数组
k_bao = {};	% 每一个元胞(1*8)表示一条线路单独做线性回归时各

delta = {};	% 每一个元胞(1*8)表示一条线路不同变量次数进行回归之后的误差
for i = 1:6	% 一共 6 条线路，每条线路都产生一组 a 数组
	temp_a = [];	% 存放临时 a
	temp_k = [];
	for j = 1:8	% 每条线路都有 8 个 a系数
		temp_machine = machine{j}(:,j);
		temp_thread = thread{j,i};
		min_index = find(temp_thread == min(temp_thread));	% 当前线路当前组中线路最小的索引
		min_index = min_index(1);
		max_index = find(temp_thread == max(temp_thread));	% 当前线路当前组中线路最大的索引
		max_index = max_index(1);
		min_point = [temp_machine(min_index) temp_thread(min_index)];	% 最小点
		max_point = [temp_machine(max_index) temp_thread(max_index)];	% 最大点

		temp_machine([max_index,min_index]) = [];

		temp_thread([max_index,min_index]) = [];


		dis = [];	% 距离
		k_matix = [];	% 各个距离对应的 k

		for alp = 1:3	% 第一次规定 a 的范围在 1 到 10
			A = [min_point(1)^alp 1; max_point(1)^alp 1];
			B = [min_point(2); max_point(2)];
			X = A \ B;
			k = X(1);
			E = X(2);

			f = @(x) k .* x.^alp + E;

			dis = [dis;sum((temp_thread - f(temp_machine)).^2)];

			k_matix = [k_matix,k];
        end

		temp_a = [temp_a,find(dis == min(dis))];
		temp_k = [temp_k, k_matix(find(dis == min(dis)))];
	end
	a{i} = temp_a;
	k_bao{i} = temp_k;
end

K_result = {};

for i = 1:6
	cover = a{i};	% 各变量的幂
	temp_machine = excel_chuli;
	cover = repmat(cover,size(temp_machine,1),1);
	temp_machine = temp_machine .^ cover;
	X = [ones(size(temp_machine,1),1),temp_machine(:,:)];
	Y = excel_chaoliu(:,i);
	K = regress(Y,X);
	K_result{i} = K;
end

