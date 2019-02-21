function Testing_quantizing()
% ������ ������� ������������ ��������
% ������������ ����� ������� �������� � ��������� ������
% ��������������� ������� RRC �� ������ � �������� + FIR ��� ����������

% ������� �������
[rcrFilt, rcrFilt2, Initial_FIR, Initial_FIR2, Nrrc, Nfir] = initialize_floating_filters();

% ��������� ��������� ��������������� ������������������ ��� repeatability
hStr = RandStream('mt19937ar', 'Seed', 0);

dqpskmod    = comm.DQPSKModulator(pi/4, 'BitInput', true);
dqpskdemod  = comm.DQPSKDemodulator('BitOutput', true);
cd = comm.ConstellationDiagram('ShowTrajectory',false,'ShowReferenceConstellation',false);

% ����� ������������ ������
% ���� �� ��������, ������ ��� � ������� ����������
% ����� �������� �����������(��� ������� ������������ ���� �������)
dataL = 1000;

% ������ �������� ������� ��� �����������
d = grpdelay(rcrFilt, 20);                   
D = grpdelay(Initial_FIR)/8 + d(10)/4 + 1;

% ������� ����������� �������� �������� ������� ��� ���������������
% ��������� ������� ��� ��������� � ��������
g = testing_filters();

% ���������� � ���������� �������� ������ ����� �������
[err_v, peak_v]  = rx_tx(Nrrc, Nfir);

% ����������� � ������� ��� �������
[ach1, ach2, ach3] = achh();

% ������ ���������� ������������
if err_v < 2
    if ach1 < -64 && ach2 < -85 && ach3 < 120
        print = "���������� ������������ ���������";
    else
        print = "���������� ������������ �� ���������";
    end
end

s1 = "������� �������� ������� ������(��������): ";
s2 = "������� �������� ������� ������(��������): ";
s3 = "������� ��������� ������� � 1 �������� ������(��): "
s4 = "������� ��������� ������� � 2 �������� ������(��): "
s5 = "������� ��������� ������� � 3 �������� ������(��): "

