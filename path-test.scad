a=[for (i=[0:9]) [10*sin(10*i),10*cos(10*i)] ];
b=[for (i=[10:18]) [10*sin(10*i),-10+10*cos(10*i)] ];
c=[for (i=[19:27]) [-10+10*sin(10*i),-10+10*cos(10*i)] ];
d=[for (i=[28:35]) [-10+10*sin(10*i),10*cos(10*i)] ];
e=concat(a,b,c,d);
echo(e);
polygon(e);