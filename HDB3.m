function [t,y] = HDB3(x,f0,fs,doPlot)

%本函数实现将输入的一段二进制代码编为相应的AMI码输出

%输入x为二进制码，输出y为编出的单极性非归零码

%f0是码率，fs是采样率，最好是整数倍，单位K
x=HDB3trans(x);%进行编码转换
f0=f0*1000;
fs=fs*1000;  
t0=fix(fs/f0);
t=0:1/fs:length(x)/f0;
t=t(1:length(t)-1);%因为从0开始，所以多了一个点，把多出的一个点截掉。
for i = 1:length(x)     %计算码元的值
    if(x(i)==1);
       for j = 1:t0    %改码元对应的点值为1    
           y((i-1)*t0+j) = 1;
       end
    elseif(x(i)==-1)
       for j = 1:t0    %改码元对应的点值为1    
           y((i-1)*t0+j) = -1;
       end
    else
      for j = 1:t0    %改码元对应的点值为1    
          y((i-1)*t0+j) =0;
      end
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

function y=HDB3trans(x)
xn=x;
yn=xn;% 输出yn初始化
numZerosContiuns=0;% 计数器初始化
for k=1:length(xn)
   if xn(k)==1
      numZerosContiuns=numZerosContiuns+1;                % "1"计数器
         if numZerosContiuns/2 == fix(numZerosContiuns/2) % 奇数个1时输出-1,进行极性交替
              yn(k)=1;
         else
              yn(k)=-1;
         end
    end
end
        % HDB3编码
numZerosContiuns=0;  % 连零计数器初始化
yh=yn;  % 输出初始化
sign=0; % 极性标志初始化为0
V=zeros(1,length(yn));% V脉冲位置记录变量 
B=zeros(1,length(yn));% B脉冲位置记录变量
for k=1:length(yn)
   if yn(k)==0
       numZerosContiuns=numZerosContiuns+1;  % 连“0”个数计数
       if numZerosContiuns==4   % 如果4连“0”
           numZerosContiuns=0;    % 计数器清零
           if(k==4)%初始4个值为0
               yh(1)=1;
               yh(4)=1;
               sign=1;
          else
         yh(k)=1*yh(k-4); 
                            % 让0000的最后一个0改变为与前一个非零符号相同极性的符号
         V(k)=yh(k);        % V脉冲位置记录
         if yh(k)==sign     % 如果当前V符号与前一个V符号的极性相同
            yh(k)=-1*yh(k); % 则让当前V符号极性反转,以满足V符号间相互极性反转要求
            yh(k-3)=yh(k);  % 添加B符号,与V符号同极性
            B(k-3)=yh(k);   % B脉冲位置记录
            V(k)=yh(k);     % V脉冲位置记录
            yh(k+1:length(yn))=-1*yh(k+1:length(yn));
                            % 并让后面的非零符号从V符号开始再交替变化
         end
           end
       end
       sign=yh(k);          % 记录前一个V符号的极性
  else
      numZerosContiuns=0;                % 当前输入为“1”则连“0”计数器清零
  end
end    
y=yh;
end