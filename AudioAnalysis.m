%% Reading in the audio file, selecting a window and plotting the spectrogram of the audio

clear all;

[y , Fs] = audioread('ghost.wav');


windowsize = 2049;
win = window(@hanning, windowsize);

[S F T] = spectrogram(y, win, (windowsize - 1)/2 , windowsize - 1, Fs);
figure
imagesc(T, F, log10(abs(S)));

axis xy;
xlabel('time (s)');
ylabel('frequency (Hz)');
colormap bone;

%% Designing a band pass filter with pass band between 4.5 and 5.4 kHz and 60 dB attenuation

Wn = [4500 5200]./(Fs/2);
B = fir1(101, Wn, 'bandpass');

%% Applying bandpass filter to signal

yp = filter(B, 1, y);

[Sp F T] = spectrogram(yp, win, (windowsize - 1)/2 , windowsize - 1, Fs);

figure

imagesc(T, F, log10(abs(Sp)));

axis xy;
xlabel('time (s)');
ylabel('frequency (Hz)');
colormap bone; 

%% Modulating yp by a sinusoid of 5000 Hz 

ypm = yp.*cos(2*pi*5000*[0:length(yp) - 1]'/Fs);

[Spm F T] = spectrogram(ypm, win, (windowsize - 1)/2 , windowsize - 1, Fs);

figure

imagesc(T, F, log10(abs(Spm)));
axis xy;
xlabel('time (s)');
ylabel('frequency (Hz)');
colormap bone;

%% Applying a bandpass filter again to the modulated signal where audio content is present

Wnn = [0.001 300]./(Fs/2);
BB = fir1(5001, Wnn, 'bandpass');

ypmfiltered = filter(BB, 1, ypm);

[Spmfiltered F T] = spectrogram(ypmfiltered, win, (windowsize - 1)/2 , windowsize - 1, Fs);

figure

imagesc(T, F, log10(abs(Spmfiltered)));
axis xy;
xlabel('time (s)');
ylabel('frequency (Hz)');
colormap bone;
sound(5000*flipud(ypmfiltered(500:end)), 2*Fs)

%% Calculating the FFT, flipping the vector holding the audio, and calculating the inverse FFT to get the original signal

FF = fft(flipud(ypmfiltered(500:end)));
F1 = FF(1:end/2);
F2 = FF(end/2+1:end);
F1 = circshift(F1,100);
F2 = circshift(F2,-100);
FFt= [F1;F2];
YF = ifft(FFt);

sound(real(5000*YF),2*Fs);
