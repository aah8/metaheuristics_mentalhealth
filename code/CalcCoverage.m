function [cov]=CalcCoverage(f,model)

    if all(f==0)
        cov=inf;
        sol=[];
        return;
    end

    N=model.N;
    D=model.D;
    d=model.d;
    c=model.c;
    capacity = model.capacity;

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
            local_d(node(j)) = Inf;                                     %fulfill the demand for that node (make it impossible for other hubs to be assigned to that node
        end
    end
    
    a = sum(D_new, 2)';                 %tells us whether demand node is satisfied or not
    d_satisfied = sum(a.*d);            %calculate the satisfied demand
    cov = d_satisfied / sum(d);         %calculate the total demand coverage
end