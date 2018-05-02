function R = createRx(theta)

cot = cos(theta);
sit = sin(theta);

R = [1 0 0;...
    0 cot -sit;...
    0 sit cot];
