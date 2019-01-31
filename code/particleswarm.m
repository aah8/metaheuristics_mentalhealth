clc;
clear;
close all;

%% Problem Definition

global NFE;
NFE = 0;

model = CreateNationalModel();         %create model
f=CreateRandomSolution(model);  %create random solution

CostFunction=@(f) MyCost(f, model);        % Cost Function

nVar = model.M;             % Number of Decision Variables

VarSize=[1 nVar];   % Size of Decision Variables Matrix

VarMin=0;         % Lower Bound of Variables
VarMax=1;         % Upper Bound of Variables


%% PSO Parameters

MaxIt=500;      % Maximum Number of Iterations

nPop=100;        % Population Size (Swarm Size)

% w=1;            % Inertia Weight
% wdamp=0.99;     % Inertia Weight Damping Ratio
% c1=2;           % Personal Learning Coefficient
% c2=2;           % Global Learning Coefficient

% Constriction Coefficients
phi1=2.1;
phi2=2.0;
phi=phi1+phi2;
chi=2/(phi-2+sqrt(phi^2-4*phi));
w=chi;                                  %inertia weight
wdamp=0.99;                             %inertia weight damping ratio
c1=chi*phi1;                            %personal learning coefficient
c2=chi*phi2;                            %global learning coefficient

% Velocity Limits
VelMax=1;
VelMin=-1;

%% Initialization

empty_particle.Coverage=[];
empty_particle.Position=[];
empty_particle.Cost=[];
empty_particle.Velocity=[];
empty_particle.Best.Position=[];
empty_particle.Best.Cost=[];
empty_particle.Best.Coverage=[];

particle=repmat(empty_particle,nPop,1);

GlobalBest.Cost=inf;

for i=1:nPop

    % Initialize Position
    particle(i).Position=randi([0 1],VarSize);

    % Initialize Velocity
    particle(i).Velocity=zeros(VarSize);

    % Evaluation
    particle(i).Cost=CostFunction(particle(i).Position);

    % Update Personal Best
    particle(i).Best.Position=particle(i).Position;
    particle(i).Best.Cost=particle(i).Cost;

    % Update Global Best
    if particle(i).Best.Cost<GlobalBest.Cost

        GlobalBest=particle(i).Best;

    end

end

BestCost=zeros(MaxIt,1);

nfe=zeros(MaxIt,1);


%% PSO Main Loop

for it=1:MaxIt

    for i=1:nPop

        % Update Velocity
        particle(i).Velocity = w*particle(i).Velocity ...
            +c1*rand(VarSize).*(particle(i).Best.Position-particle(i).Position) ...
            +c2*rand(VarSize).*(GlobalBest.Position-particle(i).Position);

        % Apply Velocity Limits
        particle(i).Velocity = max(particle(i).Velocity,VelMin);
        particle(i).Velocity = min(particle(i).Velocity,VelMax);

        % Update Position
        particle(i).Position = particle(i).Position + particle(i).Velocity;

        % Velocity Mirror Effect
        IsOutside=(particle(i).Position<VarMin | particle(i).Position>VarMax);
        particle(i).Velocity(IsOutside)=-particle(i).Velocity(IsOutside);

        % Apply Position Limits
        particle(i).Position = max(particle(i).Position,VarMin);
        particle(i).Position = min(particle(i).Position,VarMax);

        % Evaluation
        particle(i).Cost = CostFunction(particle(i).Position);

        %get coverage
        particle(i).Coverage = CalcCoverage(particle(i).Position, model);

        % Update Personal Best
        if particle(i).Cost<particle(i).Best.Cost

            particle(i).Best.Position=particle(i).Position;
            particle(i).Best.Cost=particle(i).Cost;
            particle(i).Best.Coverage = CalcCoverage(particle(i).Best.Position, model);

            % Update Global Best
            if particle(i).Best.Cost<GlobalBest.Cost
                GlobalBest=particle(i).Best;
            end
        end
    end

    BestCost(it)=GlobalBest.Cost;

    %store coverage
    Coverages(it) = GlobalBest.Coverage;

    nfe(it)=NFE;

    disp(['Iteration ' num2str(it) ': NFE = ' num2str(nfe(it)) ', Best Cost = ' num2str(BestCost(it))]);

    w=w*wdamp;
    
    figure(1);
    pause(0.05);
    PlotSolution(GlobalBest.Position, model);
end

%% Results

figure;
plot(nfe,BestCost,'LineWidth',2);
%semilogy(nfe,BestCost,'LineWidth',2);
xlabel('NFE');
ylabel('Best Cost');

