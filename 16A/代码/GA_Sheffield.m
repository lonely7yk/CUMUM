%% GA_Sheffield: 谢菲尔德工具箱遗传算法
% 千万注意是求最大值还是最小值需要改变 ranking 括号里的正负 和 '[Y,I] = min(ObjV);'
function [trace,noteExtrem,extremY,extremX] = GA_Sheffield(nvars,lb,ub,command)
	% input
	% nvars = 2;		% 变量数量
	% lb = [0 0]; ub = [10 10]; % lb 为变量下限，ub 为上限，均为行向量，长度与 nvars 相等
	% command : 0 表示求最小值，1 表示求最大值，默认为 0
	% output
	% trace : n+1 行，表示 n 个变量和 1 个结果；MAXGEN 列，每列表示一代的结果
	% noteExtrem : n+1 行，表示 n 个变量和 1 个结果；MAXGEN 列，每列表示到目前为止的最优结果
	% extremY : 最优 Y
	% extremX : 最优 Y 对应 X
	
	if nargin < 4
		command = 0;
	end
	
	% 遗传参数（请根据具体情况修改！！）
	NIND = 40;		% 种群大小
	MAXGEN = 500;	% 最大遗传代数
	PRECI = 20;		% 个体长度
	GGAP = 0.9;	% 代沟
	px = 0.7;		% 交叉概率
	pm = 0.05;		% 变异概率
	trace = zeros(nvars+1,MAXGEN);	% 寻优过程因变量和自变量
	noteExtrem = zeros(nvars+1,MAXGEN);	% 寻优过程最优因变量和自变量
	
	% 区域描述器 1：个体长度 2、3：上下界 4：编码方式（1为二进制 0为格雷码）
	% 5：子串使用刻度（0为算数 1为对数） 6、7：范围是否包含边界（1为是 0为否）
	FiledD = [repmat(PRECI,1,nvars);lb;ub; repmat([1;0;1;1],[1,nvars])];	
	Chrom = crtbp(NIND,PRECI * nvars);		% 随机种群（40 * 20）
	
	gen = 0;
	X = bs2rv(Chrom,FiledD);
	ObjV = Fitness(X);		% Fitness 需根据需求重写

	if command == 0
		extremY = inf;	% 求最小值
	else
		extremY = 0;	% 求最大值
	end

	extremX = zeros(1,nvars);	% 取到最大或最小时的 X 取值
	while gen < MAXGEN
		if command == 1
			temp_ObjV = -ObjV;	% 如果计算最大值就取相反数
		else
			temp_ObjV = ObjV;
		end
		FitnV = ranking(temp_ObjV);					% 适应度值（适应度越大个体越好，越有可能被选中）
		SelCh = select('sus',Chrom,FitnV,GGAP);	% 选择
		SelCh = recombin('xovsp',SelCh,px);		% 重组
		SelCh = mut(SelCh,pm);					% 变异
		X = bs2rv(SelCh,FiledD);				% 子代个体的十进制转换
	    ObjVSel = Fitness(X);
		[Chrom,ObjV] = reins(Chrom,SelCh,1,1,ObjV,ObjVSel);	% 重插入
		X = bs2rv(Chrom,FiledD);
		gen = gen + 1;

		if command == 0
			[Y,I] = min(ObjV);
			% 求最小值
			if extremY > Y
				extremY = Y;
				extremX = X(I,:);
			end
		else
			[Y,I] = max(ObjV);
			% 求最大值
			if extremY < Y
				extremY = Y;
				extremX = X(I,:);
			end
		end

		trace(1:end-1,gen) = X(I,:);	% 当代最优值对应的 X
		trace(end,gen) = Y;		% 当代最优值对应的 Y
		
		noteExtrem(1:end-1,gen) = extremX;
		noteExtrem(end,gen) = extremY;
	end
	
	% hold on
	plot(1:MAXGEN,noteExtrem(end,:));
	xlabel('进化代数')
	ylabel('最优解变化')
	title('进化过程')
end

%% Fitness: 适应度函数
function [ObjV] = Fitness(X)

end