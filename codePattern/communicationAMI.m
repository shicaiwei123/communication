%% 初始化
%低电平表示0，高低电平交替表示1.
clear all
f0=1;
fs=10;
SNR=5;
num=200000;
doPlot=true;
signalFinal=[];
bitError=[];
errorNum=0;
%加载二进制符号
x=load('signalSource');
s=x.s;
i=0;
x1=s(1:100000);
   %% 线路码映射
    %频率单位为K
    [t,y]=AMI(x1,1,10,doPlot);
    [clockx,clocky]=Myclock(f0,fs);
    figure(2)
    plot(clockx(1:200),clocky(1:200)+2)
    hold on
    plot(t(1:100),y(1:100))
    axis([0,0.01,-1.5,3.5]);
    legend('clock','data');
    ylabel('strength')
    xlabel('t/s')
    title('线路码信号')
    %% 求功率谱
    %也许是过程问题，需要功率较低
    [Pxx,f]=periodogram(y,[],[],fs*1000); %直接法
    figure(3)
    plot(f,10*log10(Pxx));
    ylabel('strength/db')
    xlabel('f/HZ')
    title('AMI信号功率谱')
    
    %% 信道传输
    signalAWGN=awgn(y,SNR,'measured');
    figure(4)
    subplot(2,1,1)
    plot(t(1:100),signalAWGN(1:100))
    axis([0,0.01,-1.5,2]);

    %% 信源接收
    T=1/f0;
    st=ones(1,5);
    signalGet=conv(signalAWGN,st)/5;
    figure(4)
    subplot(2,1,2)
    stem(t(1:100),signalGet(1:100))
    axis([0,0.01,-1,2]);
    signalSmy=signalGet;
    signalSmy(signalSmy<0.5)=-1;
    signalSmy(signalSmy<0.5)=1;
    signalSmy=fix(signalSmy);
    signalSample=signalGet(5:10:end);
    signalTemp=signalSample;
    signalTemp(signalTemp<-0.5)=-1;
    signalTemp(signalTemp>0.5)=1;
    signalTemp=fix(signalTemp);
    signalAbs=abs(signalTemp);
    %接收后功率谱
    [Pxx,f]=periodogram(abs(signalSmy),[],[],fs*1000); %直接法
    figure(5)
    plot(f,10*log10(Pxx));
    ylabel('strength/db')
    xlabel('f/HZ')
    title('AMI信号功率谱')
    signalJugdgment=bitxor(signalAbs,x1);
    signalError=find(signalJugdgment);
    bitError=vertcat(bitError,length(signalError)/num);
    %% 检错
    %如果两个1的符号相同，那么肯定有一个出错了。
    %一个1变成了-1，或者一个-1变成了1，或者0变成了1或-1.
    signalNonzeroYlabel=find(signalTemp);
    signalErrorCorrection=signalTemp(signalNonzeroYlabel);
    for i=2:2:length(signalErrorCorrection)
        if(signalErrorCorrection(i)~=-signalErrorCorrection(i-1))
%           signalErrorCorrection(i)=-signalErrorCorrection(i-1);
            errorNum=errorNum+1;
        end
    end
            
            
        
    
    
    
    
