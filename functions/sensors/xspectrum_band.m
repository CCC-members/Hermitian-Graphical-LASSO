function [Svv,M] = xspectrum_band(data, band, Fs, deltaf, varf, Nw)
% xspectrum estimates the Cross Spectrum of the input M/EEG data by Hilbert Transform
%%
% =============================================================================
% This function is part of the BC-VARETA toolbox:
% https://github.com/CCC-members/BC-VARETA_Toolbox
% =============================================================================@
%
%% Authors:
%   Pedro A. Valdes-Sosa, 2010-2021
%   Alberto Taboada-Crispi, 2016
%   Deirel Paz-Linares, 2017-2021
%   Eduardo Gonzalez-Moreira, 2017-2018
%   Ariosky Areces-Gonzalez, 2018-2021
%
%
%% Inputs:
%    data     = M/EEG data matrix, in which every row is a channel
%    Fs       = sampling frequency (in Hz)
%    Fm       = maximun frequency (in Hz) in the estimated spectrum
%    deltaf   = frequency resolution
%    use_gpu  = key:'use_gpu' value: true or false
%% Outputs:
%    PSD      = estimated power spectral density of input EEG data
%    Svv      = estimated cross spectrum of input EEG data
%    Ns       = number of segments in which the EEG signal is wrapped
%    Svv      =
%
%
%**************************************************************************
%% Initialization oF variables...
use_seg     = true;
[Nc,Nt]     = size(data);

deltat      = 1/(2*varf); % sliding window for hilbert envelope (adjusted by the response of the gaussian filter)
data        = repmat(data,1,1,2*Nw);
e           = dpss(Nt,Nw); % discrete prolate spheroidal (Slepian) sequences
e           = reshape(e,[1,Nt,2*Nw]);
e           = repmat(e,Nc,1,1);
data        = data.*e;
M           = 2*Nw*Nt; % sample number
Svv         = zeros(Nc,Nc);

use_gpu     = false;
if(use_gpu)
    Svv_gpu = gpuArray(Svv);
end
%% Estimation of the Cross Spectrum...
if(use_gpu)
    dataFFT = gather(fft(gpuArray(data),[],2));
else
    dataFFT = fft(data,[],2);
end
dataFilt            = filt_data_band(dataFFT,Fs,band.f_start,band.f_end,varf,'use_gpu',use_gpu);
dataEnv             = envelope_data(dataFilt,Fs,deltat,'use_seg',use_seg,'use_gpu',use_gpu);
clearvars deltaFilt;
if(use_gpu)
    dataEnv         = reshape(dataEnv,Nc,Nt*2*Nw).';
    Svv_gpu(:,:)    = cov(dataEnv);
    Svv_gpu(:,:)    = (Svv_gpu(:,:) + Svv_gpu(:,:)')/2;
else
    dataEnv         = reshape(dataEnv,Nc,Nt*2*Nw).';
    Svv(:,:)        = cov(dataEnv);
    Svv(:,:)        = (Svv(:,:) + Svv(:,:)')/2;
end
clearvars dataEnv;
if(use_gpu)
    Svv = gather(Svv_gpu);
end

end