####################################################################################
# Educational Use License                                                          #
#                                                                                  #
# This software is provided for educational and research purposes only.            #
# You may use, modify, and distribute this code only in a non-commercial           #
# educational setting. Any commercial use, including but not limited to            #
# selling, licensing, or incorporating this software into commercial products,     #
# is strictly prohibited without explicit permission from the author.              #
#                                                                                  #
# For inquiries regarding commercial use, please contact [leo92kgred@gmail.com].   #
####################################################################################

function [A,B,C,D]=tf2ss_se (num,den)
	if(nargin == 0)
		disp("No values provided\n");
	elseif(size(num,2)==size(den,2))
		disp("don't support\n");
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
