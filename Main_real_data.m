%%
%%  Hermitian-Graphical-LASSO
%%
% Description:
%
%
%
%
%
%
%
% Authors:
% - Deirel Paz Linares
% - Eduardo Gonzalez Moreira
% - Ariosky Areces Gonzalez
% - Pedro A. Valdes Sosa
%
% Updated: Feb 5, 2023

disp("=====================================================================");
disp("              <<<<< Hermitian-Graphical-LASSO >>>>>");
disp("=====================================================================");


%% Preparing WorkSpace
clc;
close all;
clearvars;
disp("-->> Starting process analysis");
disp("=====================================================================");
restoredefaultpath;
tic
addpath('app_config');
addpath(genpath('functions'));
addpath(('external'));
addpath(('external/osl_core'));
addpath(genpath('external/MEG-ROI-nets'));
addpath(('tools'));

%% Printing data information
app_properties = jsondecode(fileread(strcat('app_config/properties.json')));
disp(strcat("-->> Name:",app_properties.generals.name));
disp(strcat("-->> Version:",app_properties.generals.version));
disp(strcat("-->> Version date:",app_properties.generals.version_date));
disp("=====================================================================");

%% ------------ Checking MatLab compatibility ----------------
if(app_properties.check_matlab_version)
    disp('-->> Checking installed matlab version');
    if(~check_matlab_version())
        return;
    end
end

%% ------------  Checking updates --------------------------
if(app_properties.check_app_update)
    disp('-->> Checking last project version');
    if(isequal(check_version,'updated'))
        return;
    end
end

properties                  = get_properties();
color_map                   = load(properties.general_params.colormap_path);
properties.cmap             = color_map.cmap;
properties.cmap_a           = color_map.cmap_a;
properties.cmap_c           = color_map.cmap_c;
if(isequal(properties,'canceled'))
    return;
end
properties.general_params.workspace.input_path = fullfile(pwd,properties.general_params.workspace.input_path);
properties.general_params.workspace.output_path = fullfile(pwd,properties.general_params.workspace.output_path);
[status,reject_subjects]    = check_properties(properties);
if(~status)
    fprintf(2,strcat('\nBC-V-->> Error: The current configuration files are wrong \n'));
    disp('Please check the configuration files.');
    return;
end
root_path                   = properties.general_params.workspace.input_path;
subjects                    = dir(fullfile(root_path,'**','subject.mat'));

%% Starting analysis
for i=1:length(subjects)
    subject_file                                        = subjects(i);
    [subject,checked,error_msg_array]                   = checked_subject_data(subject_file,properties);
    if(checked)
        if(isequal(properties.general_params.workspace.output_path,'local') || isempty(properties.general_params.workspace.output_path))
            subject.subject_path                        = fullfile(subject_file.folder,'Output');
        else
            subject.subject_path                        = fullfile(properties.general_params.workspace.output_path,subject.name);
        end
        if(~isfolder(subject.subject_path))
            mkdir(subject.subject_path);
        end
        
        %% Calling analysis
        process_error = process_analysis_interface(subject, properties);
        
    else
        fprintf(2,strcat('\nBC-V-->> Error: The folder structure for subject: ',subject.name,' \n'));
        fprintf(2,strcat('BC-V-->> Have the folows errors.\n'));
        for j=1:length(error_msg_array)
            fprintf(2,strcat('BC-V-->>' ,error_msg_array(j), '.\n'));
        end
        fprintf(2,strcat('BC-V-->> Jump to an other subject.\n'));
        continue;
    end
end


























    
disp("=====================================================================");
disp("-->> Process finished.");
hours = fix(toc/3600);
minutes = fix(mod(toc,3600)/60);
disp(strcat("Elapsed time: ", num2str(hours) , " hours with ", num2str(minutes) , " minutes." ));
disp('=====================================================================');
disp(app_properties.generals.name);
disp('=====================================================================');