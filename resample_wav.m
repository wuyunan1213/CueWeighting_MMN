% Resample *.wav file to desired rate

fname=uigetfile('*.wav');
[orig_sig,orig_fs] = audioread(fname);
fs = input('Desired sampling rate: ');

resampled = resample(orig_sig,fs,orig_fs); % Resampled stimulus has a sampling rate of fs

resampled = resampled/max(abs(resampled)); % makes max amplitude +/-1 so audiowrite doesn't chop it off

fname_resamp=[fname(1:end-4) '_resampled.wav'];
audiowrite(fname_resamp,resampled',fs);

figure
subplot(1,2,1)
Original = orig_sig;
OriginalFFT = abs(fft(Original));
n = length(Original);
freq=orig_fs/n.*(1:n);
omi3=OriginalFFT(1:(n/2));
f=freq(1:(n/2));
plot(f,omi3); 
set(gca,'yscale','log')
set(gca,'xscale','log')
title(fprintf('Original, fs = %d',orig_fs))
ylabel('Magnitude')
xlabel('Frequency')
hold on

subplot(1,2,2)
[babble_new,fs_new] = audioread(fname_resamp);
mFFT = abs(fft(babble_new));
n2 = length(mFFT);
freq_m = fs_new/n2.*(1:n2);
thebabble_new = mFFT(1:(n2/2));
fN=freq_m(1:(n2/2));
plot(fN,thebabble_new,'r');
set(gca,'yscale','log')
set(gca,'xscale','log')
title(fprintf('Resampled, fs = %d',fs))
ylabel('Magnitude')
xlabel('Frequency')
hold off

figure
plot(fN,thebabble_new,'r');
hold on
plot(f,omi3);
% ylim([0 3000])
set(gca,'yscale','log')
set(gca,'xscale','log')
ylabel('Magnitude')
xlabel('Frequency')
legend('Resampled','Original','Location','Best')