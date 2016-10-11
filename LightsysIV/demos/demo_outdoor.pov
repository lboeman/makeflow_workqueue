/*
  Persistence of Vision Ray Tracer Scene Description File

  Demo scene showing usage of CIE_Skylight.inc for outdoor setups

  Jaime Vives Piqueres, Oct-2003.

*/
global_settings{
 assumed_gamma 1.0
 radiosity{
  brightness 2
 }
}
#default{texture{finish{ambient 0}}}
#include "colors.inc"
#include "textures.inc"


// *** CIE & LIGHTSYS ***
#include "CIE.inc"
CIE_ColorSystemWhitepoint(sRGB_ColSys,Illuminant_D65)
#include "lightsys.inc"          
#include "rspd_jvp.inc"          // predefined material samples

// *** trace control ***
#declare r_sun=seed(29);
#declare hf_res=800;

// *** sky sphere and sun ***
#declare Al=90*rand(r_sun);
#declare Az=360*rand(r_sun);
#declare North=<-1+2*rand(r_sun),0,-1+2*rand(r_sun)>;
#declare Intensity_Mult=1;
#declare Max_Vertices=800;
#include "CIE_Skylight"
light_source{
 SolarPosition
 Light_Color(SunColor,6)
}

// *** some fog for distance sense ***
fog{
 fog_type 2
 color (HorizonColor)
 fog_alt 2
 distance 20
}

// *** terrain ***
// textures:
#declare Cl_terrain1=ReflectiveSpectrum(RS_ConstrStone1);
#declare Cl_terrain2=ReflectiveSpectrum(RS_UknownLeaf3);
#declare Cl_trees=ReflectiveSpectrum(RS_UknownLeaf1);
#declare t_terrain=
texture{
 pigment{
  slope y
  color_map{
   [0.0 rgb Cl_terrain2]
   [0.1 rgb Cl_terrain1]
   [0.5 rgb Cl_terrain1]
   [0.8 rgb Cl_terrain1]
   [0.9 rgb Cl_terrain2]
   [1.0 rgb Cl_terrain2]
  }
 }
 finish{ambient 0}
}
// filling plane:
plane{y,0
 texture{t_terrain
  normal{granite scale 20}
 }
 translate .01*y
}
// height_field terrain
#declare terrain=
height_field{
 function hf_res,hf_res{
  pigment{
   wrinkles
   pigment_map{
    [0 crackle solid]
    [0.5 bumps]
    [1 granite]
   }
   turbulence .5
   scale .5
   translate 33
  }
 }
 translate -.5
 scale <200,50,200>
 texture{t_terrain}
 translate 25*y
}
object{terrain}
object{terrain rotate 90*y translate <0,-11,200>}

// *** trees **
// simple use of trace to give a bit more life to this test scene
#declare r_t=seed(9627);
#declare i=0;
#declare nt=5000;
#declare trees=
union{
#while (i<nt)
 #declare kk=true;
 #while (kk) 
  #declare Norm=<0,0,0>;
  #declare Start=<-100+200*rand(r_t),100,-100+200*rand(r_t)>;
  #declare Inter=trace(terrain,Start,-1*y,Norm);
  #if (Norm.y>.9)
   #declare kk=false;
  #end
 #end
 sphere{0,.2+.3*rand(r_t) 
  translate Inter+.1
 }
 #declare i=i+1;
#end
 pigment{rgb Cl_trees}
 normal{granite 1} 
}
object{trees}
object{trees rotate 90*y translate <0,-11,200>}


// *** camera ***
camera{
 location <0,24,-100>
 look_at <-1,30,0>
}
