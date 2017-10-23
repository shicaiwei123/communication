%% 初始化
clear all
f0=1;
fs=10;
SNR=5;
doPlot=true;
signalFinal=[];
bitError=[];
errorNum=0;
%加载二进制符号
x=load('signalSource');
s=x.s;
num=20000;
i=0;
x1=s(1:20000);
   %% 线路码映射
    %频率单位为K
    [t,y]=HDB3(x1,1,10,doPlot);
    [clockx,clocky]=Myclock(f0,fs);
    figure(2)
    plot(clockx,clocky+2)
    hold on
    plot(t,y)
    axis([5.28,5.29,-1.5,3.5]);
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
    title('HDB3信号功率谱')
    
    %% 信道传输
    signalAWGN=awgn(y,SNR,'measured');
    figure(4)
    subplot(2,1,1)
    plot(t,signalAWGN)
    axis([5.28,5.29,-1.5,2]);

    %% 信源接收
    T=1/f0;
    st=ones(1,10);
    numZeros=0;
    signalGet=conv(signalAWGN,st)/10;
    figure(4)
    subplot(2,1,2)
    stem(t,signalGet(1:length(t)))
    axis([0,0.01,-1,2]);
    signalSample=signalGet(10:10:end);
    signalTemp=signalSample;
    signalTemp(signalTemp<-0.5)=-1;
    signalTemp(signalTemp>0.5)=1;
    signalTemp=fix(signalTemp);
    input=signalTemp;                   % HDB3码输入
    decode=input;               % 输出初始化
    sign=0;                     % 极性标志初始化
    for k=1:length(signalTemp)
        if input(k) ~= 0
           if (sign==signalTemp(k)&&(numZeros>1)) % 如果当前码与前一个非零码的极性相同，防止误比特带来的误判错误
              decode(k-3:k)=[0 0 0 0];% 则该码判为V码并将*00V清零
           end
           sign=input(k);       % 极性标志
           numZeros=0;          %标志清0
        else
            numZeros=numZeros+1;

        end
    end
    signalAbs=abs(decode);
    signalJugdgment=bitxor(signalAbs,x1);
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
            
            
        
    
    
    
    
