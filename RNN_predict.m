function send_seq_pre=RNN_predict(rcv_seq_pre)
 a=rcv_seq_pre;
 a=fliplr(a);
 data_dim=length(rcv_seq_pre);
 sigmoid=inline('1./(1+exp(-x))');
for position = 0:data_dim-1
%         %X = [a(data_dim - position)-'0' b(data_dim - position)-'0'];   % X �� input
%           X = a(data_dim - position);
       if (data_dim - position+2)>data_dim
           X = [a(data_dim - position)  0 0];   % X �� input
       else
           X = [a(data_dim - position)  a(data_dim - position+1) a(data_dim - position+2)];   % X �� input
       end
%          X =a(position+1);
%         y = c(position+1);
%         
        % ������RNN�����������Ƚϼ�
        % X ------------------------> input
        % sunapse_0 ----------------> U_i
        % layer_1_values(end, :) ---> previous hidden layer ��S(t-1)��
        % synapse_h ----------------> W_i
        % layer_1 ------------------> new hidden layer (S(t))
        global synapse_0;
        global synapse_1;
        global synapse_h;
        global layer_1_values;
        layer_1 = sigmoid(X*synapse_0 + layer_1_values(end, :)*synapse_h);
        
        % layer_1 ------------------> hidden layer (S(t))
        % layer_2 ------------------> ���յ�����������ά��Ӧ���� label (Y) ��ά����һ�µ�
        % ����� sigmoid ��ʵ����һ���任���� hidden layer (size: 1 x 16) �任Ϊ 1 x 1
        % ��дʱ����������������ƥ��Ļ���ʹ����ʹ�� softmax ���б仯��
        % output layer (new binary representation)
        layer_2 = sigmoid(layer_1*synapse_1);
        
        % ���������������з��򴫲�
        % layer_2_error ------------> �˴Σ��� position+1 �ε���
        % l ����ʵ���
        % layer_2 ��������
        % layer_2_deltas �����ı仯�����ʹ���˷��򴫲������Ǹ��󵼣������������� layer_2���ǾͶ������󵼼��ɣ�Ȼ��������Ϳ��Եõ������diff��

        
        % decode estimate so we can print it out
        % ���Ǽ�¼��λ�õ������������ʾ���
        d(data_dim - position) = round(layer_2(1));
        % ��¼�´˴ε������� (S(t))
        % store hidden layer so we can use it in the next timestep
        layer_1_values = [layer_1_values; layer_1];
end
 d=fliplr(d);
 send_seq_pre=d;