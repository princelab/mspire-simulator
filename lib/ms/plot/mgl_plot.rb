
require 'ffi-inliner'
module Mgl_Plot
   extend Inliner
   inline do |builder|
     builder.use_compiler Inliner::Compilers::GPlusPlus
     builder.library "mgl-fltk"
     builder.c_raw <<-code
       #include <string>
	   #include <stdlib.h>
	   #include <iostream>
	   #include <vector>
	   #include <mgl/mgl_fltk.h>
	   #define PI 3.1415927
       using namespace std;
       vector<float> * lines = new vector<float>;
       vector<float> * surf = new vector<float>;
       float tx, tx2, ty, ty2, tz, tz2;
       float rX, rY;
       mglData nx(30,30,30), ny(30,30,30), nz(30,30,30), b(30,30,30) ,c(30,30,30) ,d(30,30,30);
       code
       builder.c <<-code
		  float newPlot(float rotateX, float rotateY){
			rX = rotateX;
			rY = rotateY;
			return 0;
		  }
       code
       builder.c <<-code
          float setRange(float x, float x2, float y, float y2, float z, float z2){ 
				tx = x;
				tx2 = x2;
				ty = y;
				ty2 = y2;
				tz = z;
				tz2 = z2;
			  return 0;   
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
	   builder.c <<-code 
		  int sample(mglGraph *gr, void *){
				gr->Rotate(rX,rY,0);
				gr->Aspect(5, 4, 1);
				gr->SetRanges (tx-5, tx2+5, ty-5, ty2+5, tz, tz2);	
				gr->SetFontSize(1.6);
				gr->Label('x', "m/z", 0.0);
				gr->Label('y', "RT", 0.0);
				gr->Label('z', "Int", 0.0);
				gr->SetTickLen (0.03, 1.0);
				gr->SetTicks ('x', ((tx2+5)/10), 0);
				gr->SetTicks ('y', ((ty2+5)/5), 0);
				gr->SetTicks ('z', (tz2/2), 0);
				gr->Axis("xyz");
				
				vector<float>::iterator it;
				int count = 0;
				float x, y, z;

				for ( it=lines->begin() ; it < lines->end(); it++ ){
					//addlines
					vector<float> * xd = new vector<float>;
					vector<float> * yd = new vector<float>;
					vector<float> * zd = new vector<float>;
					x = *it;
					xd->push_back(x);
					xd->push_back(x);
					it++;
					y = *it;
					yd->push_back(y);
					yd->push_back(y);
					it++;
					z = *it;
					zd->push_back(z);
					zd->push_back(0.0);
					b.Set(*xd);
					c.Set(*yd);
					d.Set(*zd);
					gr->Tens(b,c,d,d,"wcbBH");
					delete xd;
					delete yd;
					delete zd;
					//addlines
				}
			gr->SetMeshNum(10);
			gr->Mesh(nx,"W9");
			return 0;
		  } 
       code
       builder.c <<-code
          float plotC(){ 
			mglGraphFLTK gr;
			string * a = new string("Awesome");
			const char * b = a->c_str();
			char * c = new char;
			strcpy(c,b); 
			char ** d = &c;
			gr.Window(1,d,sample,"MathGL examples");
			return mglFlRun(); 
			}
	   code
	   builder.c <<-code
		   float addLine(float x, float y, float z){
				lines->push_back(x);
				lines->push_back(y);
				lines->push_back(z);
				return 0;
		   }
	   code
	   builder.c <<-code
		   float addNoise(){
			float x, y, z;
			for(int i=0; i<1000; i++){
				x = RandomFloat(tx,tx2);
				y = RandomFloat(ty,ty2);
				z = RandomFloat(700000,10000000); //150000000.0
			}
			return 0;
		   }
	   code
  end
end
