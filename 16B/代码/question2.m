%--------------------------------------------------------------------------
%             question2.m
%             计算开放前和开放后排队时间、逗留时间和排队长度
%--------------------------------------------------------------------------

clc,clear
close all

global m kj
m = 0.5;
% kf1 = 1.247715;
% kf2 = 1.055157;
% kf3 = 0.689468;
kf1 = 8;
kf2 = 8;
kf3 = 8;
kj = 166.7;

v_before = 23.57;	% 开放前轿车平均速度
v_after = 24.17;	% 开放后轿车平均速度

uf1 = 40;			% 开放前的设计速度
uf2 = uf1 .* 1.05;	% 开放后的设计速度1
uf3 = uf1 .* 1.1;	% 开放后的设计速度2

ES = 4.47;
DS = 0.59;
redTime = 60;
EG = @(mark) redTime .* (mark == 1);
DG = @(mark) 0.5 .* (mark == 1);

k = [1:150];
count = 1;
for i = 10:0.1:150
	u1(count) = u_k(i,uf1,kf1);
    u2(count) = u_k(i,uf2,kf2);
    u3(count) = u_k(i,uf3,kf3);
    q1(count) = q_k(i,uf1,kf1);
    q2(count) = q_k(i,uf2,kf2);
    q3(count) = q_k(i,uf3,kf3);
    count = count + 1;
end
% hold on
% plot(10:0.1:150,u1,'LineWidth',3)
% plot(10:0.1:150,u2,'LineWidth',3)
% plot(10:0.1:150,u3,'LineWidth',3)
% legend('未开放前的自由流速度','开放后的自由流速度1','开放后的自由流速度2')
% % savePicture('速度-密度曲线','k/密度(km · 单车道)^-¹','v/km·h^-¹')
% hold off
% 
% figure
% hold on
% plot(10:0.1:150,q1,'LineWidth',3)
% plot(10:0.1:150,q2,'LineWidth',3)
% plot(10:0.1:150,q3,'LineWidth',3)
% legend('未开放前的自由流速度','开放后的自由流速度1','开放后的自由流速度2')
% % savePicture('流量-密度曲线','k/密度(km · 单车道)^-¹','q/密度(h·单车道)^-¹')

k1 = dichotomy(uf1,kf1,v_before);	% 二分法查找对应速度的密度
k2 = dichotomy(uf2,kf2,v_after);
k3 = dichotomy(uf3,kf3,v_after);

q_a1 = q_k(k1,uf1,kf1);	% 开放前速度1流量
q_b2 = q_k(k2,uf2,kf2);	% 开放后速度2流量
q_b3 = q_k(k3,uf3,kf3);	% 开放后速度3流量

%% ******************************** 开放前后各参数 *********************************
% K = 3;
q_before = 4345 / 3600;		% 开放前流量
q_after = 4079 / 3600;			% 开放后流量
alp = 0.31;				% 进入小区的车流量比例（一条支路）
alp2 = 0.476;			% 两条支路
DSG_rg = DS + DG(1);	% 有红绿灯情况下的离开时间和等待时间方差
ESG_rg = ES + EG(1);	% 有红绿灯情况下的离开时间和等待时间期望
DSG_nrg = DS + DG(0);	% 无红绿灯...方差
ESG_nrg = ES + EG(0);	% 无红绿灯...期望

lamda = 1 / 80;
lamda_road = (1 - alp) .* lamda;	% 进入道路的来车强度
lamda_road2 = (1 - alp2) .* lamda;
lamda_quarter = alp .* lamda;		% 进入小区的来车强度
lamda_quarter2 = alp2 .* lamda;

% L = [];
% for lamda = 0:0.0001:1
% 	
% 	before.Wq_rg = queueTime(DSG_rg,ESG_rg,lamda,1) ./ (redTime .* q_before);	% 平均排队时间
% 	before.W_rg = (ESG_rg + before.Wq_rg) ./ (redTime .* q_before);						% 平均逗留时间
% 	% before.Lq_rg = queueLength(DSG_rg,ESG_rg,lamda,1) .* (redTime .* q_before);	% 平均排队长度
% 	L = [L;queueLength(DSG_rg,ESG_rg,lamda,1) .* (redTime .* q_before)];
% end
% plot(L)

% 开放前有红绿灯
before.Wq_rg = queueTime(DSG_rg,ESG_rg,lamda,1) ./ (redTime .* q_before);	% 平均排队时间
Wq = queueTime(DSG_rg,ESG_rg,lamda,1);
before.W_rg = (ESG_rg + Wq) ./ (redTime .* q_before);						% 平均逗留时间
before.Lq_rg = queueLength(DSG_rg,ESG_rg,lamda,1) .* (redTime .* q_before);	% 平均排队长度

