function rcv_seq=noisy_channel(send_seq)
send_seq=[0,0,send_seq,0,0];
len=length(send_seq);
global noise_rate1;
global noise_rate2;
a1=0;
a2=0;
a3=noise_rate2*rand(1,1);

%%generate rcv_seq section
rcv_seq(1)=0;
rcv_seq(2)=0;
for i=3:len
    a1=noise_rate1*sin(5i);
    a2=noise_rate1*cos(5i);
%     a1=3;
%     a2=3;
    rcv_seq(i)=send_seq(i)+a1*send_seq(i-1)+a2*send_seq(i-2)+a3;
end   
end