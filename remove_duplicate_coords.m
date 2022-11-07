% Removes coordinates that are within .01 of each other in teh x direction
% from a .dat file so that SolidWorks can import the curve
clear; clc;
filename = 'airfoil'; filename2 = strcat(filename,'2');
path = strcat('./sampleData/',filename,'.dat'); path2 = strcat('./sampleData/',filename2,'.dat');
fid = fopen(path); fid2 = fopen(path2, 'w'); fprintf(fid2, '%s\n', filename2);
file = textscan(fid, '%s', 'delimiter', '\n','whitespace', '');
i = 2;
while i < length(file{1})
    fprintf(fid2, '%s\n', string(file{1}(i)));
    
    coord1 = textscan(file{1}{i}, '%f');
    coord2 = textscan(file{1}{i+1}, '%f');
    x1 = coord1{1}(1); x2 = coord2{1}(1);
    if(abs(x1-x2) < 0.005)
        j = i+2;
        done = false;
        while done == false && j < length(file{1})
            coord2 = textscan(file{1}{j}, '%f');
            x2 = coord2{1}(1);
            if (abs(x1-x2) < 0.01)
                j = j+1;
            else
                done = true;
            end
        end
        i = j;
    else
        i = i+1;
    end
end
coord1 = textscan(file{1}{i-1}, '%f');
coord2 = textscan(file{1}{i}, '%f');
x1 = coord1{1}(1); x2 = coord2{1}(1);
if(abs(x1-x2) >= 0.01)
    fprintf(fid2, '%s\n', string(file{1}(i)));
end
fclose(fid); fclose(fid2);