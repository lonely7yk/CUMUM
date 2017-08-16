clc,clear
close all

%% ******************************** 读取数据 *********************************
% 1. position : 1列编号、2列 x 坐标、3列 y 坐标、4列海拔、5列功能区
% 2. density : 1列编号、2列 As、3列 Cd、4列 Cr、5列 Cu、6列 Hg、7列 Ni、8列 Pb、9列 Zn
% 3. delta0 : 背景值方差
% 4. c : 中间值（变量为 d）
% 5. Dc : c 的导数
load Q2

%% ******************************** 计算 *********************************
% for i = 1:size(Dc,1)
% 	for j = 1:size(Dc,2)
% 		num(i,j) = double(subs(Dc(i,j),'d',1));
% 	end
% end

load num	% 由于计算时间太长，存储后直接读取
for i = 1:size(Dct,2)
    for j = 1:size(Dct,1)
        num(j,i) = abs(D2cd_num(j,i)) * delta0(position(j,5)) + abs(Dct_num(j,i));
    end
end

for i = 1:size(num,2)
    [s,index] = sort(num(:,i),'descend');
    result{i} = [index,s,position(index,[2,3,5])];
end