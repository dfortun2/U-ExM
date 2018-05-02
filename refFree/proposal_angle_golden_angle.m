function theta = proposal_angle_golden_angle(i,n)

a1=0.3803;
a2=0.5249;
a3=0.7245;

theta(1)=mod(a1*i,1)*360;
theta(2)=mod(a2*i,1)*360;
theta(3)=mod(a3*i,1)*360/n;
