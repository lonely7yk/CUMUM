%% oneExp: 一次指数平滑预测
function [yhat,err] = oneExp(data,alpha)

	yt = data;
	n = length(yt);
	m = length(alpha);
	yhat(1,1) = (yt(1) + yt(2)) / 2;
	for i = 2:n
		yhat(i,1) = alpha * yt(i - 1) + (1 - alpha) .* yhat(i - 1);
	end
	err = sqrt(mean((yt - yhat).^2));
