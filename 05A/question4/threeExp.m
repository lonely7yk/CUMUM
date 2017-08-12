%% threeExp: 三次指数平滑
function [yhat,yhat_qian] = threeExp(data)
	yt = data;
	n = length(yt);
	alpha = 0.3;
	st0 = mean(yt(1:3));
	st1(1) = alpha * yt(1) + (1 - alpha) * st0;
	st2(1) = alpha * st1(1) + (1 - alpha) * st0;
	st3(1) = alpha * st2(1) + (1 - alpha) * st0;

	for i = 2:n
		st1(i) = alpha * yt(i) + (1 - alpha) * st1(i-1);
		st2(i) = alpha * st1(i) + (1 - alpha) * st2(i-1);
		st3(i) = alpha * st2(i) + (1 - alpha) * st3(i-1);
	end

	at = 3 * st1 - 3 * st2 + st3;
	bt = 0.5 * alpha / (1 - alpha)^2 * ((6 - 5 * alpha) * st1 - 2 * (5 - 4 * alpha) * st2 + (4 - 3 * alpha) * st3);
	ct = 0.5 * alpha^2 / (1 - alpha)^2 * (st1 - 2 * st2 + st3);
	yhat_qian = at + bt + ct;
	yhat_qian = yhat_qian';
	% plot(1:n,yt,'D',2:n,yhat(1:end-1),'*')

	% legend('实际值','预测值');
	xishu = [ct(end),bt(end),at(end)];

	yhat = polyval(xishu, 1:10);
	yhat = yhat';