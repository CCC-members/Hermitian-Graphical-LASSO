function dataFilt = filt_data_band(W,Fs,Fmin,Fmax,var,varargin)
%   FILT_DATA Summary of this function goes here
% 'FourierCoefficients',W,'Fs',Fs,'Freq',F(freq),'varf',varf,'use_gpu',use_gpu
%
for i=1:2:length(varargin)
    eval([varargin{i} '=  varargin{(i+1)};'])
end

if(~exist('use_gpu','var'))
    use_gpu = false;
end
Nf                     = size(W,2);
deltaf                 = Fs/Nf;
F                      = 0:deltaf:(Nf-1)*deltaf;
[~,Imin]               = min(abs(F-Fmin));
Fmin                   = F(Imin);
[~,Imax]               = min(abs(F-Fmax));
Fmax                   = F(Imax);
band                   = Imin:Imax;
band_window            = exp(-(F-Fmin).^2/(2*var^2)) + exp(-(F-Fmax).^2/(2*var^2));
band_window(band)      = 1;
band_window            = band_window + flip(band_window,2);
band_window            = band_window/sum(band_window);
if (use_gpu)
    W               = gpuArray(W).*repmat(gpuArray(band_window),size(W,1),1,size(W,3));
    dataFilt        = ifft(W,[],2,'symmetric');
    dataFilt        = gather(dataFilt(:,1:Nf,:));
else
    W               = W.*repmat(band_window,size(W,1),1,size(W,3));
    dataFilt        = ifft(W,[],2,'symmetric');
end
end
