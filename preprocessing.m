function f
I=imread('C:/fingerprint.jpg');
[m,n]=size(I);
I=double(I);
M=0;
var=0;
for x=1:m
    for y=1:n
    M=M+I(x,y);
    end
end
M1=M/(m*n);
for x=1:m
for y=1:n
var=var+(I(x,y)-M1).^2;
end
end
var1=var/(m*n);
for x=1:m
for y=1:n
if I(x,y)>=M1
I(x,y)=150+sqrt(2000*(I(x,y)-M1)/var1);
else
I(x,y)= 0; %150-sqrt(2000*( I(x,y)-M1)/var1)

end
end
end


%分成多个3*3小块儿并算其平均值及方差
M =3;%3*3 
H = floor(m/M);
  L= floor(n/M);
    aveg1=zeros(H,L); 
var1=zeros(H,L);
for x=1:H;
for y=1:L;
aveg=0;
var=0;
for i=1:M;
for j=1:M;
aveg=I(i+(x-1)*M,j+(y-1)*M)+aveg;
end
end
aveg1(x,y)=aveg/(M*M);
for i=1:M;
for j=1:M;
var=(I(i+(x-1)*M,j+(y-1)*M)-aveg1(x,y)).^2+var;
end
end
var1(x,y)=var/(M*M);
end
end

%所有块的平均值及所有块的方差
Gmean=0;
Vmean=0;
for x=1:H
for y=1:L
Gmean=Gmean+aveg1(x,y);
Vmean=Vmean+var1(x,y);
end
end
Gmean1=Gmean/(H*L); 
Vmean1=Vmean/(H*L);





%均值方差分割法
%or背景分割法
gtemp=0;
gtotle=0;
vtotle=0;
vtemp=0; 
for x=1:H 
    for y=1:L   
    if Gmean1>aveg1(x,y)    
        gtemp=gtemp+1;         
    gtotle=gtotle+aveg1(x,y);    
    end        
    if Vmean1<var1(x,y)   
         vtemp=vtemp+1;      
       vtotle=vtotle+var1(x,y);    
    end    
    end 
end  
G1=gtotle/gtemp;
V1=vtotle/vtemp;   
   gtemp1=0;
gtotle1=0;
vtotle1=0;
vtemp1=0; 
for x=1:H  
   for y=1:L
        if G1<aveg1(x,y) 
           gtemp1=gtemp1-1;
             gtotle1=gtotle1+aveg1(x,y);
        end 
        if 0<var1(x,y)<V1  
          vtemp1=vtemp1+1;   
          vtotle1=vtotle1+var1(x,y);  
        end   
   end
 end
  G2=gtotle1/gtemp1;
V2=vtotle1/vtemp1;   
  e=zeros(H,L); 
for x=1:H    
    for y=1:L       
  if aveg1(x,y)>G2 && var1(x,y)<V2  
          e(x,y)=1;     
   end       
  if aveg1(x,y)< G1-100 && var1(x,y)< V2
            e(x,y)=1;    
  end  
    end 
end
for x=2:H-1  
   for y=2:L-1
         if e(x,y)==1   
           if e(x-1,y) + e(x-1,y+1) +e(x,y+1) + e(x+1,y+1) + e(x+1,y) + e(x+1,y-1) + e(x,y-1) + e(x-1,y-1) <=4       
            e(x,y)=0;     
           end      
         end    
   end
 end
    Icc = ones(m,n);
 for x=1:H 
   for y=1:L  
      if  e(x,y)==1 
          for i=1:M   
          for j=1:M   
               I(i+(x-1)*M,j+(y-1)*M)=G1;
                 Icc(i+(x-1)*M,j+(y-1)*M)=0;  
          end    
          end   
      end   
   end 
end



