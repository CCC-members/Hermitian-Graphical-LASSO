function process_error = process_analysis_interface(subject, properties)

process_error = [];

% if(iscell(subject.MEEG.data))
%     subject.MEEG.data = cell2mat(subject.MEEG.data(1,1:end));
% end
bands = properties.spectral_params.frequencies;
for i=1:length(bands)
    band = bands(i);    
    properties.str_band =  strcat( band.name,'_',string(band.f_start),'Hz_',string(band.f_end),'Hz');
    if(band.run)
        %%
        %% Estimating cross-spectra
        %%
        disp(strcat( 'BC-V-->> Sensor level for frequency band: (' , band.name , ') ' , string(band.f_start), 'Hz-->' , string(band.f_end) , 'Hz') );
        
        [subject,properties]    = sensor_level_analysis(band,subject,properties);
        disp('-->> Applying average reference.');
%         %%
%         %% Estimating Activation
%         %%
%         [subject,properties]        = get_activation_priors(subject,properties);
%         [stat,J,T,indms,properties] = activation_level_sssblpp(subject,properties);
%         
%         
%         %%
%         %% Estimating Connectivity
%         %%
%         properties.connectivity_params.hg_lasso_th      = analysis_method.(method_name).hg_lasso_th;
%         [Thetajj,Sjj,Sigmajj]                           = connectivity_level_hg_lasso(subject,properties);
    end
end

end

