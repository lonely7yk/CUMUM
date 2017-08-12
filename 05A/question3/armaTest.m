x = [9205
9513
9171.26
13127
9513
9924
8892.8
10210
9980
9405];

% myaic = zeros(3,3);
% myaic(:) = inf;
% for i = 0:2
% 	for j = 0:2
% 		if i == 0 & j == 0
% 			continue
% 		end
% 		m = armax(x, [i, j]);
% 		myaic(i+1,j+1) = aic(m);
% 		% fprintf('p = %d, q = %d, AIC = %f\n', i, j, myaic);
% 	end
% end
% [p,g] = find(myaic == min(min(myaic))); %选取AIC最小对应的 p,q
% p = p - 1;  % 因为数组以 1 开头，而p,q 应该以 0 开头，所以 p,q 均减一
% g = g - 1;
% m = armax(x, [p,g])

m = armax(x,[2,1])
myaic = aic(m)

xp = predict(m, x);
% res = resid(m,x);
res = x - xp;
h = lbqtest(res)

a = forecast(m,x,10)