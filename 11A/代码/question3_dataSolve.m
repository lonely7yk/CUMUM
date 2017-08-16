clc,clear
close all
tic
%% ******************************** 读取数据 *********************************
% 1. position : 1列编号、2列 x 坐标、3列 y 坐标、4列海拔、5列功能区
% 2. density : 1列编号、2列 As、3列 Cd、4列 Cr、5列 Cu、6列 Hg、7列 Ni、8列 Pb、9列 Zn
load Q1

%% ******************************** 求中间量和导数 *********************************
delta0 = [0.9	30	9	3.6	8	3.8	6	14];

syms Q t delta d
C = Q / ((4 * pi * t)^1.5 * delta^0.5) * exp(-d^2 / (4 * delta * t));

for j = 1:size(density,2)-1
	density_cur = density(:,j+1);		% 当前指标
	for i = 1:length(position)
		cd(i,j) = subs(C,{'Q','t','delta'},{density_cur(i),1,delta0(position(i,5))});	% cd 为 C 关于 d 的表达式
		ct(i,j) = subs(C,{'Q','d','delta'},{density_cur(i),1,delta0(position(i,5))});	% ct 为 C 关于 t 的表达式
	end
end

Dcd = diff(cd);		% 对 d 求导
D2cd = diff(Dcd);	% 对 d 求二次到
Dct = diff(ct);		% 对 t 求导

for i = 1:size(Dcd,1)
	for j = 1:size(Dcd,2)
        % cd_num(i,j) = double(subs(cd(i,j),'d',1));
        Dcd_num(i,j) = double(subs(Dcd(i,j),'d',1));
		D2cd_num(i,j) = double(subs(D2cd(i,j),'d',1));
		Dct_num(i,j) = double(subs(Dct(i,j),'t',1));
	end
end

clear i j density_cur
save Q2 
toc