fprintf("%s \n%s %f \n%s %f \n%s %f \n%s %f \n%s %f \n" , ...
    print , s1, err_v, s2, peak_v, s3, ach1, s4, ach2, s5, ach3);

    function [diff_max_percents, peak_val] = rx_tx(Nr, Nf)
        % �������� ����������� ���������� ������� ����� �������
        % ���������� ��������� ����������� � ��������� ��������
        % �������� ����������� ������� �� ������������� ������
        % �������� ����������� ����������� ���������
        
        Fs = 36e3;
        Ts = 1/Fs;

        dataL = 1000;
        T = (dataL-1)*Ts;

        initial_bits = randi(hStr, [0 1], dataL, 1);
        t = linspace(0,T, dataL);

        mod_bits = dqpskmod(initial_bits);
        t_mod = linspace(0,T, dataL/2);

        up_mod_bits = upsample(mod_bits, 8, 0);
        rrc = filter(rcrFilt.Numerator, 1, up_mod_bits);
        t_ups = linspace(0,T, dataL*4);
        
        fir = filter(Initial_FIR.Numerator, 1, rrc);

        down = filter(rcrFilt.Numerator, 1, fir);

        offset = 0;
        dec = downsample(down, 8, offset);
        
        delayed = dec(D:end)'./g;
        t_d = t_mod(D:end);

        diff = mod_bits(1:end - D + 1)' - delayed;
        
        diff_max_percents =  rms(abs(diff))*100;
        peak_val = max(abs(diff))*100;
        
        figure;
        plot_stem();
        
        function plot_stem()
            % ��������� ������������� � �������� �����������
            
            ax1 = subplot(6,1,1);
            stem(ax1, t_mod, real(mod_bits)');
            title('������������ Q ����������');
            
            ax2 = subplot(6,1,2);
            plot(ax2, t_ups, real(rrc)');
            title('��������������� RRC � ������� Q ����������');
            
            ax3 = subplot(6,1,3);
            plot(ax3, t_ups, real(fir)');
            title('��������������� �� FIR Q ����������');
            
            ax4 = subplot(6,1,4);
            stem(ax4, t_mod, real(dec)');
            title('��������������� �� �������� RRC Q ����������');

            ax5 = subplot(6,1,5);
            stem(ax5, t_d, real(delayed)');
            title('��������� ��������');
            
            ax6 = subplot(6,1,6);
            stem(ax6, t_d, abs(diff));
            title('������ ������ ������� ������');   
            
            cd(delayed');
        end
    end

    function [av1, av2, av3] = achh()
        % ����������� ���������� ��� ��������
        % avX - ������� ��������� � �� ������
        % �������� ��������������� �������� ���� �������
        
        Fs = 144e3;
        L  = dataL;

        delta =  [1; zeros(dataL - 1,1)];

        pr = filter(Initial_FIR2.Numerator, 1, delta);
%         pr = Initial_FIR2(delta);
        
        impulse = filter(rcrFilt2.Numerator, 1, pr);
%         impulse = rcrFilt2(pr);

        Y = fft(impulse);
        P2 = abs(Y/L);
        P1 = P2(1:L/2 + 1);
        P1 = P1./P1(1);
            f = Fs*(0:(L/2))/L;
        
        av1 = 20*log10(mean(P1(112:238)));
        av2 = 20*log10(mean(P1(285:411)));
        av3 = 20*log10(mean(P1(487:501)));
       
        plot_achh(); 
        
        function plot_achh()
            % ����������� ���
            
            P = 20*log10(P1); 
            f = Fs*(0:(L/2))/L;
            figure;
            plot(f, P);
            title('Frequency response');
            xlabel('Frequency');
            ylabel('Amplitude dB');
        end
    end

    function [rcrFilt, rcrFilt2, Initial_FIR, Initial_FIR2, Nrrc, Nfir] = initialize_floating_filters()  
        % ������� �������, � �������� ��������
        
        % RRC
        Fs   = 144;        % Sampling Frequency
        Nrrc = 64;         % Order
        Fc   = 9;          % Cutoff Frequency
        TM   = 'Rolloff';  % Transition Mode
        R    = 0.35;       % Rolloff
        DT   = 'sqrt';     % Design Type
        Beta = 0.5;        % Window Parameter
        Word_len = 16;
        Fraction_len = 15;

        rcrFilt = RRC_quantized(Fs, Nrrc, Fc, TM, R, DT, ...
            Beta, Word_len, Fraction_len);
        rcrFilt2 = RRC_quantized(Fs, Nrrc, Fc, TM, R, DT, ...
            Beta, Word_len, Fraction_len);
        
        % FIR
        % All frequency values are in kHz.
        Nfir  = 64;        % Order              
        Fpass = 13;        % Passband Frequency 18
        Fstop = 19;        % Stopband Frequency 28
        Wpass = 0.5;       % Passband Weight
        Wstop = 40;        % Stopband Weight
        dens  = 16;        % Density Factor
%         Word_len = 16;
%         Fraction_len = 15;

        Initial_FIR = Equirippple_Remez_quantized(Fs, Nfir, Fpass, ...
            Fstop, Wpass, Wstop, dens, Word_len, Fraction_len);
        Initial_FIR2 = Equirippple_Remez_quantized(Fs, Nfir, Fpass, ... 
            Fstop, Wpass, Wstop, dens, Word_len, Fraction_len);
        
    end

    function K = testing_filters()
        % ������� ����������� �������� ������� �� ���� ��������
        
        Fs = 144e3;
        L  = dataL;

        delta =  [1; zeros(dataL - 1,1)];

        prr = filter(rcrFilt2.Numerator, 1, delta);
        pr = filter(Initial_FIR2.Numerator, 1, prr);  
        impulse = filter(rcrFilt2.Numerator, 1, pr);

        K = max(real(impulse));

    end

end


