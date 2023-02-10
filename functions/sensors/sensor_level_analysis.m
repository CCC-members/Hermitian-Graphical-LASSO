function [subject,properties] = sensor_level_analysis(band,subject,properties)

disp('=================================================================');

text_level      = 'Sensor_level';

%%
%% Preparing params
%%
Lvj           = subject.Headmodel.Ke;
Cdata        = subject.Cdata;
Sh           = subject.Shead;
cmap_a       = properties.cmap_a;
cmap_c       = properties.cmap_c;
str_band     = properties.str_band;

%%
%%
%%
disp('BC-V-->> Estimating cross-spectra for M/EEG data.');
spectral_prop           = properties.spectral_params;
spectral_prop.band      = band;
[Svv,M]                 = cross_spectra(subject, spectral_prop);
properties.sensor_level_out.M = M;
properties.sensor_level_out.Svv = Svv;

%%
%%
%%
disp('-->> Applying average reference.');
[Svv(:,:),Lvj] = applying_reference(Svv(:,:),Lvj);    % applying average reference...

%% Adding fieltrip external functions
f_path          = mfilename('fullpath');
[ref_path,~,~]  = fileparts(fileparts(fileparts(f_path)));
addpath(genpath(fullfile(ref_path,'external/fieldtrip')));
ft_defaults

%%
%% Test
%%

figure_name = strcat('Scalp 2D - ',str_band);
if(properties.run_bash_mode.disabled_graphics)
    figure_scalp_2D = figure('Color','w','Name',figure_name,'NumberTitle','off','visible','off'); hold on; set(gca,'Color','w');
else
    figure_scalp_2D = figure('Color','w','Name',figure_name,'NumberTitle','off'); hold on; set(gca,'Color','w');
end
define_ico(figure_scalp_2D);

Channel          = Cdata.Channel;
%%
elec_data               = [];
elec_data.pos           = zeros(length(Channel),3);
for ii = 1:length(Channel)
    elec_data.lbl{ii}   = Channel(ii).Name;
    temp                = Channel(ii).Loc;
    elec_data.pos(ii,:) = mean(temp,2);
end
elec_data.label         = elec_data.lbl;
elec_data.elecpos       = elec_data.pos;
elec_data.unit          = 'mm';


temp    = diag(Svv);
temp    = abs(temp)/max(abs(temp(:)));
cfg     = [];
topo    = [];
if(isequal(subject.modality,'MEG'))
    %% MEG topography
    if(isequal(properties.general_params.fieldtrip.layout.value,'4D248_helmet.mat'))
        cfg.layout          = properties.general_params.fieldtrip.layout.value;
        cfg.channel         = 'meg';
        cfg.markers         = '.';
        cfg.markersymbol    = '.';
        cfg.colormap        = cmap_a;
        cfg.markersize      = 3;
        cfg.markercolor     = [1 1 1];
    elseif(isequal(properties.general_params.fieldtrip.layout.value,'4D248_helmet.mat'))
        
    end
    topo.sens           = elec_data;
    topo.tra            = elec_data.pos;
    topo.coilpos        = elec_data.pos;
    topo.label          = elec_data.lbl';
    topo.dimord         = 'chan_freq';
    topo.freq           = 1;
    topo.powspctrm      = temp;    
else
    %% EEG topography
    cfg.marker          = '';
    cfg.layout          = properties.general_params.fieldtrip.layout.value;   
    cfg.channel         = 'eeg';
    cfg.markersymbol    = '.';
    cfg.colormap        = cmap_a;
    cfg.markersize      = 3;
    cfg.markercolor     = [1 1 1];
    topo.elec           = elec_data;
    topo.label          = elec_data.lbl;
    topo.dimord         = 'chan_freq';
    topo.freq           = 1;
    topo.powspctrm      = temp;
end

ft_topoplotTFR(cfg,topo);
title(['MEG' ' ' band.name ' ' 'topography'])

