%%
% #################### Поиск оптимального FIR фильтра ####################
% 
% Этот файл перебирает все возможные значения и находит 
% FIR фильтр, который лучше других борется с МСИ
% его параметры заданы так, что он обеспечивает требуемые значения 
% подавления в полосе задержания
% Результат работы должен использоваться в файле:

% finding_convolution_RRC_FIR.m

% Исходные значения для фильтра
% All frequency values are in kHz.
Fs    = 144;       % Sampling Frequency
N     = 144;       % Order
Fpass = 11;        % Passband Frequency
Fstop = 13.5;      % Stopband Frequency
Wpass = 0.1;       % Passband Weight
Wstop = 80;        % Stopband Weight
dens  = 16;        % Density Factor


order = [];
F_pass = [];
F_stop = [];
W_pass = [];
value_of_numerator_close_to_zero = [];

for n = 104:8:112
   for f_pass = 15:0.25:15
      for f_stop = f_pass + (3:0.25:6)
          for wpass = 0.1:0.1:1
          
              FIR = Equirippple_Remez_matlab(Fs, n, f_pass, f_stop, ...
                                                wpass, Wstop, dens);
              numerator = FIR.Numerator;
              
              close_to_zero = abs(numerator(n/2 + 9));
              
              if close_to_zero < 0.01        
                order = [order n];
                F_pass = [F_pass f_pass];
                F_stop = [F_stop f_stop];
                W_pass = [W_pass wpass];
                value_of_numerator_close_to_zero = ...
                    [value_of_numerator_close_to_zero close_to_zero];
%                 fvtool(FIR, 'analysis', 'impulse');

%                 result = input('Continue? ', 's');
%                 if result == 'no'
%                     break
%                 end
            end
         end
      end
   end
end

clc;
[val index] = min(value_of_numerator_close_to_zero)
t = 'the smallest one is:'
val
order(index)
F_pass(index)
F_stop(index)
W_pass(index)

FIR = Equirippple_Remez_matlab(Fs, order(index), F_pass(index),...
    F_stop(index), W_pass(index), Wstop, dens);

fvtool(FIR, 'analysis', 'impulse');



