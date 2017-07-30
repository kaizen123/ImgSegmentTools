%DISPLAY THE RESULTS FROM THE EXPERIMENT.

CD = cd;

DIRS_BAD = [CD '/Highlight/AEREN_DATA/BAD'];
DIRS_GOOD = [CD '/Highlight/AEREN_DATA/GOOD'];
DIRS_ONLYA = [CD '/Highlight/AEREN_DATA/ONLY A'];


cd(DIRS_BAD);
DIR_EXP_RESULTS_BAD = dir('CORT_EXP_OUTPUT*');

cd(DIRS_GOOD);
DIR_EXP_RESULTS_GOOD = dir('CORT_EXP_OUTPUT*');

cd(DIRS_ONLYA);
DIR_EXP_RESULTS_ONLYA = dir('CORT_EXP_OUTPUT*');


DIRSS = cell(3,2);
DIRSS{1,1} = DIRS_BAD;
DIRSS{2,1} = DIRS_GOOD;
DIRSS{3,1} = DIRS_ONLYA;

DIRSS{1,2} = 0;
DIRSS{2,2} = 1;
DIRSS{3,2} = 2;
            

FILENAME = ['AEREN_EXPERIMENT' '.txt'];
    
DATAS = fopen(FILENAME, 'wt');

%ACCESS EACH SUB-DIRECTORY.

for DI = 1:3

DIRSSS = DIRSS{DI,1};
cd(DIRSSS);
DIR_EXP_RESULTS = dir('CORT_EXP_OUTPUT*');
    
CODES = DIRSS{DI,2};

%DETERMINE HOW MANY DATA POINTS WE HAVE.


size_mat = 0;

for I = 1:numel(DIR_EXP_RESULTS)
    
    LOAD_MAT = struct2cell(load(DIR_EXP_RESULTS(I).name));
    LOAD_MAT = LOAD_MAT{1,1};
    
    size_mat = size_mat + size(LOAD_MAT, 1);
    
end;




%open file for data output





%load all data points into a master data matrix.

size_mat_col = size(LOAD_MAT, 2);


master_matrix = zeros(size_mat, size_mat_col+10);


%start row.

start_row = 0;

J = 0;

for I = 1:numel(DIR_EXP_RESULTS)
    
    start_row = find(master_matrix(:,1) == 0, 1, 'first');
    
    LOAD_MAT = struct2cell(load(DIR_EXP_RESULTS(I).name));
    LOAD_MAT = LOAD_MAT{1,1};
    
    %remove the background pixels.
    
    LOAD_MAT = LOAD_MAT(LOAD_MAT(:,1) ~= 1, :);
    
    mean_LOAD_MAT = mean(LOAD_MAT(:,2)) + std(LOAD_MAT(:,2));
    
    
    X_COM = mean(LOAD_MAT(:,10));
    Y_COM = mean(LOAD_MAT(:,11));
    
    DIFF = sqrt((X_COM - LOAD_MAT(:,10)).^2 + (Y_COM - LOAD_MAT(:,11)).^2);

    FIND_DIFF_MIN_INDEX = find(DIFF == min(DIFF));

    FIND_DIFF_MIN_X = DIFF(FIND_DIFF_MIN_INDEX);

    
    
