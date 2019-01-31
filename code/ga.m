clc;
clear;
close all;


%% Problem Definition
model = CreateNationalModel();      %create model
f=CreateRandomSolution(model);      %create random solution

global NFE;
NFE=0;

% Cost Function
CostFunction = @(f) MyCost(f, model);

nVar=model.M;                       % number of decision variables = number of hubs
VarSize=[1 nVar];                   % decision variables matrix size

%% GA Parameters

MaxIt=500;      % Maximum Number of Iterations

nPop=100;        % Population Size

pc=0.7;                 % Crossover Percentage
nc=2*round(pc*nPop/2);  % Number of Offsprings (Parnets)

pm=0.2;                 % Mutation Percentage
nm=round(pm*nPop);      % Number of Mutants

mu=0.02;         % Mutation Rate

ANSWER=questdlg('Choose selection method:','Genetic Algorith',...
    'Roulette Wheel','Tournament','Random','Roulette Wheel');

UseRouletteWheelSelection=strcmp(ANSWER,'Roulette Wheel');
UseTournamentSelection=strcmp(ANSWER,'Tournament');
UseRandomSelection=strcmp(ANSWER,'Random');

if UseRouletteWheelSelection
    beta=8;         % Selection Pressure
end

if UseTournamentSelection
    TournamentSize=3;   % Tournamnet Size
end

pause(0.1);

%% Initialization

empty_individual.Position=[];
empty_individual.Cost=[];
empty_individual.Coverage=[];

pop=repmat(empty_individual,nPop,1);

for i=1:nPop
    %initialize position
    pop(i).Position=randi([0 1],VarSize);
    
    % Evaluation
    pop(i).Cost = CostFunction(pop(i).Position);
    %pop(i).Coverage = CalcCoverage(pop(i).Position, model);
end

% Sort Population
Costs=[pop.Cost];
[Costs, SortOrder]=sort(Costs);
pop=pop(SortOrder);

% Store Best Solution
BestSol=pop(1);
BestSol.Coverage = CalcCoverage(BestSol.Position, model);

% Array to Hold Best Cost Values
BestCost=zeros(MaxIt,1);

% Store Cost
WorstCost=pop(end).Cost;

% Array to Hold Number of Function Evaluations
nfe=zeros(MaxIt,1);

%% Main Loop

for it=1:MaxIt
    
    %calculate selection probabilities
    P=exp(-beta*Costs/WorstCost);
    P=P/sum(P);
    
    %crossover
    popc=repmat(empty_individual,nc/2,2);
    for k=1:nc/2
        
        %select parents indices
        if UseRouletteWheelSelection
            i1=RouletteWheelSelection(P);
            i2=RouletteWheelSelection(P);
        end
        if UseTournamentSelection
            i1=TournamentSelection(pop,TournamentSize);
            i2=TournamentSelection(pop,TournamentSize);
        end
        if UseRandomSelection
            i1=randi([1 nPop]);
            i2=randi([1 nPop]);
        end

        %select parents
        p1=pop(i1);
        p2=pop(i2);
        
        %apply crossover
        [popc(k,1).Position, popc(k,2).Position]=Crossover(p1.Position,p2.Position);
        
        %evaluate offsprings
        popc(k,1).Cost = CostFunction(popc(k,1).Position);
        popc(k,2).Cost = CostFunction(popc(k,2).Position);

        %calculate cost
        popc(k,1).Coverage = CalcCoverage(popc(k,1).Position, model);
        popc(k,2).Coverage = CalcCoverage(popc(k,2).Position, model);
    end
    popc=popc(:);
    
    %mutation
    popm=repmat(empty_individual,nm,1);
    for k=1:nm
        %select parent
        i=randi([1 nPop]);
        p=pop(i);
        
        %apply mutation
        popm(k).Position=Mutate(p.Position,mu);
        
        %evaluate mutant
        popm(k).Cost = CostFunction(popm(k).Position);

        %calculate cost
        popm(k).Coverage = CalcCoverage(popm(k).Position, model);
    end
    
    %create merged population
    pop=[pop
         popc
         popm];
     
    %sort population
    Costs=[pop.Cost];
    [Costs, SortOrder]=sort(Costs);
    pop=pop(SortOrder);
    
    %update worst cost
    WorstCost=max(WorstCost,pop(end).Cost);
    
    %truncation
    pop=pop(1:nPop);
    Costs=Costs(1:nPop);
    
    %store best solution ever found
    BestSol=pop(1);
    BestSol.Coverage = CalcCoverage(BestSol.Position, model);
    
    %store best cost ever found
    BestCost(it)=BestSol.Cost;

    %store coverage
    Coverages(it) = BestSol.Coverage;
    
    %store NFE
    nfe(it)=NFE;
    
    %show iteration information
    disp(['Iteration ' num2str(it) ': NFE = ' num2str(nfe(it)) ', Coverage = ' num2str(Coverages(it)*100) '%, Best Cost = ' num2str(BestCost(it))]);
    
    figure(1);
    pause(0.05);
    PlotSolution(BestSol.Position, model);
end

%% Results
figure;
plot(nfe,BestCost,'LineWidth',2);
xlabel('NFE');
ylabel('Cost');