function runXfoil(name, Re, alpha_min,alpha_max, inc)
%% runXfoil JUL 2018
%runXfoil.m
%
%This script creates an xfoil batch script and then executes it.

%% INPUT variables
filename = strcat('.\sampleData\',name);
%Location of xfoil
xfoilLocation = '.\xfoil.exe';

%% Directory Preparation
%Purge Directory of interfering files
[status,result] =dos(strcat('del ',filename,'.txt'));
[status,result] =dos(strcat('del ',filename,'.run'));
%[status,result] =dos(strcat('del ',filename,'.bat'));

%% Create run file
%Open the file with write permission
fid = fopen(strcat(filename,'.run'), 'w');

%Disable Graphics
%fprintf(fid, 'PLOP\ng\n\n');

%Load the Xfoil definition of the airfoil
fprintf(fid, 'LOAD %s\n', strcat(filename,'.dat'));
%fprintf(fid, 'naca 2424\n');

%Smooth out the airfoil to be sufficient for xfoil
fprintf(fid, '%s\n',   'PANE');

%Open the OPER menu
fprintf(fid, '%s\n',   'OPER');

%Enter viscous mode
fprintf(fid, '%s\n',   'V');

%Enter Reynolds number
fprintf(fid, '%f\n',   Re);

%Increase number of iterations
fprintf(fid, '%s\n',   'ITER 100');

% Enter polar modeit
fprintf(fid, '%s\n',   'P');
fprintf(fid, '%s\n',    strcat(filename,'.txt')); % save polar file
fprintf(fid, '\n'); % dont save polar dump

%Calculate the flow around the airfoil for angle of attack of -5 to alpha deg
fprintf(fid, '%s\n',   ['ASEQ',' ',num2str(alpha_min),' ',num2str(alpha_max),' ',num2str(inc)]);
%fprintf(fid, '%s\n',   ['ASEQ 0 ',num2str(alpha),' ',num2str(inc)]);
%fprintf(fid, '%s\n',   'ALFA 0');

%Drop out of polar mode
fprintf(fid, '%s\n',   'P');

%Drop out of OPER menu
fprintf(fid, '%s\n',   '');

%Quit Program
fprintf(fid, 'QUIT\n');

%Close File
fclose(fid);

%% Create Batch  File
delay=45;
createBatch(name,delay);
tic;
batchRunXfoil();
batchT=toc;
fprintf('%f\n',batchT);

%% Execute Run
%Run Xfoil using
% cmd = strcat(xfoilLocation,' < ',filename,'.run');
% [status,result] = dos(cmd);
end

function batchRunXfoil()
    [status,result] = dos('runXfoil.bat');
end

function createBatch(name,delay)
    filename = strcat('.\\sampleData\\',name);
    fid=fopen('runXfoil.bat','w');
    fprintf(fid, '@echo off\n');
    fprintf(fid, ['set App=xfoil.exe\n']);
    fprintf(fid, ['set Delay=',num2str(delay),'\n']);
    fprintf(fid, 'set killer=%%temp%%\\kill.bat\n');
    fprintf(fid, 'echo > "%%killer%%" ping localhost -n %%Delay%% ^> nul\n');
    fprintf(fid, 'echo>> "%%killer%%" tasklist ^| find /i "%%App%%" ^> nul ^&^& taskkill /f /im %%App%%\n');
    fprintf(fid, 'start /b "Timeout" "%%killer%%"\n');
    fprintf(fid, ['%%App%%<',filename,'.run']);
    fclose(fid);
end

