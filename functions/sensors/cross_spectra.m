function [Svv_band,Lvj,PSD,Nseg] = cross_spectra(subject, properties)


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
Lvj     = subject.Headmodel.Ke;
Fs      = properties.samp_freq.value;       % sampling frequency
Fmax    = properties.max_freq.value;        % maximum frequency
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
[Svv_band,Nseg] = xspectrum_band(data, band, Fs, deltaf, varf, Nw);
PSD = [];
disp('-->> Applying average reference.');

[Svv_band(:,:),Lvj] = applying_reference(Svv_band(:,:),Lvj);    % applying average reference...



end