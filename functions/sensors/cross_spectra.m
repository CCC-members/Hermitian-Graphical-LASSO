function [Svv,M] = cross_spectra(subject, properties)


% Authors:
% - Deirel Paz Linares
% - Eduardo Gonzalez Moreira
% - Pedro A. Valdes Sosa

% Date: March 16, 2019

% Updates
% - Ariosky Areces Gonzalez

% Date: January 30, 2021

%%
%% Preparing params
%%
data    = subject.MEEG.data;
Fs      = properties.samp_freq.value;       % sampling frequency
deltaf  = properties.freq_resol.value;      % frequency resolution
varf    = properties.freq_gfiltvar.value;   % gaussian filter variance
Nw      = properties.win_order.value;       % Slepian windows
band    = properties.band;

%% estimating cross-spectra...

% Remove fieldtrip path for override functions 
warning off;
rmpath(genpath(fullfile('external/fieldtrip')));
warning on;
% estimates the Cross Spectrum of the input M/EEG data
Svv = zeros(size(data{1},1));
M   = 0;
for seg = 1:length(data)
    data_seg        = data{seg};
    [Svv_seg,M_seg] = xspectrum_band(data_seg, band, Fs, deltaf, varf, Nw);
    Svv             = Svv + Svv_seg;
    M               = M + M_seg;
end




end