prompt = "how many elements do you have";
n= input(prompt);
%elementNumbers=zeros(n,6);
elementNumbers=(sym('elementNumbers',[n 6]));
elementType= strings(n,1);
% get input
for i=1:n
    for j=1:6
       if j==1 
           disp("ID:");
       end
       
       if j==2 
           disp("PosNode:");
       end
       
       if j==3 
           disp("NegNode:");
       end
       
       if j==4 
           disp("Value:");
       end
       
       if j==5 
           disp("VolRes:");
       end
       
       if j==6 
           disp("CurRes:");
       end
       
       x=input("");
       elementNumbers(i,j) = x;
    end
    y=input("Type:");
    elementType(i,1) = y;
end
% get maxnode
posnode=elementNumbers(1:n,2);
 Mp = max(posnode,[],'all');
 negnode=elementNumbers(1:n,3);
 
 Mn = max(negnode,[],'all');
 maxnode=max(Mn,Mp);

 vCounter=0;

% number of voltage
 for i=1:n
      if isequal(elementType(i),"v")
       vCounter=vCounter+1;
      end     
 end
 %matrix voltage 
 Vol=zeros(vCounter,6);
 t=0;
  for i=1:n
     if isequal(elementType(i),"v")
         t=t+1;
         Vol = [Vol;elementNumbers(t,1:6)];
     end
  end
% error 

 for i=1:vCounter
     for j=i+1:vCounter-1
       if (Vol(i,2)==Vol(j,2)||Vol(i,2)==Vol(j,3))&&(Vol(i,3)==Vol(j,2)||Vol(i,3)==Vol(j,3))
   
              disp("error");
         
       end
     end
 end
 syms w
%  find matrix B
 %tempB = zeros(maxnode,vCounter);
 tempB=(sym('tempB',[double(maxnode) double(vCounter)]));
 tempB(1:maxnode,1:vCounter)=0;
 
 j=0;
 for i=1:n
      if isequal(elementType(i),"v")
          j=j+1;
          tempB(elementNumbers(i,2),j)=1;
          tempB(elementNumbers(i,3),j)=-1;     
      end     
 end
%  delete source node
  B=tempB(1:maxnode-1,1:vCounter);
  
  c=B.';
  
 
%   find G
  G=(sym('G',[double(maxnode-1) double(maxnode-1)]));
 % G=zeros(maxnode-1,maxnode-1);
 G(1:maxnode-1,1:maxnode-1)=0;
  
  for z=1:n
      for i=1:maxnode-1
          for j=1:maxnode-1
              if i==j
                  if elementNumbers(z,2)==i||elementNumbers(z,3)==i
                  if elementType(z,1)=="r"
                      G(i,j)=G(i,j)+1/(elementNumbers(z,4));
                     
                  end
                  if elementType(z,1)=="l"
                      G(i,j)=G(i,j)+1/(complex(0,1)*w*(elementNumbers(z,4)));
                     
                  end
                  if elementType(z,1)=="c"
                       G(i,j)=G(i,j)+complex(0,1)*w*(elementNumbers(z,4));
                  end
                  end
              end
              if (elementNumbers(z,2)==i && elementNumbers(z,3)==j)||(elementNumbers(z,2)==j && elementNumbers(z,3)==i)
                  if elementType(z,1)=="r"
                      G(i,j)=G(i,j)+(-1)/(elementNumbers(z,4));
                  end
                  if elementType(z,1)=="l"
                      G(i,j)=G(i,j)+(-1)/complex(0,1)*w*(elementNumbers(z,4));
                  end
                  if elementType(z,1)=="c"
                       G(i,j)=G(i,j)+(-1)*complex(0,1)*w*(elementNumbers(z,4));
                  end
              end
          end
      end
  
  
  end
%   error
  counter=0;
  for j=1:maxnode-1
      if G(j,j)==0
      for i=1:n
          if (elementNumbers(i,2)==j|| elementNumbers(i,3)==j)&& elementType(i,1)=="i"
             counter=counter+1;
             if counter>1
              disp("error");
              counter=0;
              
             end
          end
      end
      end
  end


  %%%finding the current sources corresponding to each node 
  tempZ = zeros(double(maxnode),1);
  for i=1:n
      if isequal(elementType(i),"i")
        
          tempZ(elementNumbers(i,2),1)=tempZ(elementNumbers(i,2),1) - elementNumbers(i,4);
          tempZ(elementNumbers(i,3),1)=tempZ(elementNumbers(i,3),1) + elementNumbers(i,4);
         
      end     
  end
  Z = tempZ(1:maxnode-1,1);
  
 %%%finding the voltage sources to be added to z
 for i=1:n
     if isequal(elementType(i),"v")
         Z = [Z;elementNumbers(i,4)];
     end
 end
