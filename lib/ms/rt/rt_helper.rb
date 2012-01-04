
#C++ code:
require 'ffi-inliner'
module RThelper
   extend Inliner
   inline do |builder|
     builder.use_compiler Inliner::Compilers::GPlusPlus
     builder.c_raw <<-code
       #include <iostream>
       #include <string>
       #include <cstdlib>
       #include <cmath>
       using namespace std;
       code
       builder.map 'char *' => 'string'
       builder.c <<-code
       #include <cstdlib>
       #include <math.h>
       #define PI 3.14159
          float randn( float m, float s){                                      
			  float x1, x2, w, y1;   
			  static float y2;   
			  static int use_last   = 0;   
			  static float rand_max = (float)( RAND_MAX);   
			   
			  if ( use_last){            /* use value from previous call */      
				y1 = y2;   
				use_last = 0;   
			  }   
			  else{   
				do{     
				  x1 = 2.0 * (float)( rand()) / rand_max - 1.0;   
				  x2 = 2.0 * (float)( rand()) / rand_max - 1.0;   
				  w = x1 * x1 + x2 * x2;   
				} while ( w >= 1.0);   
			   
				w  = sqrt( (-2.0 * log( w) ) / w );   
				y1 = x1 * w;   
				y2 = x2 * w;   
				use_last = 1;   
			  }   
			   
			  return ( m + y1 * s);   
			}		
	   code
       builder.c <<-code
			
		float gaussian(float mz, float mu, float sd){
			return ((1/(sqrt(2*(PI)*(pow(sd,2)))))*(exp(-((pow((mz-mu),2))/(pow((2*sd),2))))));
		} 
       code
       builder.c <<-code
       
         float emg(float a,float b,float c,float d,float x){
			float one, two, three, four;
			one = (a*c*(sqrt(2*PI)))/(2*d);
			two = (((b-x)/d)*((pow(c,2))/(pow((2*d),2))));
			three = (d/abs(d));
			four = ((b-x)/(sqrt(2*c)))+(c/(sqrt(2*d)));
			
			return one*exp(two)*(three-erf(four));
         }
       code
  end
end
