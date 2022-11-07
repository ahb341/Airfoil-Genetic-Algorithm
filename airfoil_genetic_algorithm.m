%% Airfoil Genetic Algorithm OCT 2018
% airfoil_genetic_algorithm.m
% A genetic algorithm to optimize an airfoil for a given set of parameters 
% and constraints. Currently optimizes CL/CD, but can be improved to 
% optimize for other conditions.
clear; clc;
%% Input Variables
mr = 0.08; % Mutation Rate
population_size = 50; % Size of airfoil population
name = 'GA'; % Name of airfoil
Re = 600000; % Reynold's Number


alpha_min = -2;
alpha_max = 5;
inc = 0.25; % increment for xfoil angle of attack flow calculations
num_coords = 70; % num coords for upper and lower section
max_gens = 30; % max number of generations
testname = 'pop_-2to5_600000_02_06_21';
%mh114 = DNA('mh114',Re);
%createKillXfoil(0); % create kill xfoil batch file (wait time 2 seconds)

% Parallel Computing Toolbox
%pool = gcp();
%% Genetic Algorithm
% population must have at least 1 member
p = Population(mr,population_size,name,Re,num_coords);
worldRecord = p.population(1); % Most fit airfoil out of all generations
for i = 1:max_gens
    fprintf('Generation: %d\n', i);
    %calculate fitness
    p.calcFitness(alpha_min,alpha_max,inc);
    b = p.getBest();
    if (b.fitness() > worldRecord.fitness())
        worldRecord = b;
    end
    fprintf('Current Best: %f\n', b.cdp);
    fprintf('World Record: %f\n', worldRecord.cdp);
    %generate mating pool
    p.naturalSelection();
    %create next generation
    p.generate();
    save(testname,'p','worldRecord');
end
p.calcFitness(alpha_min,alpha_max,inc);
best = p.getBest();
if (best.fitness() > worldRecord.fitness)
    worldRecord = best;
end
fprintf('Current Best: %f\n', best.cdp);
fprintf('World Record: %f\n', worldRecord.cdp);
save(testname,'p','worldRecord');

%% Post Processing
% Sort population
[~, ind] = sort([p.population.fitness]);
pop_sorted = p.population(ind);

% Use the line below in the command window to obtain coordinates and polar
% results from .dat and .txt files respectively. Subtract from 'end' to
% pick an airfoil before the top ranked airfoil

% pop_sorted(end).calcFitness(alpha_min,alpha_max,inc)
