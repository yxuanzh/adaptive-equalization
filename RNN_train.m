function []=RNN_train(rcv_seq,send_seq)
%%parameter rcv_seq and send_seq should be string type
% implementation of RNN 
% clc
% clear
% clc
% close all

%%function defination
sigmoid=inline('1./(1+exp(-x))');
sigmoid_output_to_derivative=inline('x.*(1-x)');
%% training dataset generation
len=length(rcv_seq);
data_dim = 128;
train_sample=ceil(len/data_dim);
% largest_number = 2^data_dim-1;
% binary = cell(largest_number,1);
% int2binary = cell(largest_number,1);
% for i = 1:largest_number+1
%     binary{i} = dec2bin(i-1, data_dim);
%     int2binary{i} = binary{i};
% end

%% input variables
alpha0 = 0.03;
input_dim = 3;
hidden_dim = 16;
output_dim = 1;
err_plot=[];

%% initialize neural network weights
global synapse_0;
global synapse_1;
global synapse_h;
synapse_0 = randn(input_dim,hidden_dim);
synapse_1 = randn(hidden_dim,output_dim);
synapse_h = randn(hidden_dim,hidden_dim) ;

synapse_0_update = zeros(size(synapse_0));
synapse_1_update = zeros(size(synapse_1));
synapse_h_update = zeros(size(synapse_h));

%% train logic
 for j = 0:(train_sample-1)
     adjustive_rate=j/(train_sample-1);
     alpha=(1-adjustive_rate)*alpha0+adjustive_rate*0.01*alpha0;
%     % generate a simple addition problem (a + b = c)
%     a_int = randi(round(largest_number/2)); % int version
%     a = int2binary{a_int+1}; % binary encoding
      a=rcv_seq(j*data_dim+1:(j*data_dim+data_dim));
      a=fliplr(a);
%     
%     b_int = randi(floor(largest_number/2)); % int version
%     b = int2binary{b_int+1}; % binary encoding
%     
%     % true answer
%     c_int = a_int + b_int;
%     c = int2binary{c_int+1};
      c=send_seq(j*data_dim+1:(j*data_dim+data_dim));
      c=fliplr(c);

    
    overallError = 0;
    
    layer_2_deltas = [];
    global layer_1_values;
    layer_1_values = [];
    layer_1_values = [layer_1_values; zeros(1, hidden_dim)];
    
    % ��ʼ��һ�����н��д��������һ��������һ��LSTM��Ԫ�������ʵ����������
     for position = 0:data_dim-1
%         %X = [a(data_dim - position)-'0' b(data_dim - position)-'0'];   % X �� input
%           X = a(data_dim - position);
       if (data_dim - position+2)>data_dim
           X = [a(data_dim - position)  0 0];   % X �� input
       else
           X = [a(data_dim - position)  a(data_dim - position+1) a(data_dim - position+2)];   % X �� input
       end
%          X =a(position+1);
          y = c(data_dim - position);                               % Y ��label����������������
%         y = c(position+1);
%         
        % ������RNN�����������Ƚϼ�
        % X ------------------------> input
        % sunapse_0 ----------------> U_i
        % layer_1_values(end, :) ---> previous hidden layer ��S(t-1)��
        % synapse_h ----------------> W_i
        % layer_1 ------------------> new hidden layer (S(t))
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
        % did we miss?... if so, by how much?
        layer_2_error = y - layer_2;
        layer_2_deltas = [layer_2_deltas; layer_2_error*sigmoid_output_to_derivative(layer_2)];
        
        % ���������������и����þ���ֵ��
        overallError = overallError + abs(layer_2_error(1));
        
        % decode estimate so we can print it out
        % ���Ǽ�¼��λ�õ������������ʾ���
        d(data_dim - position) = round(layer_2(1));
        
        % ��¼�´˴ε������� (S(t))
        % store hidden layer so we can use it in the next timestep
        layer_1_values = [layer_1_values; layer_1];
    end
    
    % �����������diff������������ı仯�����������²���������ÿһ��timestep�����м���
    future_layer_1_delta = zeros(1, hidden_dim);
    
    % ��ʼ���з��򴫲������� hidden_layer ��diff���Լ������� diff
    for position = 0:data_dim-1
        % ��Ϊ��ͨ������õ������㣬������ﻹ����Ҫ�õ������
        % a -> (operation) -> y, x_diff = derivative(x) * y_diff
        % ע����������ʼ��ǰ��
        %X = [a(position+1)-'0' b(position+1)-'0'];
%         X = a(position+1);
        if (position+3)>data_dim
            X=[a(position+1) 0 0];
        else
            X = [a(position+1) a(position+2) a(position+3)];
        end

        %X = a(position+1)-'0';
        % layer_1 -----------------> ��ʾ������ hidden_layer (S(t))
        % prev_layer_1 ------------> (S(t-1))
        layer_1 = layer_1_values(end-position, :);
        prev_layer_1 = layer_1_values(end-position-1, :);
        
        % layer_2_delta -----------> �����������diff
        % hidden_layer_diff,��������������������diff�Լ���һ���������diff
        % error at output layer
        layer_2_delta = layer_2_deltas(end-position, :);
        % ����ط��� hidden_layer �����������棬��Ϊ hidden_layer -> next timestep, hidden_layer -> output��
        % ����䷴�򴫲�Ҳ��������
        % error at hidden layer
        layer_1_delta = (future_layer_1_delta*(synapse_h') + layer_2_delta*(synapse_1')) ...
                        .* sigmoid_output_to_derivative(layer_1);
        
        % let's update all our weights so we can try again
        synapse_1_update = synapse_1_update + (layer_1')*(layer_2_delta);
        synapse_h_update = synapse_h_update + (prev_layer_1')*(layer_1_delta);
        synapse_0_update = synapse_0_update + (X')*(layer_1_delta);
        
        future_layer_1_delta = layer_1_delta;
    end
    
    synapse_0 = synapse_0 + synapse_0_update * alpha;
    synapse_1 = synapse_1 + synapse_1_update * alpha;
    synapse_h = synapse_h + synapse_h_update * alpha;
    
    synapse_0_update = synapse_0_update * 0;
    synapse_1_update = synapse_1_update * 0;
    synapse_h_update = synapse_h_update * 0;
    
    if(mod(j,20) == 0)
%         err = sprintf('Error:%s\n', num2str(overallError)); fprintf(err);
%         d = bin2dec(num2str(d));
%         pred = sprintf('Pred:%s\n',dec2bin(d,data_dim)); fprintf(pred);
%         Tru = sprintf('True:%s\n', num2str(c)); fprintf(Tru);
%         out = 0;
%         size(c)
%         sep = sprintf('-------------\n'); fprintf(sep);
        err_plot=[err_plot,overallError];
        err = sprintf('Error:%d\n', overallError); fprintf(err);
        pred = sprintf('Pred:%s\n',num2str(d)); fprintf(pred);
        Tru = sprintf('True:%s\n', num2str(c)); fprintf(Tru);
        out = 0;
        size(c)
        sep = sprintf('-------------\n'); fprintf(sep);
    end
    plot(err_plot);
    xlabel('iteration');
    ylabel('cost');
    
    
end


