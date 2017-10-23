function [t,y] = Myclock(f0,fs)

%本函数实现将输入的一段二进制代码编为相应的单极性非归零码输出

%输入x为二进制码，输出y为编出的单极性非归零码

%f0是码率，fs是采样率，最好是整数倍，单位K
f0=f0*1000;
fs=fs*2000;  
t0=20;
x=ones(1,10000);
t=0:1/fs:length(x)/f0;
t=t(1:length(t)-1);%因为从0开始，所以多了一个点，把多出的一个点截掉。
for i = 1:length(x)   


        for j = 1:t0/2    %改码元对应的点值为1    

            y((i-1)*t0+j) = 1;

        for j = t0/2+1:t0    %改码元对应的点值为1    

            y((i-1)*t0+j) = 0;
        end
        end
    

end
end