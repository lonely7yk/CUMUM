clc,clear
close all;

red_wine_s = xlsread('question4.xlsx',1,'D2:AD74')';
red_wine_s(find(isnan(red_wine_s))) = 0;
white_wine_s = xlsread('question4.xlsx',2,'D2:AE74')';
white_wine_s(find(isnan(white_wine_s))) = 0;
red_grape_s = xlsread('question4.xlsx',3,'D2:AD56')';
red_grape_s(find(isnan(red_grape_s))) = 0;
white_grape_s = xlsread('question4.xlsx',4,'D2:AE56')';
white_grape_s(find(isnan(white_grape_s))) = 0;

save data4