%[FIND_DIFF_MIN_X mean_LOAD_MAT]
        
    
        if (FIND_DIFF_MIN_X < 15)
        
            FIND_DIFF_MIN = FIND_DIFF_MIN_INDEX;
        
            INDEX = LOAD_MAT(FIND_DIFF_MIN, 1);
            LOAD_MAT = LOAD_MAT(LOAD_MAT(:,1) ~= INDEX, :);
            
        else
            
            if (LOAD_MAT(:,2) <= mean_LOAD_MAT)
                
                FIND_DIFF_MIN = (1:size(LOAD_MAT,1));
                LOAD_MAT = LOAD_MAT(FIND_DIFF_MIN, :);
                
            else
                
                FIND_DIFF_MIN = FIND_DIFF_MIN_INDEX;
                
                INDEX = LOAD_MAT(FIND_DIFF_MIN, 1);
                LOAD_MAT = LOAD_MAT(LOAD_MAT(:,1) ~= INDEX, :);
                
            end;
        
        end;
    
    
    ROWS = size(LOAD_MAT, 1);
    
    master_matrix(start_row:(start_row + ROWS - 1),1:size_mat_col) = LOAD_MAT;
    
    
    
    %we need to calculate a radius from the cross-section centroid that is
    %normalized to the cross-section.
    
    THETA_VECT = -pi:(pi/8):pi;
    
    NORMAL_RAD = zeros(size(LOAD_MAT, 1), 1);
    minrad = zeros((size(THETA_VECT, 2) - 1), 1);
    maxrad = zeros((size(THETA_VECT, 2) - 1), 1);
    
    for aa = 1:(length(THETA_VECT) - 1)
        
        bound_index = find((LOAD_MAT(:,19) >= THETA_VECT(aa)) & (LOAD_MAT(:,19) < THETA_VECT(aa + 1)));
        
        if (isempty(bound_index) == 0)
        
            data = LOAD_MAT(bound_index,20);
                   
            max_min = data - min(data);
            
            minrad(aa) = min(data);
            maxrad(aa) = max(data);
            
            %INV_SLOPE = max_min/mean_max_min;
        
            normalized_radius = (max_min/max(max_min));
            NORMAL_RAD(bound_index) = normalized_radius;
        
        end;
        
        
    end;
    
    
    agg_max_min_diff = maxrad./minrad;
    agg_max_min_diff = agg_max_min_diff(agg_max_min_diff >= 0);
    
    
    mean_rad_dif = mean(agg_max_min_diff);
    
    
    %DERIVE NORMALIZED OBJECT VARIABLES.
    
    master_matrix(start_row:(start_row + ROWS - 1), (size_mat_col + 1)) = NORMAL_RAD;
    
    master_matrix(start_row:(start_row + ROWS - 1), (size_mat_col + 2)) = LOAD_MAT(:, 2)/mean_rad_dif;
    master_matrix(start_row:(start_row + ROWS - 1), ((size_mat_col + 3):(size_mat_col + 6))) = LOAD_MAT(:, 4:7)/mean_rad_dif;
    master_matrix(start_row:(start_row + ROWS - 1), (size_mat_col + 7)) = LOAD_MAT(:, 8)/mean_rad_dif;
    master_matrix(start_row:(start_row + ROWS - 1), (size_mat_col + 8)) = LOAD_MAT(:, 9)/mean_rad_dif;
    master_matrix(start_row:(start_row + ROWS - 1), (size_mat_col + 9)) = LOAD_MAT(:, 14)/mean_rad_dif;
    master_matrix(start_row:(start_row + ROWS - 1), (size_mat_col + 10)) = LOAD_MAT(:, 16)/mean_rad_dif;
    
    
    LOAD_MAT_NORM = horzcat(NORMAL_RAD, horzcat(LOAD_MAT(:, 2), LOAD_MAT(:, 4:7), LOAD_MAT(:, 8), LOAD_MAT(:, 9), LOAD_MAT(:, 14), LOAD_MAT(:, 16))/mean_rad_dif);
    
    
    
    %print the data to text fil
    
    STAT = DIR_EXP_RESULTS(I).name;
    
    J = J + 1;
    
    for I = 1:ROWS
    
    
    LOAD_MATS = LOAD_MAT(I,:);   
    LOAD_MATS_NORM = LOAD_MAT_NORM(I, :);
                    %info    sample  cell    area    orient  bound   bound   bound   bound   extent  perim   x-com   y-com   convex  eccent  major   equiv   minor  x-diff  y-diff  theta    rad   contrast  mean    std     class   normrad  normA  nbound  nbound nbound   nbound   next   normP  normMaj normMin                                                                                  bound
    fprintf(DATAS, '%1.0f\t %1.0f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.4f\t %1.0f\t %1.8f\t %1.8f\t %1.8f\t %1.8f\t %1.8f\t %1.8f\t %1.8f\t %1.8f\t %1.8f\t %1.8f\n', CODES, J, LOAD_MATS, LOAD_MATS_NORM); 
    
    
    end;
    
    
end;



%REMOVE ALL STRAIGHT LINE OBJECTS.

master_matrix = master_matrix(master_matrix(:,13) ~= 1, :);



%subset data by area classification

%we have 3 area classifications: cell areas, aerenchyma areas and noise
%(junk areas).


SUB_CELL_AREA = master_matrix(master_matrix(:,size_mat_col) == 1, :);
SUB_AEREN_AREA = master_matrix(master_matrix(:,size_mat_col) == 2, :);
SUB_NOISE_AREA = master_matrix(master_matrix(:,size_mat_col) == 0, :);


%REMOVE ALL AREAS = 1.

%SUB_CELL_AREA = SUB_CELL_AREA(SUB_CELL_AREA(:,2) ~= 1, :);
%SUB_AEREN_AREA = SUB_AEREN_AREA(SUB_AEREN_AREA(:,2) ~= 1, :);
%SUB_NOISE_AREA = SUB_NOISE_AREA(SUB_NOISE_AREA(:,2) ~= 1, :);


% 
% MAJ_MIN_CELL = SUB_CELL_AREA(:,14)./SUB_CELL_AREA(:,16);
% MAJ_MIN_AEREN = SUB_AEREN_AREA(:,14)./SUB_AEREN_AREA(:,16);

[n, x] = hist(SUB_CELL_AREA(:,(size_mat_col + 1)), 500);
[n2, x2] = hist(SUB_AEREN_AREA(:,(size_mat_col + 1)), 500);



figure('Position', [0, 0, 2100, 1400])
subplot(2,1,1);
hist(SUB_CELL_AREA(:,(size_mat_col + 1)), 500), axis([0 1 0 max(n(2:end))+5]);
title('Cell Areas', 'FontSize', 18, 'FontWeight', 'bold');
grid on;

subplot(2,1,2);
hist(SUB_AEREN_AREA(:,(size_mat_col + 1)), 500), axis([0 1 0 max(n2)+5]);
title('Aerenchyma Areas', 'FontSize', 18, 'FontWeight', 'bold');
grid on;








end;


fclose(DATAS);

