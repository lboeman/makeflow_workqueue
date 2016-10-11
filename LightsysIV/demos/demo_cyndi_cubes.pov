/*
  Persistence of Vision Ray Tracer Scene Description File
  
  Color manipulation for image maps by using CIE_tools.inc
  You can change the hue, create a color negative, a grayscale
  image or can do other strange things with Cyndi's "True Colors" 
  
  Note the nice effect that only the memory for just one image_map 
  is allocated!
  
  +w640 +h480 +A0.2
  
  Ive, Mai-2003.
  
*/

global_settings {
  assumed_gamma 1.0
}

#default { finish {ambient 0.1 diffuse 0.9 specular 0.85 roughness 0.009} }  

#include "colors.inc"        
#include "CIE.inc"
#include "CIE_tools.inc"
#include "lightsys.inc"
#include "lightsys_constants.inc"
#include "espd_lightsys.inc"

#declare lightsys_brightness = 1.0;

//-----------------------------------------------------------------------

#declare AreaLight = off;

#declare LC1 = EmissiveSpectrum(ES_Osram_CoolFluor_36w);
#declare LM  = Lm_Incandescent_100w;

object {
  Light(LC1, LM, x*40, y*40, AreaLight*4,AreaLight*4, off)
  translate <-150,140,-240>
}

camera{    
  location <0,-10,-14>
  right x*image_width/image_height
  direction 1.5*z 
  look_at <0,-.6,0>
}

plane{
  -z, -40
  pigment{rgb ReferenceRGB(Gray20)}
}  

//-----------------------------------------------------------------------

#declare Cyndi = pigment{image_map{png "cyndi" interpolate 2}}

#macro Box(ImgMap)
  #local R = 0.15;  
  #local Img = box {0,1 pigment{ImgMap} translate -0.5 scale <2,2,R*2> }
  union {
    object {Img rotate y*0   translate -z }
    object {Img rotate y*180 translate  z }
    object {Img rotate y*90  translate -x }
    object {Img rotate y*-90 translate  x }
    object {Img rotate x*-90 translate -y }
    object {Img rotate x*90  translate  y }
    sphere {<-1,-1,-1> R} 
    sphere {< 1,-1,-1> R} 
    sphere {<-1,-1, 1> R} 
    sphere {< 1,-1, 1> R}
    sphere {<-1, 1,-1> R} 
    sphere {< 1, 1,-1> R} 
    sphere {<-1, 1, 1> R} 
    sphere {< 1, 1, 1> R}
    cylinder {<-1,-1,-1>< 1,-1,-1> R}
    cylinder {<-1,-1,-1><-1,-1, 1> R}
    cylinder {< 1,-1,-1>< 1,-1, 1> R}
    cylinder {<-1,-1, 1>< 1,-1, 1> R}
    cylinder {<-1, 1,-1>< 1, 1,-1> R}
    cylinder {<-1, 1,-1><-1, 1, 1> R}
    cylinder {< 1, 1,-1>< 1, 1, 1> R}
    cylinder {<-1, 1, 1>< 1, 1, 1> R}
    cylinder {<-1,-1,-1><-1, 1,-1> R}
    cylinder {< 1,-1,-1>< 1, 1,-1> R}
    cylinder {< 1,-1, 1>< 1, 1, 1> R}
    cylinder {<-1,-1, 1><-1, 1, 1> R}
    pigment {rgb ReferenceRGB(Gray05)}
  }
#end

#macro BoxBC(B,C)
  Box(CIE_Imagemap_BC(Cyndi, B, C))
#end    

#macro BoxLch(L,C,H)
  Box(CIE_Imagemap_LCH(Cyndi, L, C, H))
#end

#declare Seed = seed(2003);
#declare D = 1.4;
#declare R = 12;

#macro RandRot(R)
  rotate <rand(Seed)*R-R/2,rand(Seed)*R-R/2,rand(Seed)*R-R/2>
#end

//-----------------------------------------------------------------------
 
// 1.row: changing the hue 
object {BoxLch(1, 1, 0.15) RandRot(R) translate <-D*4, D*3, 0>}
object {BoxLch(1, 1, 0.25) RandRot(R) translate <-D*2, D*3, 0>}
object {BoxLch(1, 1, 0.50) RandRot(R) translate < D*0, D*3, 0>}
object {BoxLch(1, 1, 0.75) RandRot(R) translate < D*2, D*3, 0>}
object {BoxLch(1, 1, 0.85) RandRot(R) translate < D*4, D*3, 0>}

// 2.row: chromatisity from oversaturated (left) to grayscale (right) 
object {BoxLch(1, 2.0, 1) RandRot(R) translate <-D*4, D*1, 0>}
object {BoxLch(1, 1.5, 1) RandRot(R) translate <-D*2, D*1, 0>}
object {BoxLch(1, 1.0, 1) RandRot(R) translate < D*0, D*1, 0>}
object {BoxLch(1, 0.5, 1) RandRot(R) translate < D*2, D*1, 0>}
object {BoxLch(1, 0.0, 1) RandRot(R) translate < D*4, D*1, 0>}

// 3.row: changing contrast where -1 does produce a 'negative film'
object {BoxBC(1,  2.0)    RandRot(R) translate <-D*4,-D*1, 0>}
object {BoxBC(1,< 1,2,0>) RandRot(R) translate <-D*2,-D*1, 0>}
object {BoxBC(1,<-1,1,1>) RandRot(R) translate < D*0,-D*1, 0>}
object {BoxBC(1, -1.0)    RandRot(R) translate < D*2,-D*1, 0>}
object {BoxBC(1, -2.0)    RandRot(R) translate < D*4,-D*1, 0>}

// 4.row: changing brightness for single RGB channels with higher contrast 
object {BoxBC(<1.6, 0.1, 0.0>, 1.5) RandRot(R) translate <-D*4,-D*3, 0>}
object {BoxBC(<1.4, 1.2, 0.0>, 1.5) RandRot(R) translate <-D*2,-D*3, 0>}
object {BoxBC(1.33, 1.5)            RandRot(R) translate < D*0,-D*3, 0>}
object {BoxBC(<0.0, 1.5, 1.0>, 1.5) RandRot(R) translate < D*2,-D*3, 0>}
object {BoxBC(<0.0, 0.1, 2.0>, 1.5) RandRot(R) translate < D*4,-D*3, 0>}

//-----------------------------------------------------------------------

