clc,clear
load data

yuce = threeExp_zong(zhiwater{3});
figure
p = plot(2005:2014,yuce(:,1),2005:2014,yuce(:,2),2005:2014,yuce(:,3));
set(p,'LineWidth',1.5);
legend('I类+II类+III类','IV类+V类','劣V类');
savePicture('水文年支流水质预测','时间(年)','各类水质所占比重')

%% threeExp_zong: 批量做三次指数平滑
function yuce = threeExp_zong(water)
	% 三个不同的指标
	vector1 = water(:,1);
	vector2 = water(:,2);
	vector3 = water(:,3);

	% 以下为预测指标
	vector1_p = threeExp(vector1)';
	vector2_p = threeExp(vector2)';
	vector3_p = threeExp(vector3)';

	yuce = [vector1_p,vector2_p,vector3_p];
end

% [yuce,yuce_hou] = GM11(excel_paifang,10,1)

% result = [];
% for i = 1:5
% 	p1_ku = percent(1:9:end,i);

% 	% p1_ku = percent(1:9:end,4)+percent(1:9:end,5)
% 	% [yhat,err] = oneExp(p1_ku,0.8)
% 	% pencent(1:9:end,4)+pencent(1:9:end,5)+pencent(1:9:end,6)


% 	x = p1_ku;

% 	myaic = zeros(4,4);
% 	myaic(:) = inf;
% 	for i = 0:2
% 		for j = 0:2
% 			if i == 0 & j == 0
% 				continue
% 			end
% 			m = armax(x, [i, j]);
% 			myaic(i+1,j+1) = aic(m);
% 		% fprintf('p = %d, q = %d, AIC = %f\n', i, j, myaic);
% 		end
% 	end
% 	[p,g] = find(myaic == min(min(myaic))); %选取AIC最小对应的 p,q
% 	p = p - 1;  % 因为数组以 1 开头，而p,q 应该以 0 开头，所以 p,q 均减一
% 	g = g - 1;
% 	m = armax(x, [p,g]);
	
% 	xp = predict(m, x);
% 	% res = resid(m,x);
% 	res = x - xp;
% 	h = lbqtest(res);
	
% 	a  =forecast(m,x,10);
% 	result = [result,a];
% end
