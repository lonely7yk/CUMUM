before.Wq_rg = queueTime(DSG_rg,ESG_rg,lamda,1) ./ (redTime .* q_before);	% 平均排队时间
Wq = queueTime(DSG_rg,ESG_rg,lamda,1);
before.W_rg = (ESG_rg + Wq) ./ (redTime .* q_before);						% 平均逗留时间
before.Lq_rg = queueLength(DSG_rg,ESG_rg,lamda,1) .* (redTime .* q_before);	% 平均排队长度


function [Wq,W,Lq] = countParas(DSG,ESG,lamda,redTime,q)
	% input
	% DSG : 服务时间和离开时间方差
	% ESG : 服务时间和离开时间期望
	% lamda : 来车强度（红绿灯时间和的倒数）
	% redTime : 红灯时间
	% q : 车流量
	% output
	% Wq : 排队时间
	% W : 逗留时间
	% Lq : 排队长度

	Wq = queueTime(DSG,ESG,lamda,1) ./ (redTime .* q);	% 平均排队时间
	temp = queueTime(DSG,ESG,lamda,1);
	W = (ESG + temp) ./ (redTime .* q);						% 平均逗留时间
	Lq = queueLength(DSG,ESG,lamda,1) .* (redTime .* q);	% 平均排队长度
end

%% queueTime: 平均排队时间
function [Wq] = queueTime(DSG,ESG,lamda,K)
	A = (DSG + ESG.^2) ./ (2 * ESG .* (K - lamda .* ESG));
	B = 0;
	for i = 0:K-1
		B = B + factorial(K - 1) .* (K - lamda .* ESG) ./ (factorial(i) .* (lamda .* ESG).^(K-i));
	end
	Wq = A ./ (1 + B);
end

%% queueLength: 平均排队长度
function [Lq] = queueLength(DSG,ESG,lamda,K)
	A = lamda .* (DSG + ESG.^2) ./ (2 * ESG .* (K - lamda .* ESG));
	B = 0;
	for i = 0:K-1
		B = B + factorial(K - 1) .* (K - lamda .* ESG) ./ (factorial(i) .* (lamda .* ESG).^(K-i));
	end
	Lq = A ./ (1 + B);
end