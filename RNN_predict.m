function send_seq_pre=RNN_predict(rcv_seq_pre)
 a=rcv_seq_pre;
 a=fliplr(a);
 data_dim=length(rcv_seq_pre);
 sigmoid=inline('1./(1+exp(-x))');
for position = 0:data_dim-1
%         %X = [a(data_dim - position)-'0' b(data_dim - position)-'0'];   % X 是 input
%           X = a(data_dim - position);
       if (data_dim - position+2)>data_dim
           X = [a(data_dim - position)  0 0];   % X 是 input
       else
           X = [a(data_dim - position)  a(data_dim - position+1) a(data_dim - position+2)];   % X 是 input
       end
%          X =a(position+1);
%         y = c(position+1);
%         
        % 这里是RNN，因此隐含层比较简单
        % X ------------------------> input
        % sunapse_0 ----------------> U_i
        % layer_1_values(end, :) ---> previous hidden layer （S(t-1)）
        % synapse_h ----------------> W_i
        % layer_1 ------------------> new hidden layer (S(t))
        global synapse_0;
        global synapse_1;
        global synapse_h;
        global layer_1_values;
        layer_1 = sigmoid(X*synapse_0 + layer_1_values(end, :)*synapse_h);
        
        % layer_1 ------------------> hidden layer (S(t))
        % layer_2 ------------------> 最终的输出结果，其维度应该与 label (Y) 的维度是一致的
        % 这里的 sigmoid 其实就是一个变换，将 hidden layer (size: 1 x 16) 变换为 1 x 1
        % 有写时候，如果输入与输出不匹配的话，使可以使用 softmax 进行变化的
        % output layer (new binary representation)
        layer_2 = sigmoid(layer_1*synapse_1);
        
        % 计算误差，根据误差进行反向传播
        % layer_2_error ------------> 此次（第 position+1 次的误差）
        % l 是真实结果
        % layer_2 是输出结果
        % layer_2_deltas 输出层的变化结果，使用了反向传播，见那个求导（输出层的输入是 layer_2，那就对输入求导即可，然后乘以误差就可以得到输出的diff）

        
        % decode estimate so we can print it out
        % 就是记录此位置的输出，用于显示结果
        d(data_dim - position) = round(layer_2(1));
        % 记录下此次的隐含层 (S(t))
        % store hidden layer so we can use it in the next timestep
        layer_1_values = [layer_1_values; layer_1];
end
 d=fliplr(d);
 send_seq_pre=d;