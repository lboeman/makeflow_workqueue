/*
  Persistence of Vision Ray Tracer Scene Description File

  Demo scene showing usage of CIE.inc and LightsysIV for space scenes. 
  
  Creates a starfield with colors of known kelvin temperatures, the moon
  with ASTER lunar samples, and a realistic extraterrestrial sun color.

  Jaime Vives Piqueres, Apr-2003.

*/
global_settings{
 assumed_gamma 1.0
 max_trace_level 16
}
#default{texture{finish{ambient 0}}}
#include "functions.inc"


// *** CIE & LIGHTSYS ***
#include "CIE.inc"
CIE_ChromaticAdaption(off)       // recommended for photograpic effects
//#declare Space_ColSys=NTSC_ColSys;
//#declare Space_ColSys=SMPTE_ColSys;
#declare Space_ColSys=sRGB_ColSys;
CIE_ColorSystem(Space_ColSys) 
#include "lightsys.inc"          
#include "espd_sun.inc"          // predefined illuminants
#include "rspd_lunar.inc"        // predefined material samples


// *** UNIVERSE DATA ***
#declare universe=2000;  // universe shell dimension
#declare vision=12;      // angle of starfield section
#declare use_stars=1;     
#declare star_type=1;    // 0=round, 1=spiky
#declare star_size=14;   
#declare r_s=seed(13);   // stars random seed
#declare num_stars=300;
#declare use_moon=1;       
#declare r_sun=seed(18);   // sun position random seed


// *** STARFIELD ***
#if (use_stars)
// using starfield macro to generate some background stars
#include "demo_starfield.inc"
object{
 Starfield(universe,vision,num_stars,star_type,star_size,r_s)
}
#end 


// *** MOON ***
#if (use_moon)

// moon texture
#declare t_moon=
texture{
 pigment{
  onion
  color_map{ 
   [0.0 rgb ReflectiveSpectrum(RS_Lunar_Maria_3)]
   [1.0 rgb ReflectiveSpectrum(RS_Lunar_Highlands_3)]
  }
 }
}

// moon isosurface
#declare Moon=
isosurface{
 function{(x*x+y*y+z*z-1)+f_granite(x*2,y*2,z*2)*f_agate(x,y,z)*.05}
 max_gradient 3.8
 contained_by{sphere{0,1}}
 texture{t_moon scale .02}
}

// placement
object{Moon scale 60 translate <0,0,100>}
light_source{
 0
 Light_Color(EmissiveSpectrum(ES_Sun),2000000000)
 Light_Fading()
 translate 10e4*z
 rotate 360*rand(r_sun)*x
 rotate 360*rand(r_sun)*y
}

#end // moon


camera{
 location -500*z
 direction 4*z
 look_at 100*z
}
