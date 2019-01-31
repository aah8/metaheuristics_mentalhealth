function [z, sol]=MyCost(f,model)

    global NFE;
    if isempty(NFE)
        NFE=0;
    end
    
    NFE=NFE+1;

    if all(f==0)
        z=inf;
        sol=[];
        return;
    end

    N=model.N;
    D=model.D;
    d=model.d;
    c=model.c;
    capacity = model.capacity;
    budget = model.budget;

    
    %populate a matrix which indicates which hub serves which nodes
    [~, temp] = sort(D(:));                 %sort the D matrix in ascending order
    [node, hub] = ind2sub(size(D), temp);   %store the nodes and hubs that are closest in distance
    local_cap = capacity.*f;                %local capacity
    local_d = d;                            %local demand
    D_new = zeros(size(D));                 
    
    
    for j = 1 : length(node) %for each node
        if f(hub(j)) == 1 && local_cap(hub(j))> local_d(node(j))        %if a hub is open and the hub still has capacity
            D_new(node(j), hub(j)) = 1;                                 %place a 1 in the Dnew matrix, assigning that node to that hub
            local_cap(hub(j)) = local_cap(hub(j)) - local_d(node(j));   %reduce the local capacity of that hub
            local_d(node(j)) = Inf;                                     %fulfill the demand for that node (make it impossible for other hubs to be assigned to that node)
        end
    end
    
    a = sum(D_new, 2)';                 %tells us whether demand node is satisfied or not
    d_satisfied = sum(a.*d);            %calculate the satisfied demand
    coverage = d_satisfied / sum(d);    %calculate the total demand cooverage
    
   % ensure at least 80% coverage
    if (coverage < 0.8)
        z=inf;
        sol=[];
        return;
    end

    facilities_cost = sum(f.*c);    %calculate the cost of building the facilities
    if facilities_cost >= budget    %ensure the cost of building these facilities is within the budget
        z=inf;
        sol=[];
        return;
    end
    
    Dmin=zeros(1,N);
    A=zeros(1,N);
    
    for i = 1 : N
        if a(i) > 0
            [r, c] = find(D_new(i,:));  %find the 
            Dmin(i) = D(r, c);          %
            A(i) = c;                   %
        end
    end
    
    z1 = sum(d.*Dmin);                  
    z2 = sum(f.*c);                     
    z3 = (1 - coverage) * sum(d);       %penalty for not covering demand

    % Objective Function Weights
    w1 = 1;
    w2 = .1;
    w3 = .0001;
    z = w1*z1 + w2*z2 + w3*z3;
    
    sol.A=A;
    sol.Dmin=Dmin;
    sol.z1=z1;
    sol.z2=z2;
    sol.z=z;
    sol.coverage = coverage;
end