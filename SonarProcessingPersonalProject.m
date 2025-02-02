% Underwater Sonar Signal Processing

% Sonar parameters
fc = input(' Enter the carrier frequency in Hz ( Like 10000 ): ');
PRF = input(' Enter the pulse repetition frequency in Hz ( Like 100 ): '); 
PluseWidth = input('Enter the pulse width in seconds ( Like 0.01 s) : '); 
Bandwith = input('Enter the bandwidth in Hz ( Like 1000 ): '); 
Range = input('Enter the target range in meters ( Like 500 ): '); 
velocity = input('Enter the target velocity in meters per second ( like 10) : '); 
c = 1500; % Speed of sound in water (m/s)

% Generate transmitted chirp signal
fs = 2 * Bandwith; % Sampling frequency
t = 0:1/fs:PluseWidth-1/fs; % Time vector for one pulse
chirp_signal = exp(1j * pi * (Bandwith/PluseWidth) * t.^2); % LFM chirp

% Simulate target reflection
tau = 2 * Range / c; % Time delay
fd = 2 * velocity * fc / c; % Doppler frequency
t_received = 0:1/fs:(PluseWidth + tau)-1/fs; % Time vector for received signal
received_signal = exp(1j * pi * (Bandwith/PluseWidth) * (t_received - tau).^2) .* exp(1j * 2 * pi * fd * t_received);

% Add noise and attenuation to simulate underwater conditions
received_signal = awgn(received_signal, 20); % Add noise (SNR = 20 dB)
attenuation = 0.9; % Simulate signal attenuation in water
received_signal = attenuation * received_signal;

% Matched filtering
matched_filter = conj(fliplr(chirp_signal)); % Matched filter
output_signal = conv(received_signal, matched_filter, 'same'); % Convolution

% Range detection
[~, peak_index] = max(abs(output_signal));
range_estimate = (peak_index / fs) * c / 2; % Estimated range

% Doppler processing
N = length(output_signal); % Number of samples
f = (-fs/2:fs/N:fs/2-fs/N); % Frequency vector
doppler_spectrum = fftshift(fft(output_signal)); % FFT
[~, doppler_index] = max(abs(doppler_spectrum));
doppler_frequency = f(doppler_index); % Doppler frequency
velocity_estimate = doppler_frequency * c / (2 * fc); % Estimated velocity

% Display results
disp(['Estimated range: ', num2str(range_estimate), ' meters']);
disp(['Estimated velocity: ', num2str(velocity_estimate), ' m/s']);

% Visualization
figure;
subplot(2,1,1);
plot(t, real(chirp_signal))
title('Transmitted Chirp Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,1,2);
plot(t_received, real(received_signal))
title('Received Signal (with noise and attenuation)');
xlabel('Time (s)');
ylabel('Amplitude');

figure;
plot(abs(output_signal))
title('Matched Filter Output');
xlabel('Samples');
ylabel('Amplitude');

figure;
plot(f, abs(doppler_spectrum))
title('Doppler Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');