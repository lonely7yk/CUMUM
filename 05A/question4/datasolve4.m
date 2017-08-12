clc,clear
excel_paifang = xlsread('tenyears.xlsx',1,'D2:D11');
excel_fenlei = xlsread('tenyears.xlsx',2,'D3:O92');
percent1 = excel_fenlei(:,2:2:end);
percent = [percent1(:,1) + percent1(:,2) + percent1(:,3), percent1(:,4) + percent1(:,5), percent1(:,6)];

density = [0.0189
		0.0188
		0.0200
		0.0144
		0.0218
		0.0236
		0.0248
		0.0251
		0.0271
		0.0303];

flux = [9464.69
9350.87
9256.12
9160.5
9066.06
8972.56
8880.04
8788.47
8697.84
8608.15];

k = [0.0142
0.0341
0.1106];
    
allwater = {};
ganwater = {};
zhiwater = {};

for i = 1:3
	allwater{i} = percent(3*i-2:9:end,:);
	ganwater{i} = percent(3*i-1:9:end,:);
	zhiwater{i} = percent(3*i:9:end,:);
end

save data