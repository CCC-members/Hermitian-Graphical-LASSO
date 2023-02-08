function [properties] = get_properties()
try
    properties = jsondecode(fileread(strcat('app_config/properties.json')));    
catch ME
    fprintf(2,strcat('\nBC-V-->> Error: Loading the property files: \n'));
    fprintf(2,strcat(ME.message,'\n'));
    fprintf(2,strcat('Cause in file app_config\properties.json \n'));
    disp('Please verify the json format in the file.');
    properties = 'canceled';
    return;
end
try
    general_params              = jsondecode(fileread(properties.general_params_file.file_path));
    properties.general_params   = general_params;
catch ME
    fprintf(2,strcat('\nBC-V-->> Error: Loading the property files: \n'));
    fprintf(2,strcat(ME.message,'\n'));
    fprintf(2,strcat('Cause in file', properties.general_params_file.file_path , '\n'));
    disp('Please verify the json format in the file.');
    properties = 'canceled';
    return;
end
try
    activ_params              = jsondecode(fileread(properties.activ_params_file.file_path));
    properties.activ_params   = activ_params;
catch ME
    fprintf(2,strcat('\nBC-V-->> Error: Loading the property files: \n'));
    fprintf(2,strcat(ME.message,'\n'));
    fprintf(2,strcat('Cause in file', properties.activ_params_file.file_path , '\n'));
    disp('Please verify the json format in the file.');
    properties = 'canceled';
    return;
end
try
    conn_params              = jsondecode(fileread(properties.conn_params_file.file_path));
    properties.conn_params   = conn_params;
catch ME
    fprintf(2,strcat('\nBC-V-->> Error: Loading the property files: \n'));
    fprintf(2,strcat(ME.message,'\n'));
    fprintf(2,strcat('Cause in file', properties.conn_params_file.file_path , '\n'));
    disp('Please verify the json format in the file.');
    properties = 'canceled';
    return;
end
try
    spectral_params              = jsondecode(fileread(properties.spectral_params_file.file_path));
    properties.spectral_params   = spectral_params;
catch ME
    fprintf(2,strcat('\nBC-V-->> Error: Loading the property files: \n'));
    fprintf(2,strcat(ME.message,'\n'));
    fprintf(2,strcat('Cause in file', properties.conn_params_file.file_path , '\n'));
    disp('Please verify the json format in the file.');
    properties = 'canceled';
    return;
end
end

