function [t,y] = CMI(x,f0,fs,doPlot)

%本函数实现将输入的一段二进制代码编为相应的单极性非归零码输出

%输入x为二进制码，输出y为编出的单极性非归零码

%f0是码率，fs是采样率，最好是整数倍，单位K
f0=f0*1000;
fs=fs*1000;  
numZeros=1;
t0=fix(fs/f0);
t=0:1/fs:length(x)/f0;
t=t(1:length(t)-1);%因为从0开始，所以多了一个点，把多出的一个点截掉。
for i = 1:length(x)     %计算码元的值

    if(x(i) == 0)       %如果信息为1
            for j = 1:t0/2    %改码元对应的点值为1    

                y((i-1)*t0+j) = 0;
            end

            for j = t0/2+1:t0    %改码元对应的点值为1    

                y((i-1)*t0+j) = 1;
            end

%         numOnes=numOnes+1;

    else
        if(mod(numZeros,2)==1)
            for j = 1:t0    %反之，信息为0，码元对应点值取0

                y((i-1)*t0+j) = 0;

            end
        else
            for j = 1:t0    %反之，信息为0，码元对应点值取0
                y((i-1)*t0+j) = 1;
            end
        end
        numZeros=numZeros+1;

    end
    

end

%码型谱分析
%设定NRZ码型时间长度为1s,采样点数为1500
if doPlot
nrzy=[ones(1,750),zeros(1,750)];
figure(1)
subplot(2,1,1)
nrzx=0:1/1500:1;
nrzx=nrzx(1:length(nrzx)-1);
plot(nrzx,nrzy);
xlabel('t/s')
ylabel('strength')
title('NRZ时域')
fftY=fft(nrzy);
z=abs(fftY(1:750));
subplot(2,1,2)
plot(z)
xlabel('频率')
ylabel('strength')
title('NRZ频域')
axis([0,50,0,500])
end
end