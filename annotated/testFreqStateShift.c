#include <stdio.h>
#include <stdio.h>      /* printf */
#include <string.h>     /* strcat */
#include <stdlib.h>     /* strtol */

const char *byte_to_binary(int x){
		static char b[9];
		b[0] = '\0';
		int z;
		for (z = 128; z > 0; z >>= 1){
				strcat(b, ((x & z) == z) ? "1" : "0");
		}
		return b;
}

void bin(int a)
{
		 if(a/2==1)
				  printf("1");
		  else
					 bin(a/2);
			 printf("%d",a%2);
}

int main(){

		unsigned int _rotl(const unsigned int value, int shift) {
				    if ((shift &= sizeof(value)*8 - 1) == 0)
								      return value;
						    return (value << shift) | (value >> (sizeof(value)*8 - shift));
		}

		unsigned int pinGroup = (25175000 + 1600)/4;
		unsigned int clkfreq = 80000000;
		unsigned int freqState = 1;
 
		printf("start:\npinGroup %i, freqState %i, clkFreq %i\n",pinGroup,freqState,clkfreq);
		int i = 0;
		for (i; i < 32; i++){
				pinGroup  = pinGroup << 1;
				_rotl(freqState,1);
				if(pinGroup >= clkfreq){
						pinGroup -= clkfreq;
						freqState += 1;
				}
		printf("i= %i\n\tpinGroup %i, freqState %i, clkFreq %i\n",i,pinGroup,freqState,clkfreq);
		bin(pinGroup);printf("\n");
		}
		printf("end:\npinGroup %i, freqState %i\n",pinGroup,freqState);
		return 0;
}

