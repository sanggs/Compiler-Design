#include<stdio.h>

int error()
{
    printf("ERROR");
}

int main()
{
	//Check flag value to see if search was succesful/unsuccesful
	int arr[10],beg,end,search,mid,flag;
	float a = -0.2;
	//Initialize values to search for value of 5 
	beg = 0;
	end = 9;
	flag = 0;
	search = 5;
	
	//Assumption : Array is sorted in ascending order
	
	for(;beg <= end;)
	{
		mid = (beg+end)/2;
		
		if(arr[mid] == search)
		{
			flag=1;   
		}
		
		else if ( arr[mid]>search)
		{
			end = mid - 1;
		}
		else
		{
			beg = mid + 1;
		}
	}
	
	return flag;
}
