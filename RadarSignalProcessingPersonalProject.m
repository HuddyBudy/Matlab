% Underwater Sonar Signal Processing

% Input Sonar parameters
fc = input(' Enter the carrier frequency in Hz ( Like 10000 ): ');
PRF = input('Enter the pulse repetition frequency in Hz ( Like 100 ): '); 
PluseWidth = input('Enter the pulse width in seconds ( Like 0.01 s) : '); 
Bandwith = input(' Enter the bandwidth in Hz ( Like 1000 ): '); 
Range = input(' Enter the target range in meters ( Like 500 ): '); 
velocity = input(' Enter the target velocity in meters per second ( like 10) : '); 
c = 1500; % Speed of sound in water (m/s)

% Regular Sonar parameters

% fc = 10000;
% PRF = 100; 
% PluseWidth = 0.01
% Bandwith = 1000
% Range = 500;
% velocity = 10;


% Generate transmitted chirp signal
SamplingFreq = 2 * Bandwith; % Sampling frequency
time = 0:1/SamplingFreq:PluseWidth-1/SamplingFreq; % Time vector for one pulse
chirp_signal = exp(1j * pi * (Bandwith/PluseWidth) * time.^2); % LFM chirp

% Simulate target reflection
Tau = 2 * Range / c; % Time delay
DopplerFreq = 2 * velocity * fc / c; % Doppler frequency
TReceived = 0:1/SamplingFreq:(PluseWidth + Tau)-1/SamplingFreq; % Time vector for received signal
RSignal = exp(1j * pi * (Bandwith/PluseWidth) * (TReceived - Tau).^2) .* exp(1j * 2 * pi * DopplerFreq * TReceived);

% Add noise and attenuation to simulate underwater conditions
RSignal = awgn(RSignal, 20); % Add noise (SNR = 20 dB)
attenuation = 0.9; % Simulate signal attenuation in water
RSignal = attenuation * RSignal;

% Matched filtering
matched_filter = conj(fliplr(chirp_signal)); % Matched filter
output_signal = conv(RSignal, matched_filter, 'same'); % Convolution

% Range detection
[~, peak_index] = max(abs(output_signal));
range_estimate = (peak_index / SamplingFreq) * c / 2; % Estimated range

% Doppler processing
N = length(output_signal); % Number of samples
f = (-SamplingFreq/2:SamplingFreq/N:SamplingFreq/2-SamplingFreq/N); % Frequency vector
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
plot(time, real(chirp_signal))
title('Transmitted Chirp Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,1,2);
plot(TReceived, real(RSignal))
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
