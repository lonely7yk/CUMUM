%% ******************************** 遗传算法解第一问 *********************************
%% fitnessfun: 适应度函数
function [Fitvalue,cumsump] = fitnessfun(population)
    popsize = size(population,1);
    for i = 1:popsize
        Fitvalue(i) = targetfun(population(i,:));
    end
    % 计算总概率
    fsum = sum(Fitvalue);
    Pperpopulation = Fitvalue / fsum;
    % 计算累积概率
    cumsump = cumsum(Pperpopulation);
end

%% targetfun: 目标函数
function [y] = targetfun(x)
    global y0
    global w
    y1 = y0 + x' .* w;
    y = std(y1,1);
end

%% selection: 选择操作
function [seln] = selection(population,cumsump)
    % 从种群中选择两个个体
    for i = 1:2
        r = rand;   % 生成一个随机数
        prand = cumsump - r;
        j = 1;
        while prand(j) < 0
            j = j + 1;
        end    
        seln(i) = j;    % 选中个体的序号
    end
end

%% crowwover: 交叉操作
function [scro] = crowwover(population,seln,pc)
    BitLength = size(population,2);
    pcc = IfCroIfMut(pc);       % 根据交叉概率决定是否进行交叉操作
    if pcc == 1
        chb = round(rand * (BitLength - 2)) + 1;    % 在 [1,BitLength - 1] 范围内随机产生一个交叉位
        scro(1,:) = [population(seln(1),1:chb) population(seln(2),chb + 1:BitLength)];
        scro(2,:) = [population(seln(2),1:chb) population(seln(1),chb + 1:BitLength)];
    else
        scro(1,:) = population(seln(1),:);
        scro(2,:) = population(seln(2),:);
    end
end

%% IfCroIfMut: 判断遗传算法是否需要进行交叉或变异
function [pcc] = IfCroIfMut(mutORcro)
    test(1:100) = 0;        % 初始化 100 个 0
    l = round(100 * mutORcro);    
    test(1:l) = 1;      % 把概率转换为 100 个数中的个数，赋值给 test 为 1
    n = round(rand * 99) + 1;
    pcc = test(n);
end
