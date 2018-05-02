function R = createRz(theta)

cot = cos(theta);
sit = sin(theta);

R = [cot -sit 0;...
     sit cot 0;...
     0 0 1];
