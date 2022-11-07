function [CLCD, CDp] = parsePolar(path, num)
% parsePolar - a function to parse an Xfoil polar file 
% path is the polar filename+extension e.g. './sampleData/GA.txt'
% num is the number of data points to expect. If the number of data points
% in the polar file is much less than num, then this function will return a
% CL/CD of 0.
% Future Work: Adjust CL/CD calculation to be a weighted average. Weight
% the values between 0-5 deg higher than 5-10 deg and higher than 10-15
% deg. Incorporate other parameters???

CLCD = 0; CDp = 0;
file = textread(path, '%s', 'delimiter', '\n','whitespace', '');
i = 1;
% Read each line of the file
while i <= length(file)
    % Find where the data begins
    str = char(file(i));
    header = regexpi(str, '------ -------- --------- --------- -------- -------- --------');
    
    % Look through data if header is not empty
    if(~isempty(header))
        % Store all results in arrays
        [alphas, CLs, CDs, CDps] = getResults(file,i);
        idx = find(CLs == max(CLs(:)), 1, 'last'); % index of max CL
        % Calculate stall slope
        idxf = length(CLs);
        if (idxf > idx)
            stallSlope = (CLs(idxf)-CLs(idx))/(idxf-idx);
        else
            stallSlope = 0; % doesn't stall in current range of angles
        end
        
        % Determine CL/CD and average parasitic drag
        if (length(alphas) < 0.6*num)
            % If we don't have at least 60% of the expected data points, return
            % a CL/CD of 0. This will help prevent us from being misled by 
            % bad airfoils.
            CLCD = 0; CDp = 0;
            break; % Exit the loop
        else
            % Determine Average Parasitic Drag Coefficient
            CDp = sum(CDps)/length(CDps);
            % Calculate Average CL/CD
            CLCD = sum(CLs./CDs)/length(CLs);
            break; % Exit the loop
%             if(~isempty(header))
%                 clcd = calcCLCD(file,i);
%                 break; % Exit the loop
%             end
        end
    end
    i=i+1;
end


end

% Returns the alpha, CL, and CD results from a specified polar file and
% index i
function [alphas, CLs, CDs, CDps] = getResults(file,i)
    alphas = []; CLs = []; CDs = []; CDps = [];
    if(i ~= length(file) && ~isempty(file(i+1)))
        j = i+1;
        while (j<=length(file) && ~isempty(file(j)))
            results = textscan(char(file(j)), '%f');
            alphas(j-i) = results{1}(1);
            CLs(j-i) = results{1}(2);
            CDs(j-i) = results{1}(3);
            CDps(j-i) = results{1}(4);
            j = j+1;
        end
    end
end

% Calculates the average CL/CD of the file
% Returns 0 if there are xfoil could not calculate the values, if CD is 0 
% for an angle of attack or, if not enough values were calculated.
function clcd = calcCLCD(file,i)
    if(i == length(file))
        clcd = 0;
    elseif(isempty(file(i+1)))
        clcd = 0;
    else
        j = i+1;
        clcd = 0;
        while (j<=length(file) && ~isempty(file(j)))
            results = textscan(char(file(j)), '%f');
            CL = results{1}(2);
            if (results{1}(3) == 0)
                clcd = 0;
                break;
            else
                CD = results{1}(3);
                clcd = (clcd*(j-(i+1))+CL/CD)/(j-i);
            end
            j = j+1;
        end
    end
end

