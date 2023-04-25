%==========================================================================
% Data set analyzer for use in error functions
%
%    Date: Apr 25, 2023
% 
% (c) Kaitlin Corpus, LBNL. 
%
% This code is licensed under a
% MIT License.
% You should have received a copy of the license along with this
% work. If not, see <https://opensource.org/license/mit/>.
% =========================================================================


% Add path of folder with data sets
path = 'C:\Users\ecg\Documents\Kaitlin Kinetic Studies\Kaitlin_Kinetic_Studies\Inputs\Ag_Data_Sets_5\Ag_Data_Sets';
addpath(path); 

% Set up loop to run through all of the data sets 
for n = 1:66
    % Name each of the txt files 
    if n < 10
        folder = ['\00' num2str(n)];
        dat_file_co= ['\dat_00' num2str(n) '_CO.txt'];
        dat_file_h2= ['\dat_00' num2str(n) '_H2.txt'];
        meta_file = ['\metadata_00' num2str(n) '.txt'];
    else 
        folder = ['\0' num2str(n)];
        dat_file_co= ['\dat_0' num2str(n) '_CO.txt'];
        dat_file_h2= ['\dat_0' num2str(n) '_H2.txt'];
        meta_file = ['\metadata_0' num2str(n) '.txt'];
    end
    
    % Extract the data from the meta data txt file 
    opts = delimitedTextImportOptions('Delimiter',':');
    meta_data1 = readtable([path folder meta_file],opts);
    meta_data = table2array(meta_data1);

    ylog = convertCharsToStrings(meta_data{3,2});
    xunit = convertCharsToStrings(meta_data{5,2});
    xlog = convertCharsToStrings(meta_data{6,2});
    pH = str2double((meta_data{12,2}));
    conc = str2double((meta_data{14,2}));
    
    % extract the data from each product's txt file 
    % CO product 
    co_ = readtable([path folder dat_file_co]);
    co = table2array(co_);

    % H2 product 
    h2_ = readtable([path folder dat_file_h2]);
    h2 = table2array(h2_);
    
    % Orders the potentials in descending order 
    if co(1,1) < co(length(co),1) 
        co = flip(co(:,:));
    end
    if h2(1,1) < h2(length(h2),1) 
        h2 = flip(h2(:,:));
    end

    % Exponentiates current densities if in log form 
    if strcmp(convertCharsToStrings(meta_data{3,2}), " true") == 1 
        co(2,:) = exp(co(2,:));
        h2(2,:) = exp(h2(2,:));
    end

    % Shifts the voltage to SHE if data set is in RHE 
    if strcmp(convertCharsToStrings(meta_data{5,2}), (" RHE")) == 1 
        co(:,1) = co(:,1) - (0.059 * pH);
        h2(:,1) = h2(:,1) - (0.059 * pH); 
    end
    
    % Finds the indices of the potentials from the COMSOL model simulation current data  
    differences = cell(1,length(co)-1);
    step = 0.01; % Step of voltage parameter sweep in COMSOL
    
    % For CO 
    for i = 1:length(co)-1
        differences{i} = (-1/step)*(co(i+1,1)-co(i,1));
    end

    differences_2 = cell2mat(differences);
    differences_f = [1 differences_2];
    comparison_indeces = {cell(1,length(co)-2)};
    for i = 1:length(differences)
       comparison_indeces{i} = sum(differences_f(:,1:i+1));
    end

    comparison_indeces_f = [1 round(cell2mat(comparison_indeces))]; % Indices of the simulation current data for comparison with experimental data
    COMSOL_V_list_co = co(length(co),1):step:co(1,1); % Finds the list of potentials the model will sweep through
    
    %For H2
    differences2 = cell(1,length(h2)-1);
    step2 = 0.01;
    for i = 1:length(h2)-1
       differences2{i} = (-1/step2)*(h2(i+1,1)-h2(i,1));
    end

    differences_2 = cell2mat(differences2);
    differences_f_2 = [1 differences_2];
    comparison_indeces2 = {cell(1,length(h2)-2)};
    for i = 1:length(differences2)
       comparison_indeces2{i} = sum(differences_f_2(:,1:i+1));
    end

    comparison_indeces_f_2 = [1 round(cell2mat(comparison_indeces2))]; % Same as CO
    COMSOL_V_list_h2 = h2(length(h2),1):step2:h2(1,1); % Same as CO
    
    % Names the file name that will include all of the necessary data for the error functions 
    if n<10
        filename = ['full_currdata_00' num2str(n) '.mat'];
    else
        filename = ['full_currdata_0' num2str(n) '.mat'];
    end
    
    % Saves the comparsion indices, voltage lists, voltage-current data, pH, and electrolyte data for each product (CO and H2) 
    save(filename, "comparison_indeces_f","COMSOL_V_list_co","h2","co","comparison_indeces_f_2","COMSOL_V_list_h2",'pH','conc');
end
