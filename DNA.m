classdef DNA < handle
    %   DNA - A class to describe a pseudo-DNA, or genotype
    %   Here, an organism's (airfoil's) DNA is an array of double
    %   genes stored in gen. These genes are related to the control points
    %   used for the Bezier curve. Each instance of DNA is an airfoil.
    
    properties
        name; % Airfoil's, other functions will attach proper extensions
        Re; % Reynold's number
        af; % Airfoil coordinates...b/w 0 and 1...need to make b/w -1 and 1
        gen = []; % genes for DNA
        cp; % control points for Bezier curve
        fitness; % Based on cl/cd
        clcd;
        cdp;
        order = 6; % order of Bezier curve
        
        % Airfoil is defined by
        %  LEU = Leading edge up            LED = Leading edge down      
        %  C25 = Camber at 25%              T25 = Thickness at 25%
        %  C50 = Camber at 50%              T50 = Thickness at 50%
        %  C75 = Camber at 75%              T75 = Thickness at 75%
        
        % CONSTRAINTS
        %          LEU   LED     C25   C50    C75      T25   T50   T75
        genmaxs = [0.2,  0.2,    0.15,  0.15,   0.15,     0.25,  0.25,  0.2];
        genmins = [0.0,  0.0,    0.0,  0.0,   0.0,     0.0,  0.0,  0.0];
    end
    
    methods
        % Constructor - Name nm, Reynold's Number re, Number of Coordinates
        % for each half (upper/lower) num_coords.
        function dna = DNA(nm, re, num_coords)
            dna.name = nm;
            dna.Re = re;
            
            % Generate Airfoil
            % Generate random values within constraints
            dna.gen = zeros(1,length(dna.genmaxs));
            if (nargin > 2)
                for i=1:length(dna.genmaxs)
                    dna.gen(i) = rand*(dna.genmaxs(i)-dna.genmins(i))-dna.genmins(i);
                end
                [dna.cp,dna.af] = genControlPoints(dna.gen,num_coords);
            end
        end
        
        % Save airfoil as GA.dat
        function saveAirfoil(self)
            filename = strcat('.\sampleData\', self.name);
            
            % Remove files of the same name from the directory
            [status,result] =dos(strcat('del ',filename,'.dat'));
            
            % Write airfoil name and coords to dat file
            fid = fopen(strcat(filename,'.dat'), 'w');
            fprintf(fid, strcat(self.name,'\n'));
            for i=1:length(self.af)
                fprintf(fid, '%2.8f  %2.8f\n',... 
                self.af(i,1), self.af(i,2)); 
            end
            fclose(fid);
        end
        
        % Calculate fitness based off of airfoil's CL/CD
        function calcFitness(self, alpha_min,alpha_max, inc)
            self.saveAirfoil();
            runXfoil(self.name,self.Re,alpha_min,alpha_max,inc);
            [CLCD, CDp] = parsePolar(strcat('./sampleData/',self.name,'.txt'),(alpha_max-alpha_min)/inc);
            if CLCD <= 0
                  self.fitness = 0;
            else
                %self.fitness = ((1/CDp)^2)/100;
                if CLCD > 40
                    self.fitness = (CDp^-2)*(CLCD/10)^2;
                else
                    self.fitness = (CDp^-2)*(CLCD/10)^1;
                end
                fprintf('CLCD: %f   Fitness: %f\n', CLCD, self.fitness);
            end
            self.cdp = CDp;
            self.clcd = CLCD;
        end
        
        % Mate two parent airfoils to create child. The mating process
        % determines each gene in the child's dna four different ways. 1)
        % Child receives parent1's gene. 2) Child receives partner's gene.
        % 3) Child receives average of both parents' genes. 4) Child
        % receives random value between both parents' genes.
        function child = crossover(self, partner)
            num_coords = length(self.af)/2;
            child = DNA(self.name, self.Re, num_coords);%placeholder
            child.gen = zeros(1,length(self.genmaxs));
            for i=1:length(self.gen)
                n = floor(rand*3);
                if (n == 0)
                    % parent1's gene
                    child.gen(i) = self.gen(i);
                elseif (n == 1)
                    % partner's gene
                    child.gen(i) = partner.gen(i);
                elseif (n == 2)
                    % avg of parents' values
                    child.gen(i) = 0.5.*(self.gen(i)+partner.gen(i));
                else
                    % random value in between parent gene values
                    if (self.gen(i) > partner.gen(i))
                        child.gen(i) = rand*(self.gen(i)-partner.gen(i))-partner.gen(i);
                    else
                        child.gen(i) = rand*(partner.gen(i)-self.gen(i))-self.gen(i);
                    end
                end
                [child.cp,child.af] = genControlPoints(child.gen,num_coords);
            end
        end
        
        function mutate(self, mutationRate)
            L = length(self.gen);
            for i=1:L
                if (rand < mutationRate)
                    self.gen(i) = rand*(self.genmaxs(i)-self.genmins(i))-self.genmins(i);
                end
            end
            [self.cp,self.af] = genControlPoints(self.gen,length(self.af)/2);
        end
    end%methods
end

function [cp,af] = genControlPoints(gen,num_coords)
    % Define x and y control points for upper and lower curves
    upx = [0 0 0.25 0.5 0.75 1];
    downx = upx;

    upy = zeros(1,6);
    downy = zeros(1,6);
    
    % Leading edge
    upy(2) = gen(1);
    downy(2) = -gen(2);

    %Camber + thickness
    upy(3) = gen(3) + gen(6);
    upy(4) = gen(4) + gen(7);
    upy(5) = gen(5) + gen(8);

    downy(3) = gen(3) - gen(6);
    downy(4) = gen(4) - gen(7);
    downy(5) = gen(5) - gen(8);
    
    upper = []; lower = [];
    n = length(upx);
    for i = 1:n
        upper(i,:) = [upx(n-i+1) upy(n-i+1)];
        lower(i,:) = [downx(i) downy(i)];
    end
    cp = [upper; lower];
    af = [Bezier(upper, num_coords); Bezier(lower, num_coords)];
end

