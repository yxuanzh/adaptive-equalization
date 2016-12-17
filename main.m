clear all;
close all;
clc;
[send_train,rcv_train]=seq_gen(32770);
 global synapse_0;
 global synapse_1;
 global synapse_h;
 global layer_1_values;
 global noise_rate1;
 global noise_rate2;
 RNN_train(rcv_train([3:32770]),send_train([1:32768]))
 while(1)
     sent_str=input('Please type the massage to be sent:\n','s')
     send_seq=str2bin(sent_str)
     rcv_seq=noisy_channel(send_seq);
     send_seq_pre=RNN_predict(rcv_seq);
     send_seq_pre=send_seq_pre(5:end)       %discard 2 bits
     sendstr_pre=bin2str(send_seq_pre)
     
 end