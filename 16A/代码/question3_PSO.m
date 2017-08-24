%--------------------------------------------------------------------------
%             question3_PSO.m  使用粒子群算法求解最优方案
%--------------------------------------------------------------------------
clc,clear
% close all
tic
% 将弧度转换为度数
tand = @(x) tan(x * pi / 180);
cosd = @(x) cos(x * pi / 180);
sind = @(x) sin(x * pi / 180);
atand = @(x) atan(x) * 180 / pi;
acosd = @(x) acos(x) * 180 / pi;
asind = @(x) asin(x) * 180 / pi;
sh = @(x) (exp(x) - exp(-x)) ./ 2;
ch = @(x) (exp(x) + exp(-x)) ./ 2; 

%% ******************************** 数据初始化 *********************************
% 锚链的种类
global MODE
% for k = 1:5
figure
MODE = 1;

global cta v_wind seaHeight belta0 belta1 H0 H1 R0 R1

p = 1.025 * 10^3;	% 海水密度
g = 9.8;			% 重力加速度
M = 1000;			% 浮标重量
% v_wind = 36;		% 风速
buoy_G = M * g;		% 浮标的重力
F_allFloat = pi * 1^2 * 2 * p * g;		% 浮标最大浮力
% 锚链属性
chain_alldl = [0.078 0.105 0.120 0.150 0.180];
chain_alldm = [3.2 7 12.5 19.5 28.12];
chain_dl = chain_alldl(MODE);	% 锚链的每节链环长度
chain_dm = chain_alldm(MODE) * chain_dl;		% 锚链的每节质量
% chain_L = 22.05;	% 锚链总长
% chain_num = chain_L ./ chain_dl;	% 锚链个数
% 钢管属性
tube_m = 10;		% 钢管质量
tube_l = 1;			% 钢管长度
tube_d = 0.05;		% 钢管直径
tube_allG = 4 * tube_m * g;	% 钢管总重力
tube_allFloat = 4 * pi * (tube_d / 2)^2 * tube_l * p * g;	% 所有钢管的浮力和
% 钢桶属性
barrel_m = 100;		% 钢桶的质量
barrel_l = 1;		% 钢桶长度
barrel_d = 0.3;		% 钢桶直径
barrel_G = barrel_m * g;	% 钢桶总重力
barrel_allFloat = pi * (barrel_d / 2)^2 * barrel_l * p * g;	% 钢桶的浮力
% 标准化中间量
belta0  = 3.8973;
belta1 = 13.6020;
H0 = 0.7553;
H1 = 1.8871;
R0 = 10.3100;
R1 = 29.2537;

%% ******************************** 使用遗传算法计算 *********************************
seaHeight = 16;		% 海水深度
v_wind = 36;		% 风速
minTarget = inf;
allFloat = tube_allFloat + barrel_allFloat + F_allFloat;	% 所有最大浮力和
cta = 0;			% 浮标倾斜角

chain_range = [14 30];
sphere_range = [1200 4500];
range = [chain_range;sphere_range];	% 参数变化矩阵
Max_V = 0.2 * (range(:,2) - range(:,1));	% 最大速度
n = 2;
PSOparams = [1 20 20 2 2 0.9 0.4 1500 1e-25 250 NaN 0 0];
pso_Trelea_vectorized('question3_Fitness',n,Max_V,range,0,PSOparams);

% end
toc