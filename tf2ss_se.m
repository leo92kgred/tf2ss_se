####################################################################################
# Educational Use License                                                          #
#                                                                                  #
# This software is provided for educational purposes only.                         #
# You may use, modify, and distribute this code only in a non-commercial           #
# educational setting. Any commercial use, including but not limited to            #
# selling, licensing, or incorporating this software into commercial products,     #
# is strictly prohibited without explicit permission from the author.              #
#                                                                                  #
# For inquiries regarding commercial use, please contact [leo92kgred@gmail.com].   #
####################################################################################

function [A,B,C,D]=tf2ss_se (num,den)
	[zero_x,zero_y_num]=find(num==0);
	[zero_x,zero_y_den]=find(den==0);
	if(nargin == 0)
		disp("No values provided\n");disp("No values provided\n");disp("No values provided\n");
	elseif(size(num,2)==size(den,2))
		disp("don't support\n");disp("don't support\n");disp("don't support\n");
	elseif(zero_y_num>=1 || zero_y_den>=1)
		disp("don't support\n");disp("don't support\n");disp("don't support\n");
  	elseif((size(den,1)>=2)
		disp("don't support\n");disp("don't support\n");disp("don't support\n");
  	elseif(den(1)!=1)
		disp("don't support\n");disp("don't support\n");disp("don't support\n");
  	else
	
		A=zeros(size(den,2)-1);
		B=zeros(1,size(den,2)-1)';
		C=zeros(1,size(den,2)-1);
		D=0;
		
		for i=1:((size(den,2)-1) -1)
			if (i==(size(den,2)-1)-1) A(i,i+1)=den((size(den,2))-i); 
			else A(i,i+1)=den((size(den,2))-i)/den(((size(den,2)-1)-i));
			end
		end
		
		for i=1:(size(den,2)-1)
			if (i==(size(den,2)-1)) A((size(den,2)-1),i)=-den((size(den,2))+1-i); 
			else A((size(den,2)-1),i)=-den((size(den,2)+1)-i)/den(size(den,2)-i);
			end
		end
		
		B(size(den,2)-1,1)=1;
		
		for i=1:(size(num,2))
			if (1==(size(den,2))) C(1,i)=num(size(num,2)+1-i); 
			else C(1,i)=num(size(num,2)+1-i)/den(size(den,2)-i);
			end
		end
		
		D=0;
	endif

endfunction
