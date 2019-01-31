function model=CreateModel()

    % Customer Data
    %demand
    d=[42 46 10 47 34 9 17 30 49 49 12 49 49 27 41 11 24 47 41 49 35 6 44 47 36 39 39 23 35 12 37 6 17 7 9 42 36 19 48 6];
    %x coordinate for customer
    xc=[43 38 76 79 18 48 44 64 70 75 27 67 65 16 11 49 95 34 58 22 75 25 50 69 89 95 54 13 14 25 84 25 81 24 92 34 19 25 61 47];
    %y coordinate for customer
    yc=[35 83 58 54 91 28 75 75 38 56 7 5 53 77 93 12 56 46 1 33 16 79 31 52 16 60 26 65 68 74 45 8 22 91 15 82 53 99 7 44];
    %number of nodes (customers)
    N=numel(d);
    
    % Server Data
    %cost
    c=[9104 8286 9817 9075 9238 7453 7262 9735 8715 7040 7752 9718 9033 9889 8737 8431 8548 7437 9083 8540];
    %x coordinate for server
    xs=[10 96 0 77 81 86 8 39 25 80 43 91 18 26 14 13 86 57 54 14];
    %y coordinate for server
    ys=[85 62 35 51 40 7 23 12 18 23 41 4 90 94 49 48 33 90 36 11];
    %number of servers (hubs)
    M=numel(xs);
    
    %D_ij matrix (distances from node i to hub j)
    D=zeros(N,M);
    for i=1:N
        for j=1:M
            D(i,j)=norm([xc(i)-xs(j) yc(i)-ys(j)],2);
        end
    end
    
    model.N=N;      %number of customers (nodes)
    model.M=M;      %number of servers (hubs)
    model.d=d;      %demand for nodes
    model.xc=xc;    %x coordinate for node
    model.yc=yc;    %y coordinate for node
    model.c=c;      %cost for hubs
    model.xs=xs;    %x coordintae for hub
    model.ys=ys;    %y coordinate for hub
    model.D=D;      %D_ij matrix


end