% 开放前无红绿灯
before.Wq_nrg = queueTime(DSG_nrg,ESG_nrg,lamda,1) ./ (redTime .* q_before);	
Wq = queueTime(DSG_nrg,ESG_nrg,lamda,1);
before.W_nrg = (ESG_nrg + Wq) ./ (redTime .* q_before);						
before.Lq_nrg = queueLength(DSG_nrg,ESG_nrg,lamda,1) .* (redTime .* q_before);

% 开放后有红绿灯（一条支路）
after.Wq_rg1 = queueTime(DSG_rg,ESG_rg,lamda_road,1) ./ (redTime .* q_after);
Wq = queueTime(DSG_rg,ESG_rg,lamda_road,1);
after.W_rg1 = (ESG_rg + Wq) ./ (redTime .* q_after);
after.Lq_rg1 = queueLength(DSG_rg,ESG_rg,lamda_road,1) .* (redTime .* q_after);

% 开放后有红绿灯
after.Wq_nrg1 = queueTime(DSG_nrg,ESG_nrg,lamda_road,1) ./ (redTime .* q_after);
Wq = queueTime(DSG_nrg,ESG_nrg,lamda_road,1);
after.W_nrg1 = (ESG_nrg + Wq) ./ (redTime .* q_after);
after.Lq_nrg1 = queueLength(DSG_nrg,ESG_nrg,lamda_road,1) .* (redTime .* q_after);

% 开放后有红绿灯（两条支路）
after.Wq_rg2 = queueTime(DSG_rg,ESG_rg,lamda_road2,1) ./ (redTime .* q_after);
Wq = queueTime(DSG_rg,ESG_rg,lamda_road2,1);
after.W_rg2 = (ESG_rg + Wq) ./ (redTime .* q_after);
after.Lq_rg2 = queueLength(DSG_rg,ESG_rg,lamda_road2,1) .* (redTime .* q_after);

% 开放后有红绿灯
after.Wq_nrg2 = queueTime(DSG_nrg,ESG_nrg,lamda_road2,1) ./ (redTime .* q_after);
Wq = queueTime(DSG_nrg,ESG_nrg,lamda_road2,1);
after.W_nrg2 = (ESG_nrg + Wq) ./ (redTime .* q_after);
after.Lq_nrg2 = queueLength(DSG_nrg,ESG_nrg,lamda_road2,1) .* (redTime .* q_after);

% 开放后一条支路
after.Wq_quarter_nrg1 = queueTime(DSG_nrg,ESG_nrg,lamda_quarter,1) ./ (redTime .* q_after);
Wq = queueTime(DSG_nrg,ESG_nrg,lamda_quarter,1);
after.W_quarter_nrg1 = (ESG_nrg + Wq) ./ (redTime .* q_after);
after.Lq_quarter_nrg1 = queueLength(DSG_nrg,ESG_nrg,lamda_quarter,1) .* (redTime .* q_after);

% 开放后两条支路
after.Wq_quarter_nrg2 = queueTime(DSG_nrg,ESG_nrg,lamda_quarter2,2) ./ (redTime .* q_after);
Wq = queueTime(DSG_nrg,ESG_nrg,lamda_quarter2,2);
after.W_quarter_nrg2 = (ESG_nrg + Wq) ./ (redTime .* q_after);
after.Lq_quarter_nrg2 = queueLength(DSG_nrg,ESG_nrg,lamda_quarter2,2) .* (redTime .* q_after);


%% u_k: 速度和密度的关系
function [u] = u_k(k,uf,kf)
	global m kj

	if k >= kf && k < 1/4 * kj - (1 - m) ./ m .* kf
		u = uf .* (m + (1 - m) .* kf / k);
	elseif 1/4 * kj - (1 - m) ./ m .* kf <= k && k <= 1/2 .* kj
		u = 1/4 .* m .* uf .* kj ./ k;
	else
		u = m .* uf .* (1 - k ./ kj);
	end
end

%% q_k: 流量和密度的关系
function [q] = q_k(k,uf,kf)
	global m kj

	if k >= kf &&  k< 1/4 * kj - (1 - m) ./ m .* kf
		q = uf .* (m .* k + (1 - m) .* kf);
	elseif 1/4 * kj - (1 - m) ./ m .* kf <= k && k <= 1/2 .* kj
		q = 1/4 .* m .* uf .* kj;
	else
		q = m .* uf .* (k - k.^2 ./ kj);
	end
end

%% dichotomy: 二分法搜索
function [k] = dichotomy(uf,kf,v_target)
	global kj
	left = 0;
	right = kj;
	delta = inf;
	while (1)
		k = (left + right) / 2;
		v_temp = u_k(k,uf,kf);
		delta = v_temp - v_target;
		if abs(delta) < 0.001
			break
		end

		if delta > 0
			left = k;
		else
			right = k;
		end
	end
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