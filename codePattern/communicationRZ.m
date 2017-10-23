 %% 初始化
 %高电平表示1，低电平表示0，在一个时钟周期内会归0.
clear all
f0=1;
fs=10;
SNR=5;
signalFinal=[];
bitError=[];
doPlot=true;
%加载二进制符号
x=load('signalSource');
s=x.s;
num=length(s);
i=0;
x1=s(1:10000);
   %% 线路码映射
    %频率单位为K
    [t,y]=srz(x1,1,10,doPlot);
    [clockx,clocky]=Myclock(f0,fs);
    figure(2)
    plot(clockx(1:200),clocky(1:200)+2)
    hold on
    plot(t(1:100),y(1:100))
    axis([0,0.01,-1,4]);
    legend('clock','data');
    ylabel('strength')
    xlabel('t/s')
    title('线路码信号')
    %% 求功率谱
    [Pxx,f]=periodogram(y,[],[],fs*1000); %直接法
    figure(3)
    plot(f,10*log10(Pxx));
    ylabel('strength/db')
    xlabel('f/HZ')
    title('RZ信号功率谱')
    
    %% 信道传输
    signalAWGN=awgn(y,SNR,'measured');
    figure(4)
    subplot(2,1,1)
    plot(t(1:100),signalAWGN(1:100))
    axis([0,0.01,-1,2]);

    %% 信源接收
    T=1/f0;
    st=ones(1,5);
    %抗噪性的减小是来自于均值次数的减小？
    signalGet=conv(signalAWGN,st)/5;%根据归0时刻定
    figure(4)
    subplot(2,1,2)
    stem(t(1:100),signalGet(1:100))
    axis([0,0.01,-1,2]);
    signalSample=signalGet(5:10:end-5);%抽样间隔不变，但是抽样起始点改变了。
    signalTemp=signalSample;
    signalTemp(signalTemp<0.5)=0;
    signalTemp(signalTemp>0.5)=1;
    signalJugdgment=bitxor(signalTemp,x1);
    signalFinal=
    signalError=find(signalJugdgment);
bitError=vertcat(bitError,length(signalError)/num);