%二值化 
temp=(1/9)*[1 1 1;1 1 1;1 1 1];%%模板系数     均值滤波  
Im=double(I);
In=zeros(m,n); 
for a=2:m-1;  
    for b=2:n-1; 
        In(a,b)=Im(a-1,b-1)*temp(1,1)+Im(a-1,b)*temp(1,2)+Im(a-1,b+1)*temp(1,3)+Im(a,b-1)*temp(2,1)+Im(a,b)*temp(2,2)+Im(a,b+1)*temp(2,3)+Im(a+1,b-1)*temp(3,1)+Im(a+1,b)*temp(3,2)+Im(a+1,b+1)*temp(3,3);    
    end
end  
I=In; Im=zeros(m,n);
for x=5:m-5;   
for y=5:n-5;   
    		sum1=I(x,y-4)+I(x,y-2)+I(x,y+2)+I(x,y+4); 
sum2=I(x-2,y+4)+I(x-1,y+2)+I(x+1,y-2)+I(x+2,y-4);    
 		sum3=I(x-2,y+2)+I(x-4,y+4)+I(x+2,y-2)+I(x+4,y-4); 
    		sum4=I(x-2,y+1)+I(x-4,y+2)+I(x+2,y-1)+I(x+4,y-2); 
    		sum5=I(x-2,y)+I(x-4,y)+I(x+2,y)+I(x+4,y); 
sum6=I(x-4,y-2)+I(x-2,y-1)+I(x+2,y+1)+I(x+4,y+2);     
sum7=I(x-4,y-4)+I(x-2,y-2)+I(x+2,y+2)+I(x+4,y+4);    
 		sum8=I(x-2,y-4)+I(x-1,y-2)+I(x+1,y+2)+I(x+2,y+4);     
sumi=[sum1,sum2,sum3,sum4,sum5,sum6,sum7,sum8];     
summax=max(sumi);    
 		summin=min(sumi);      
summ=sum(sumi);     
 b=summ/8; 
     if (summax+summin+ 4*I(x,y))> (3*summ/8)                   
      	sumf = summin; 
        else 
sumf = summax;
    end
if   sumf > b
Im(x,y)=128;
else
Im(x,y)=255;
end
end
end
for i=1:m
for j =1:n
Icc(i,j)=Icc(i,j)*Im(i,j);
end
end
for i=1:m
for j =1:n
if (Icc(i,j)==128)
Icc(i,j)=0;
else
Icc(i,j)=1;
end;
end
end
figure,imshow(double(Icc));title('二值化');


u=Icc; 
[m,n]=size(u); %去除空洞 
for x=2:m-1 
for y=2:n-1 
    if u(x,y)==0 
    if u(x,y-1)+u(x-1,y)+u(x,y+1)+u(x+1,y)>=3 
        u(x,y)=1; 
    end 
    else 
u(x,y)=u(x,y);
    end 
end 
end 
figure,imshow(u)

%title('去除毛刺') 
for a=2:m-1 
for b=2:n-1
 if u(a,b)==1
 if abs(u(a,b+1)-u(a-1,b+1))+abs(u(a-1,b+1)-u(a-1,b))+abs(u(a-1,b)-u(a-1,b-1))+abs(u(a-1,b-1)-u(a,b-1))+abs(u(a,b-1)-u(a+1,b-1))+abs(u(a+1,b-1)-u(a+1,b))+abs(u(a+1,b)-u(a+1,b+1))+abs(u(a+1,b+1)-u(a,b+1))~=1 && (u(a,b+1)+u(a-1,b+1)+u(a-1,b))*(u(a,b-1)+u(a+1,b-1)+u(a+1,b))+(u(a-1,b)+u(a-1,b-1)+u(a,b-1))*(u(a+1,b)+u(a+1,b+1)+u(a,b+1))==0
                     u(a,b)=0; 
end 
end 
end
end
figure,imshow(u) %title('去除空洞')

v=~u; 
se=strel('square',1); 
fo=imopen(v,se); 
v=imclose(fo,se); %对图像进行开操作和闭操作 
w=bwmorph(v,'thin',Inf);%对图像进行细化 
figure,imshow(w) 
title('细化图')
