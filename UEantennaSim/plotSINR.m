function [] = plotSINR ()

x=[0 0 ;50 50*1.7 ; -50 50*1.7 ; 0 -100];
[dis_1,sir_1]=mainSINR(x);
x=[0 0 ;100 100*1.7 ; -100 100*1.7 ; 0 -200];
[dis_2,sir_2]=mainSINR(x);
x=[0 0 ;500 500*1.7 ; -500 500*1.7 ; 0 -1000];
[dis_3,sir_3]=mainSINR(x);
x=[0 0 ;5000 5000*1.7 ; -5000 5000*1.7 ; 0 -10000];
[dis_4,sir_4]=mainSINR(x);
figure;
hold on;
cdfplot(sir_1);
cdfplot(sir_2);
cdfplot(sir_3);
cdfplot(sir_4);
legend('50' , '100' , '500' , '5000' );

