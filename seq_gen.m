function [send_seq,rcv_seq]=seq_gen(len)

%%generate send-seq
p=0.5;
send_seq=rand(len,1);
send_seq=send_seq<p;
%send_seq=2*send_seq-1;
send_seq=send_seq';
%%para init
global noise_rate1;
global noise_rate2;
noise_rate1=5;   % 500% fluctuation
noise_rate2=0.25;   % 25% fluctuation
%noise_rate1=0.1;     % 10% fluctuation
%noise_rate2=0.1;     % 10% fluctuation
% a1=0;
% a2=0;
a3=noise_rate2*randn(1,1);

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