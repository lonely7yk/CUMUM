clc,clear('all');
load data1

a = {};	% 每一个元胞(1*8)表示一条线路所对应变量的次数的数组
k_bao = {};	% 每一个元胞(1*8)表示一条线路单独做线性回归时各
E_bao = {};

% delta = {};	% 每一个元胞(1*8)表示一条线路不同变量次数进行回归之后的误差
for i = 1:6	% 一共 6 条线路，每条线路都产生一组 a 数组
	temp_a = [];	% 存放临时 a
	temp_k = [];
	temp_E = [];
	for j = 1:8	% 每条线路都有 8 个 a系数
		temp_machine = machine{j}(:,j);
		temp_thread = thread{j,i};
		% min_index = find(temp_thread == min(temp_thread));	% 当前线路当前组中线路最小的索引
		% min_index = min_index(1);
		% max_index = find(temp_thread == max(temp_thread));	% 当前线路当前组中线路最大的索引
		% max_index = max_index(1);
		% min_point = [temp_machine(min_index) temp_thread(min_index)];	% 最小点
		% max_point = [temp_machine(max_index) temp_thread(max_index)];	% 最大点

		% temp_machine([max_index,min_index]) = [];

		% temp_thread([max_index,min_index]) = [];

		% point = [temp_machine(1), temp_thread(1)];
		% temp_thread(1) = [];
		% temp_machine(1) = [];

		dis = [];	% 距离
		k_matix = [];	% 各个距离对应的 k
		E_matix = [];
		alp_matix = [];

		for alp = 0.5:0.1:5	% 第一次规定 a 的范围在 1 到 10
			A = [temp_machine.^alp, ones(5,1)];
			B = temp_thread;
			X = regress(B,A);
			k = X(1);
			E = X(2);

			f = @(x) k .* x.^alp + E;

			dis = [dis;sum((temp_thread - f(temp_machine)).^2)];

			k_matix = [k_matix,k];
			alp_matix = [alp_matix,alp];
			E_matix = [E_matix,E];
        end

	    index = find(dis == min(dis));	% 找到让距离最小的索引

		temp_a = [temp_a, alp_matix(index)];
		temp_k = [temp_k, k_matix(index)];
		temp_E = [temp_E, E_matix(index)];

	end
	a{i} = temp_a;
	k_bao{i} = temp_k;
	E_bao{i} = temp_E;
end



delta = [];

for i = 1:6
	for j = 1:8
		x = machine{j}(:,j);
		t = thread{j,i};
		e = E_bao{i}(j);
		k = k_bao{i}(j);
		alp = a{i}(j);
		f = k .* x .^ alp + e;
		temp_delta = (f - t) ./ f;
		delta = [delta, temp_delta];
	end
end

delta = abs(delta);

% K_result = {};
E_zong = [];

for i = 1:6
	cover = a{i};	% 各变量的幂
	temp_machine = excel_chuli;
	Y = excel_chaoliu(:,i);

	cover = repmat(cover,size(temp_machine,1),1);
	k = repmat(k_bao{i},size(temp_machine,1),1);

	temp_E = Y - sum(k .* temp_machine .^ cover,2);

	E_zong = [E_zong;mean(temp_E)];
	% temp_machine = temp_machine .^ cover;
	% X = [ones(size(temp_machine,1),1),temp_machine(:,:)];
	% K = regress(Y,X);
	% K_result{i} = K;
end

func = [];	% (12*8) 两行为一组，第一行为 k ，第二行为 alp
for i = 1:6
	k = k_bao{i};
	alp = a{i};
	func = [func;k;alp];
end

delta2 = [];
% 残差分析
for i = 1:6
	t = excel_chaoliu(:,i);
	X = excel_chuli;
	n = size(excel_chuli,1);	% 应变量组数
	k = repmat(k_bao{i},n,1);
	alp = repmat(a{i},n,1);
	Y = sum(k .* X .^ alp,2) + E_zong(i);
	delta2 = [delta2, abs((Y - t)./Y)];
end

y = {}; % 用来表示方程
for i = 1:6
    y{i} = @(x) sum(func(2*i-1,:).*x.^func(2*i,:)) + E_zong(i);
end

x = [153 88 228 60.5 98 155 102.1 117];
% y{5}(x)

sum = 0;
for i = 1:6
   sum = sum + abs(y{i}(x));
end

sum

% csvwrite('func.csv',func);
% csvwrite('delta2.csv',delta2);