disp('-->> Saving figure');
file_name = strcat('Scalp_2D','_',str_band,'.fig');
saveas(figure_scalp_2D,fullfile(subject.subject_path,file_name));

close(figure_scalp_2D);

%%
%%
%%
%%


%%
%% topography...
%%
Nelec = size(Lvj,1);
Svv_inv = sqrtm(Svv*Svv+4*eye(Nelec))-Svv;
Loc = [Cdata.Channel.Loc];
if(isequal(subject.modality,'MEG'))
    Loc = squeeze(mean(reshape(Loc,3,4,Nelec),2));
end
for ii = 1:length(Loc)
    X(ii) = Loc(1,ii);
    Y(ii) = Loc(2,ii);
    Z(ii) = Loc(3,ii);
end
C = abs(diag(Svv));
C = C/max(C);
C(C<0.01) = 0;

figure_name = strcat('Scalp 3D - ',str_band);
if(properties.run_bash_mode.disabled_graphics)
    figure_scalp_3D = figure('Color','w','Name',figure_name,'NumberTitle','off','visible','off'); hold on; set(gca,'Color','w');
else
    figure_scalp_3D = figure('Color','w','Name',figure_name,'NumberTitle','off'); hold on; set(gca,'Color','w');
end
define_ico(figure_scalp_3D);
scatter3(X,Y,Z,100,C.^1,'filled');
patch('Faces',Sh.Faces,'Vertices',Sh.Vertices,'FaceVertexCData',0.01*(ones(length(Sh.Vertices),1)),'FaceColor','interp','EdgeColor','none','FaceAlpha',.99);
colormap(gca,cmap_a);
az = 0; el = 0;
view(az, el);
rotate3d on;
title('Scalp','Color','k','FontSize',16);
axis equal;
axis off;
disp('-->> Saving figure');
file_name = strcat('Scalp_3D','_',str_band,'.fig');
saveas(figure_scalp_3D,fullfile(subject.subject_path,file_name));

close(figure_scalp_3D);

%%
%% inverse covariance matrix...
%%
temp_diag  = diag(diag(abs(Svv_inv)));
temp_ndiag = abs(Svv_inv)-temp_diag;
temp_ndiag = temp_ndiag/max(temp_ndiag(:));
temp_diag  = diag(abs(diag(Svv)));
temp_diag  = temp_diag/max(temp_diag(:));
temp_diag  = diag(diag(temp_diag)+1);
temp_comp  = temp_diag+temp_ndiag;

figure_name = strcat('Scalp - ',str_band);
if(properties.run_bash_mode.disabled_graphics)
    figure_scalp_electrodes = figure('Color','w','Name',figure_name,'NumberTitle','off','visible','off');
else
    figure_scalp_electrodes = figure('Color','w','Name',figure_name,'NumberTitle','off');
end
define_ico(figure_scalp_electrodes);
imagesc(temp_comp);
set(gca,'Color','w','XColor','k','YColor','k','ZColor','k',...
    'XTick',1:length(Loc),'YTick',1:length(Loc),...
    'XTickLabel',{Cdata.Channel.Name},'XTickLabelRotation',90,...
    'YTickLabel',{Cdata.Channel.Name},'YTickLabelRotation',0);

xlabel('electrodes','Color','k');
ylabel('electrodes','Color','k');
colormap(gca,cmap_c);
colorbar;
axis square;
title('Scalp','Color','k','FontSize',16);

disp('-->> Saving figure');
file_name = strcat('Covariance_Matrix','_',str_band,'.fig');
saveas(figure_scalp_electrodes,fullfile(subject.subject_path,file_name));

close(figure_scalp_electrodes);

% subject.Svv = Svv;

%% Saving files
disp('-->> Saving file')
file_name = strcat('Sensor_level_',str_band,'.mat');
disp(strcat("File: ", file_name));
parsave(fullfile(subject.subject_path ,file_name ),Svv,M,band);    
pause(1e-12);

end

