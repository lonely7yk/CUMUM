% data = [6.8 0.2 0.1 7.6 
% 8.41 2.8 0.34 7.63 
% 7.81 5.8 0.55 7.07 
% 6.47 2.9 0.34 7.58 
% 6.19 1.7 0.13 7.34 
% 6.54 3.2 0.22 7.52 
% 6.9 3.1 0.11 7.78 
% 4.2 5.8 0.53 7.66 
% 7.63 2.4 0.25 8.01 
% 4.02 3.6 1.06 7.63 
% 10.2 1.8 0.1 8.63 
% 6.45 4.3 0.99 7.42 
% 6.26 1.4 0.21 7.73 
% 6.43 2.4 0.17 8 
% 5.18 1.1 0.92 6.64 
% 6.87 2.7 0.15 7.28 
% 6.9 1.6 0.15 7.29 ];
% max_t = max(data);
% min_t = min(data);
% max_min = max_t - min_t;
% data(:,1) = (data(:,1) - min_t(1)) ./ max_min(1);
% data(:,2) = (max_t(2) - data(:,2)) ./ max_min(2);
% data(:,3) = (max_t(3) - data(:,3)) ./ max_min(3);
% f = @(qujian,lb,ub,x) (1 - (qujian(1) - x) ./ (qujian(1) - lb)) .* (x >= lb & x < qujian(1)) + ...
% 	(x >= qujian(1) & x <= qujian(2)) + ...
% 	(1 - (x - qujian(2)) ./ (ub - qujian(2))) .* (x > qujian(2) & x <= ub);
% qujian = [7,7]; lb = 6; ub = 9;
% data(:,4) = f(qujian,lb,ub,data(:,4));
% % data(find(data==0))=1
% n = size(data,1);	% 一共有多少个对象
% m = size(data,2);	% 一共有多少个指标
% k = 1 / log(n);		% log(x) 是 ln(x) 的意思，这里的 k 在下面需要使用
% p = data ./ repmat(sum(data,1),n,1);
% p(find(p == 0)) = 1;
% I = -k .* sum(p .* log(p),1);
% r = 1 - I;
% r
% weight = r ./ sum(r);

clc,clear('all');

x = [0.0189
    0.0188
    0.0200
    0.0144
    0.0218
    0.0236
    0.0248
    0.0251
    0.0271
    0.0303];

x0 = x';
x0 = [41 49 61 78 96 104];

n = length(x0);
x1 = cumsum(x0);
a_x0 = diff(x0)';
z = 0.5 * (x1(2:end) + x1(1:end-1))';
B = [-x0(2:end)',-z,ones(n-1,1)];
u = B\a_x0
x = dsolve('D2x + a1 * Dx + a2 * x = b','x(0) = c1, x(5) = c2');
x = subs(x,{'a1','a2','b','c1','c2'},{u(1),u(2),u(3),x1(1),x1(6)});
yuce = subs(x,'t',0:n-1);
yuce = double(yuce);
x = vpa(x,6)
x0_hat = [yuce(1),diff(yuce)];
epsilon = x0 - x0_hat
delta = abs(epsilon ./ x0)