% %  finding matrix A
   A=(sym('A',[double(maxnode-1+vCounter),double(maxnode-1+vCounter)]));
 % A=zeros(maxnode-1+vCounter,maxnode-1+vCounter);
   A(1:maxnode-1+vCounter,1:maxnode-1+vCounter) =0;
  A(1:maxnode-1,1:maxnode-1)=G(1:maxnode-1,1:maxnode-1);
  A(1:maxnode-1,maxnode:maxnode-1+vCounter)=B(1:maxnode-1,1:vCounter);
  A(maxnode:maxnode-1+vCounter,1:maxnode-1)=c(1:vCounter,1:maxnode-1);
% %   check
  X=inv(A)*Z;
  p=0;
% %   finding volres & curres
  for i=1:n
      if elementNumbers(i,2)~=maxnode && elementNumbers(i,3)~=maxnode
           elementNumbers(i,5)=X(elementNumbers(i,2),1)-X(elementNumbers(i,3),1);
          if elementType(i,1)=="r"
              elementNumbers(i,6)= elementNumbers(i,5)/ elementNumbers(i,4);
          end
          if elementType(i,1)=="l"
             elementNumbers(i,6)= elementNumbers(i,5)/(complex(0,1)*w*(elementNumbers(i,4)));
          end
          if elementType(i,1)=="c"
             elementNumbers(i,6)= elementNumbers(i,5)/(1/(complex(0,1)*w*(elementNumbers(i,4))));
          end
            if elementType(i,1)=="i"
              elementNumbers(i,6)= elementNumbers(i,4);
            end
           if elementType(i,1)=="v"
               p=p+1;
              elementNumbers(i,6)= X(maxnode-1+p,1);
           end
      end
      if elementNumbers(i,2)==maxnode
         elementNumbers(i,5)=-X(elementNumbers(i,3),1);
           if elementType(i,1)=="r"
              elementNumbers(i,6)= elementNumbers(i,5)/ elementNumbers(i,4);
           end
           if elementType(i,1)=="l"

elementNumbers(i,6)= elementNumbers(i,5)/(complex(0,1)*w*(elementNumbers(i,4)));
           end
           if elementType(i,1)=="c"
              elementNumbers(i,6)= elementNumbers(i,5)/(1/(complex(0,1)*w*(elementNumbers(i,4))));
           end
            if elementType(i,1)=="i"
              elementNumbers(i,6)= elementNumbers(i,4);
            end
            if elementType(i,1)=="v"
               p=p+1;
              elementNumbers(i,6)= X(maxnode-1+p,1);
           end
      end
       if elementNumbers(i,3)==maxnode
           elementNumbers(i,5)=X(elementNumbers(i,2),1);
           if elementType(i,1)=="r"
              elementNumbers(i,6)= elementNumbers(i,5)/ elementNumbers(i,4);
           end
           if elementType(i,1)=="l"
              elementNumbers(i,6)= elementNumbers(i,5)/(complex(0,1)*w*(elementNumbers(i,4)));
           end
           if elementType(i,1)=="c"
              elementNumbers(i,6)= elementNumbers(i,5)/(1/(complex(0,1)*w*(elementNumbers(i,4))));
           end
           if elementType(i,1)=="i"
              elementNumbers(i,6)= elementNumbers(i,4);
           end
            if elementType(i,1)=="v"
               p=p+1;
              elementNumbers(i,6)= X(maxnode-1+p,1);
           end
      end
  end
while true
    disp("Enter the element ID:");
    elementID = input("");
    disp("Enter the Frequency start range:");
    frequencyStart = input("");
    disp("Enter the Frequency step:");
    frequencyStep = input("");
    disp("Enter the Frequency end range:");
    frequencyEnd = input("");
    if frequencyStart==0&&frequencyStep==1&&frequencyEnd==0
        volres=zeros(1);
        volres(1,1)=volres(1,1)+subs(elementNumbers(elementID,5),w,0.000000000001*2*pi);
        
        curres=zeros(1);
        curres(1,1)=curres(1,1)+subs(elementNumbers(elementID,6),w,0.000000000001*2*pi);
        
   
    else
   
    volres=zeros(1,1+(frequencyEnd-frequencyStart)/frequencyStep);
    absVolres=abs(volres);
    curres=zeros(1,1+(frequencyEnd-frequencyStart)/frequencyStep);
    absCurres=abs(curres);
    for i=frequencyStart:frequencyStep:frequencyEnd
        
        volres(1,i) = volres(1,i)+subs(elementNumbers(elementID,5),w,i*2*pi);
        absVolres=abs(volres);
        curres(1,i) = curres(1,i)+subs(elementNumbers(elementID,6),w,i*2*pi);
        absCurres=abs(curres);
    end
    end
    disp("========================:Voltage response:=============================================");
    disp(volres);
    disp("========================:Current response:=============================================");
    disp(curres);
    
   
    plot(frequencyStart:frequencyStep:frequencyEnd,absVolres);
    title('Voltage response');
    figure;
    plot(frequencyStart:frequencyStep:frequencyEnd,absCurres);
    title('Current response');
    figure;
    
end
 
