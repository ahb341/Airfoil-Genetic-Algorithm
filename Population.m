classdef Population < handle
    %Population A class to describe a population of organisms
    %   In this case, each organism is just an instance of a DNA object
    
    properties
        mutationRate; %Mutation rate
        population = DNA.empty(); %DNA Array to hold the current population
        matingPool = DNA.empty(); %DNA ArrayList for our "mating pool"
        generations = 0; %Number of generations
    end
    
    methods
        % mutation rate m, population size popsize
        function p = Population(mr, popsize, name, Re, num_coords)
            p.mutationRate = mr;
            
            % Create a population of airfoils of size 'popsz'
            for i = 1:popsize
                p.population(i) = DNA(name,Re,num_coords);
            end
        end
        
        % Calculate fitness for every airfoil in population
        function calcFitness(self, alpha_min,alpha_max, inc)
            for i = 1:length(self.population)
                self.population(i).calcFitness(alpha_min,alpha_max,inc);
            end
        end
        
        % Generate a mating pool
        function naturalSelection(self)
            self.matingPool = [];
            
            maxFitness = 0;
            for i = 1:length(self.population)
                if (self.population(i).fitness > maxFitness)
                    maxFitness = self.population(i).fitness;
                end
            end
            % Based on fitness, each member will get added to the mating 
            % pool a certain number of times. A higher fitness = more 
            % entries to mating pool = more likely to be picked as a
            % parent. A lower fitness = fewer entries to mating pool = less 
            % likely to be picked as a parent
            for i = 1:length(self.population)
                fitness = self.population(i).fitness/maxFitness;
                n = fitness*100;%Arbitrary multiplier...can also use 
                %monte carlo method and pick two random numbers
                for j=1:n 
                    self.matingPool = [self.matingPool self.population(i)];
                end
            end
        end
        
        % Create a new generation
        function generate(self)
            % Refill the population with children from the mating pool
            for i = 1:length(self.population)
                a = randi(length(self.matingPool));
                b = randi(length(self.matingPool));
                partnerA = self.matingPool(a);
                partnerB = self.matingPool(b);
                child = partnerA.crossover(partnerB);
                child.mutate(self.mutationRate);
                self.population(i) = child;
            end
            self.generations = self.generations + 1;
        end
        
        % Compute the most fit member of the population
        function best = getBest(self)
            index = 1;
            mostfit = self.population(index).fitness;
            for i = 1:length(self.population)
                if self.population(i).fitness > mostfit
                    index = i;
                    mostfit = self.population(i).fitness;
                end
            end
            best = self.population(index);
        end
        
    end%methods
    
end

  %if rem(i,2) == 0
                    %p.population(i) = DNA(name,Re,dnasz,'0000');
                %else
%                     M = num2str(floor(rand*10));
%                     P = num2str(floor(rand*10));
%                     X = num2str(floor(rand*2)); %max section thickness is 39%
%                     XX = num2str(floor(rand*10)); %max section thickness is 39%;
%                     if (strcmp(strcat(X,XX), '00'))
%                         XX = num2str(floor(rand*9)+1);
%                     end
%                     naca = strcat(M,P,X,XX);
%                     %naca = num2str(floor(rand*8999+1000));
%                     fprintf('%s\n',naca);
%                     p.population(i) = DNA(name,Re,num_coords,naca);
                %end

