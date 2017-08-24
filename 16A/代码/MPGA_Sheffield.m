%% MPGA_Sheffield: 多种群遗传算法
% 注意改写 Fitness 函数
function [Y,X] = MPGA_Sheffield(NVAR,lb,ub,command)
	% input
	% NVAR = 2;		% 变量的维数
	% lb = [-3 4.1]; 	变量下限
	% ub = [12.1 5.8]; 	变量上限
	% command : 0 表示最小，1 表示最大
	% output
	% Y : 最优 Y
	% X : 最优 Y 对应的 X

	% 遗传参数（请根据具体情况修改！！）
	NIND = 40;		% 种群大小
	MAXGEN = 500;	% 最大遗传代数
	PRECI = 20;		% 个体长度
	GGAP = 0.9;		% 代沟
	MP = 10;		% 种群数目
	% 区域描述器 1：个体长度 2、3：上下界 4：编码方式（1为二进制 0为格雷码）
	% 5：子串使用刻度（0为算数 1为对数） 6、7：范围是否包含边界（1为是 0为否）
	FiledD = [repmat(PRECI,1,NVAR);lb;ub; repmat([1;0;1;1],[1,NVAR])];
	for i = 1:MP
		Chrom{i} = crtbp(NIND,NVAR * PRECI);
	end
	pc = 0.7 + (0.9 - 0.7) * rand(MP,1);		% 交叉概率在 [0.7,0.9]
	pm = 0.001 + (0.05 - 0.001) * rand(MP,1);	% 变异概率在 [0.001,0.05]
	gen = 0;
	gen0 = 0;
	MAXGEN = 10;
	if command == 1
		extremY = 0;
	else
		extremY = inf;
	end
	for i = 1:MP
		X = bs2rv(Chrom{i},FiledD);	
		ObjV{i} = Fitness(X);
	end
	ExtremObjV = zeros(MP,1);
	ExtremChrom = zeros(MP,PRECI * NVAR);
	while gen0 <= MAXGEN
		gen = gen + 1;
		for i = 1:MP
			if command == 1
				temp_ObjV = -ObjV{i};
			else
				temp_ObjV = ObjV{i};
			end
			FitnV{i} = ranking(temp_ObjV);
			SelCh{i} = select('sus',Chrom{i},FitnV{i},GGAP);	% 选择操作
			SelCh{i} = recombin('xovsp',SelCh{i},pc(i));		% 交叉操作
			SelCh{i} = mut(SelCh{i},pm(i));						% 变异操作
			X = bs2rv(SelCh{i},FiledD);	
			ObjVSel = Fitness(X);		% 子代目标函数值
			[Chrom{i},ObjV{i}] = reins(Chrom{i},SelCh{i},1,1,ObjV{i},ObjVSel);	% 重插入
		end
		[Chrom,ObjV] = immigrant(Chrom,ObjV,command);		% 移民操作
		[ExtremObjV,ExtremChrom] = EliteInduvidual(Chrom,ObjV,ExtremObjV,ExtremChrom,command);	% 人工选择精华种群
		if command == 1
			YY(gen) = max(ExtremObjV);						% 找出精华种群中的最优的个体
			% 判断当前优化值是否与前一次优化值相同
			if YY(gen) > extremY
				extremY = YY(gen);
				gen0 = 0;
			else
				gen0 = gen0 + 1;
			end
		else
			YY(gen) = min(ExtremObjV);
			if YY(gen) < extremY
				extremY = YY(gen);
				gen0 = 0;
			else
				gen0 = gen0 + 1;
			end
		end
		
	end
	plot(1:gen,YY)	% 进化图
	xlabel('进化代数')
	ylabel('最优解变化')
	title('进化过程')
	xlim([1,gen])
	
	if command == 1
		[Y,I] = max(ExtremObjV);		% 找出精华种群最优个体
	else
		[Y,I] = min(ExtremObjV);		% 找出精华种群最优个体
	end
	X = bs2rv(ExtremChrom(I,:),FiledD);		% 最优个体的解码解
end

%% Fitness: 适应度函数
function [ObjV] = Fitness(X)
	col = size(X,1);
	for i = 1:col
		ObjV(i,1) = 21.5 + X(i,1) * sin(4 * pi * X(i,1)) + X(i,2) * sin(20 * pi * X(i,2));
	end
end

%% EliteInduvidual: 人工选择算子
function [ExtremObjV,ExtremChrom] = EliteInduvidual(Chrom,ObjV,ExtremObjV,ExtremChrom,command)
	MP = length(Chrom);
	for i = 1:MP
		if command == 1
			[ExtremO,ExtremI] = max(ObjV{i});		% 找出第 i 种群中最优的个体
			if ExtremO > ExtremObjV(i)
				ExtremObjV(i) = ExtremO;				% 记录各种群的精华个体
				ExtremChrom(i,:) = Chrom{i}(ExtremI,:);	% 记录各种群精华个体的编码
			end
		else
			[ExtremO,ExtremI] = min(ObjV{i});		% 找出第 i 种群中最优的个体
			if ExtremO < ExtremObjV(i)
				ExtremObjV(i) = ExtremO;				% 记录各种群的精华个体
				ExtremChrom(i,:) = Chrom{i}(ExtremI,:);	% 记录各种群精华个体的编码
			end
		end

	end
end

%% immigrant: 移民算子
function [Chrom,ObjV] = immigrant(Chrom,ObjV,command)
	MP = length(Chrom);
	for i = 1:MP
		if command == 1
			[ExtremO,ExtremI] = max(ObjV{i});		% 找出第 i 种群中最优的个体
			next_i = i + 1;
			if next_i > MP
				next_i = mod(next_i,MP);
			end
			[MinO,minI] = min(ObjV{next_i});	% 找出目标种群中最劣的个体
			% 目标种群最劣个体替换为源种群最优个体
			Chrom{next_i}(minI,:) = Chrom{i}(ExtremI,:);
			ObjV{next_i}(minI) = ObjV{i}(ExtremI);
		else
			[ExtremO,ExtremI] = min(ObjV{i});		% 找出第 i 种群中最优的个体
			next_i = i + 1;
			if next_i > MP
				next_i = mod(next_i,MP);
			end
			[MinO,minI] = max(ObjV{next_i});	% 找出目标种群中最劣的个体
			% 目标种群最劣个体替换为源种群最优个体
			Chrom{next_i}(minI,:) = Chrom{i}(ExtremI,:);
			ObjV{next_i}(minI) = ObjV{i}(ExtremI);
		end
	end
end