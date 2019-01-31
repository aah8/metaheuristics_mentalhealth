function model=CreateNationalModel()
    %% Customer Data
    
    % demand
    demand = xlsread('mental health database.xlsx','data','G2:G47'); %load demand column
    d = demand'; %transpose column to row
    
    %x coordinate for state
    state_xcord = xlsread('mental health database.xlsx','data','C2:C47');
    yc = state_xcord';
    
    %y coordinate for state
    state_ycord = xlsread('mental health database.xlsx','data','D2:D47');
    xc = state_ycord';
    
    %number of nodes (states, "customers")
    N=numel(d);
    
    %% Server Data
    
    %capacity
    capacity = xlsread('mental health database.xlsx','data','I2:I47');
    capacity = capacity';
    
    %cost
    cost = xlsread('mental health database.xlsx','data','H2:H47');
    c = cost';
    
    %x coordinate for server
    capital_xcord = xlsread('mental health database.xlsx','data','E2:E47');
    ys = capital_xcord';
    
    %y coordinate for server
    capital_ycord = xlsread('mental health database.xlsx','data','F2:F47');
    xs = capital_ycord';
    
    %number of servers (hubs)
    M = numel(xs);
    
    %budget
    budget = 1000000000;
    
    %D_ij matrix (distances from node i to hub j)
    D=zeros(N,M);
    for i=1:N
        for j=1:M
            D(i,j)=norm([state_xcord(i)-capital_xcord(j) state_xcord(i)-capital_xcord(j)],2);
        end
    end
    
    model.N=N;                          %number of states with demand
    model.M=M;                          %number of hubs (clinics)
    model.d=d;                %demand for nodes
    model.xs=xs;      %x coordinate for state
    model.ys=ys;      %y coordinate for state
    model.c=c;                    %cost for hubs (clinics)
    model.xc=xc;  %x coordintae for state capital (clinic)
    model.yc=yc;  %y coordinate for state capital (clinic)
    model.D=D;                          %D_ij matrix
    model.capacity = capacity;
    model.budget = budget;
end