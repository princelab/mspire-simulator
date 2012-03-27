
#C++ code:
require 'ffi-inliner'
module RThelper
  extend Inliner
  inline do |builder|
    builder.use_compiler Inliner::Compilers::GPlusPlus
    builder.map 'char *' => 'string'
    builder.c_raw <<-code
      #include <iostream>
      #include <string>
      #include <cstdlib>
      #include <cmath>
      #include <cstdlib>
      #include <math.h>
      #define PI 3.14159  
      using namespace std;
    code
    builder.c <<-code
    float gaussian(float x, float mu, float sd){
      return ((1/(sqrt(2*(PI)*(pow(sd,2)))))*(exp(-((pow((x-mu),2))/(pow((2*sd),2))))));
    } 
    code
    builder.c <<-code
    float gaussianI(float x, float mu, float sd, float h){
      return h*(exp(-((pow((x-mu),2))/(pow(sd,2)))));
    } 
    code
    builder.c <<-code
    float RandomFloat(float a, float b){
      float random = ((float) rand()) / (float) RAND_MAX;
      float diff = b - a;
      float r = random * diff;
      return a + r;
    }
    code
  end
end
