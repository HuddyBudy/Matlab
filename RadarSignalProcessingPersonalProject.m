%% Radar Signal Processing Personal project
Print(' Please know what you are doing, I put unrealistic numbers and my computer froze')

% Radar Parmeters
c = 3e8;           % Speed of light (m/s)
fc = input('Enter your Carrier frequency in Hz ');           % Carrier frequency (Hz)
PRF = input('Enter your Pulse repetition frequency in Hz '); % Pulse repetition frequency (Hz)
Tp = input('Enter your Pulse width in seconds ');            % Pulse width (s)
B = input('Enter your Bandwidth in Hz ');          % Bandwidth (Hz)
fs = 2 * B;        % Sampling frequency (Hz)

t = 0:1/fs:Tp-1/fs; % Time vector for one pulse
chirp_signal = exp(1j * pi * (B/Tp) * t.^2); % LFM chirp


R = input('Enter your target range in meters: ');          % Target range (m)
v = input('Enter your target velocity in meters per second: ');            % Target velocity (m/s)
tau = 2 * R / c;   % Time delay (s)
fd = 2 * v * fc / c; % Doppler frequency (Hz)


t_received = 0:1/fs:(Tp + tau)-1/fs; % Time vector for received signal This part gave me trouble
received_signal = exp(1j * pi * (B/Tp) * (t_received - tau).^2) .* exp(1j * 2 * pi * fd * t_received);
received_signal = awgn(received_signal, input('Enter your noise in decibels ')); % Add noise (SNR = 20 dB)



matched_filter = conj(fliplr(chirp_signal)); % Matched filter
output_signal = conv(received_signal, matched_filter, 'same'); % Convolution


N = length(output_signal); % Number of samples
f = (-fs/2:fs/N:fs/2-fs/N); % Frequency vector
doppler_spectrum = fftshift(fft(output_signal)); % FFT
[~, doppler_index] = max(abs(doppler_spectrum));
doppler_frequency = f(doppler_index); % Doppler frequency
velocity_estimate = doppler_frequency * c / (2 * fc); % Estimated velocity


% Ploting
N = length(output_signal); % Number of samples in outtput signal
f = (-fs/2:fs/N:fs/2-fs/N); % Frequency vector
doppler_spectrum = fftshift(fft(output_signal)); % FFT
[~, doppler_index] = max(abs(doppler_spectrum));
doppler_frequency = f(doppler_index); % Doppler frequency
velocity_estimate = doppler_frequency * c / (2 * fc); % Estimated velocity

% Matched Filter Output plot
figure;
plot(abs(output_signal))
title('Matched Filter Output')
xlabel('Samples');
ylabel('Amplitude');

% figure;
plot(f, abs(doppler_spectrum))
title('Doppler Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');