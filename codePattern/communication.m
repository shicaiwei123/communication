%% 初始化
clear all
f0=1;
fs=10;
SNR=0;
signalFinal=[];
bitError=[];
BitError=[];
EsNo=[];
EbNo=[];
doPlot=false;
%加载二进制符号
x=load('signalSource'); 
s=x.s;
num=length(s);
j=0;
while(SNR<7)
k=0;
while(k<500)
  
    x1=s(k*20000+1:20000+k*20000);
    k=k+1
    %% 线路码映射
    %频率单位为K
    [t,y]=enconder4B5B(x1,1,10,doPlot);
%     [clockx,clocky]=Myclock(f0,fs);
%     figure(2)
%     plot(clockx(1:200),clocky(1:200)+2)
%     hold on
%     plot(t(1:100),y(1:100))
%     axis([0,0.01,-1,4]);
%     legend('clock','data');
%     ylabel('strength')
%     xlabel('t/s')
%     title('线路码信号')
    %% 信道传输
    signalAWGN=awgn(y,SNR,'measured');
    % figure(3)
    % subplot(2,1,1)
    % plot(t(1:100),signalAWGN(1:100))
    % axis([0,0.01,-1,2]);

    %% 信源接收

    T=1/f0;
    numberError=0;
    signalErrorNum=0;
    st=[ones(1,5),zeros(1,5)];
    signalGet=conv(signalAWGN,st)/5;
    figure(4)
    subplot(2,1,2)
    stem(t,signalGet(1:length(t)))
    axis([0,0.01,-1,2]);
    signalSample=signalGet(5:5:end-5);
    signalTemp=signalSample;
    signalTemp(signalTemp<=0.5)=0;
    signalTemp(signalTemp>=0.5)=1;
    for i=2:2:length(signalTemp)  %解码
        if(signalTemp(i)>signalTemp(i-1))
            signalDecoder(i/2)=0;
        elseif(signalTemp(i)<signalTemp(i-1))
            numberError=numberError+1;
            signalDecoder(i/2)=0; 
        else
            signalDecoder(i/2)=1; 
        end
    end
    signalJugdgment=bitxor(signalDecoder,x1);
    signalFinal=vertcat(signalFinal,signalJugdgment);
end
%坐标变换且记录坐标
EsNo(1+j)=10*log10(0.5*fs/f0)+SNR;
EbNo(1+j)=EsNo(1+j);
j=j+1

SNR=SNR+1;
signalError=find(signalFinal);
signalFinal=[];
BitError(j)=length(signalError)/num;
bitError=vertcat(bitError,length(signalError)/num);
end
%% 绘图
semilogy(EbNo,(bitError))
xlabel('EbNo(db)')
ylabel('误比特率')
title('误比特率曲线')