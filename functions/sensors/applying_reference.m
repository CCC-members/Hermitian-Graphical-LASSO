function [Svv_complex_r,K_r] = applying_reference(Svv_complex,K)
H  = eye(size(Svv_complex,1))-ones(size(Svv_complex,1))/size(Svv_complex,1);
K_r = H*K;
Svv_complex_r = Svv_complex;
Svv_complex_r(:,:) = H*squeeze(Svv_complex(:,:))*H;
Svv_complex_r(:,:) = (Svv_complex_r(:,:) + Svv_complex_r(:,:)')/2;

end