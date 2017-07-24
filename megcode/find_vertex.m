function [dist meshind] = find_vertex(vertices, point)

% function to find closest vertex in mesh

% compute geometric distance to each point in mni vertex list
gd =  sqrt((vertices(:,1) - point(1)).^2 + (vertices(:,2) - point(2)).^2 ...
      + (vertices(:,3) - point(3)).^2);

% return closest index
[dist meshind] = min(gd);

end