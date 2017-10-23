%% 初始化
clear all
f0=1;
fs=10;
SNR=5;
num=10000;
doPlot=true;
signalFinal=[];
signalErrorNum=0;
bitError=[];
errorNum=0;
%加载二进制符号
x=load('signalSource');
s=x.s;
i=0;
x1=s(1:10000);
   %% 线路码映射
    %频率单位为K
    [t,y]=Miller(x1,1,10,doPlot);
    meanMiller=mean(y(:));
    [clockx,clocky]=Myclock(f0,fs);
    figure(2)
    plot(clockx,clocky+2)
    hold on 
    plot(t,y)
    axis([0,0.01,-1.5,3.5]);
    legend('clock','data');
    ylabel('strength')
    xlabel('t/s')
    title('线路码信号')
    %% 求功率谱
    [Pxx,f]=periodogram(abs(y),[],[],fs*1000); %直接法
    figure(3)
    plot(f,10*log10(Pxx));
    ylabel('strength/db')
    xlabel('f/HZ')
    title('Miller信号功率谱')
    
    %% 信道传输
    signalAWGN=awgn(y,SNR,'measured');
    figure(4)
    subplot(2,1,1)
    plot(t,signalAWGN)
    axis([0,0.01,-1.5,2]);

    %% 信源接收
    T=1/f0;
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
            signalFinal(i/2)=1;
        elseif(signalTemp(i)<signalTemp(i-1))
            signalFinal(i/2)=1; 
        else
            signalFinal(i/2)=0; 
        end
    end
    signalJugdgment=bitxor(signalFinal,x1);
    signalError=find(signalJugdgment);
    bitError=vertcat(bitError,length(signalError)/num);
    %% 纠错
    signalNonzeroy=find(decode);
    signalErrorCorrection=decode(signalNonzeroy);
    for i=2:2:length(signalErrorCorrection)
        if(signalErrorCorrection(i)~=-signalErrorCorrection(i-1))
            signalErrorCorrection(i)=-signalErrorCorrection(i-1);
            errorNum=errorNum+1;
        end
    end
            
            
        
    
    
    
    
