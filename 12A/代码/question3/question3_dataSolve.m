clc,clear
close all

red_grape = xlsread('question3_1.xlsx',1,'C3:AF29');
white_grape = xlsread('question3_1.xlsx',1,'C31:AF58');

red_wine = xlsread('question3_1.xlsx',2,'C3:K29');
white_wine = xlsread('question3_1.xlsx',2,'C31:K58');
% white_wine = [zeros(length(white_wine),1),white3_wine];

save data3