function [dataEnv] = envelope_data(data,Fs,deltat,varargin)

for i=1:2:length(varargin)
    eval([varargin{i} '=  varargin{(i+1)};'])
end

if(~exist('use_gpu','var'))
    use_gpu = false;
end

if(~exist('use_seg','var'))
    use_seg = false;
end

[Nc,Nt,Nw]                     = size(data);                   % Nc: number of channels,Nt_deg: length of segments, Nseg: number of segments
if(use_gpu)
    dataEnv = gpuArray(zeros(Nc,Nt,Nw));
else
    dataEnv = zeros(Nc,Nt,Nw);
end
Settings.EnvelopeParams.takeLogs     = false;                        % perform analysis on logarithm of envelope. This improves normality assumption
Settings.EnvelopeParams.absolute     = false;                        % absolute power envelope
Settings.EnvelopeParams.downsample   = false;                        % downsample signal for envelope calculation
Settings.EnvelopeParams.saveMemory   = true;                         % save memory
Settings.EnvelopeParams.windowLength = deltat;                       % sliding window length for power envelope calculation. See Brookes 2011, 2012 and Luckhoo 2012.
Settings.EnvelopeParams.useFilter    = false;                        % use a more sophisticated filter than a sliding window average

if (use_seg)
    time_span = 0:(1/Fs):Nt*(1/Fs);
    for window = 1:Nw
        if use_gpu
            [dataEnv(:,:,window), ~, ~] = ROInets.envelope_data(gpuArray(squeeze(data(:,:,window))),time_span,Settings.EnvelopeParams);
        else
            [dataEnv(:,:,window), ~, ~] = ROInets.envelope_data(squeeze(data(:,:,window)),time_span,Settings.EnvelopeParams);
        end
    end
else
    time_span = 0:(1/Fs):Nt*Nw*(1/Fs);
    if use_gpu
        [dataEnv, ~, ~] = ROInets.envelope_data(gpuArray(reshape(data,Nc,Nt*Nw)),time_span,Settings.EnvelopeParams);
    else
        [dataEnv, ~, ~] = ROInets.envelope_data(reshape(data,Nc,Nt*Nw),time_span,Settings.EnvelopeParams);
    end
    data_Env            = reshape(dataEnv,Nc,Nt,Nw);
end
end
