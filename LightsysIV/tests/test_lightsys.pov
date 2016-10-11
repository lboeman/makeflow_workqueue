/*
  Persistence of Vision Ray Tracer Scene Description File

  LightSysIV basic test scene.

  Shows usage of auxiliar lighting macros to create custom light_source's, and
  also the "live" usage of the CIE color macros.

  Jaime Vives Piqueres, Apr-2003.

*/
// +w700 +h400

global_settings{
  assumed_gamma 1.0
  radiosity{
    pretrace_start 0.04 pretrace_end 0.01
    count 50
    nearest_count 10 error_bound 0.5
  }
}

#include "colors.inc"
#include "textures.inc"

// demo switchs
#declare basic_lights=true; // use basic or custom lights?
#declare precalculate_colors=true; // use precalculated colors?

// Include CIE color transformation macros by Ive
// used to convert spectrums and kelvin temperatures to RGB 
#include "CIE.inc"
// CIE Color system selection 
//#declare My_ColSys = sRGB_ColSys;
#declare My_ColSys = Adobe_ColSys;
//#declare My_ColSys = NTSC_ColSys;
CIE_ColorSystem(My_ColSys)

// Change color system white point 
//CIE_ColorSystemWhitepoint(My_ColSys, Illuminant_A)    // tungsten 2856K
CIE_ColorSystemWhitepoint(My_ColSys, Illuminant_F11)  // fluorescent 4000K
//CIE_ColorSystemWhitepoint(My_ColSys, Illuminant_D50)  // daylight 5000K
//CIE_ColorSystemWhitepoint(My_ColSys, Illuminant_D55)  // daylight 5500K
//CIE_ColorSystemWhitepoint(My_ColSys, Illuminant_D65)  // daylight 6504K
//CIE_ColorSystemWhitepoint(My_ColSys, Illuminant_D75)  // daylight 7500K


// LIGHTSYS:

// Main lightsys include
#include "lightsys.inc" 

// Include predefined lumens, spectrums, kelvin temperatures, and optionally 
// precalculate constants for common colors.
#include "lightsys_constants.inc" 
#if (precalculate_colors)
#include "lightsys_colors.inc"
#end

// Brightness control (global light multiplier):
#declare Lightsys_Brightness=1/3; // adjust for a brighter/dimmer image

// Color filter (global color-correction):
#declare Lightsys_Filter=<1,1,1>; // no correction           
//#declare Lightsys_Filter=CC10M; // Magenta CC filter for green fluorescents

// experimental attenuation
#declare Lightsys_ExposureFake=1;

// Different light settings for intensity and color
#declare lm1=Lm_Incandescent_60w;  // 720 lm
#declare lm2=Lm_Fluorescent_15w;   // 900 lm
#declare lm3=Lm_Fluorescent_15w;   // 900 lm
#declare lm4=Lm_Halogen_52w;       // 885 lm
#declare lm5=1000;                 // 1000 lm
#if (precalculate_colors)
// simple built-in indetifiers
#declare Cl1=Cl_Incandescent_60w;
#declare Cl2=Cl_Warm_White_Fluor;
#declare Cl3=Cl_Cool_White_Fluor;
#declare Cl4=Cl_Halogen;
#declare Cl5=Cl_SI_D65;
#else
// using CIE macros with predefined spectrums and temperatures
#declare Cl1=EmissiveSpectrum(ES_Incandescent_60w);
#declare Cl2=EmissiveSpectrum(ES_Warm_White_Fluor);
#declare Cl3=EmissiveSpectrum(ES_Cool_White_Fluor);
#declare Cl4=EmissiveSpectrum(ES_Solux_Halog4700K);
#declare Cl5=Daylight(Kt_SI_D65);
#end


// **********************************
// *** build five different lamps ***
// **********************************

// + lamp objects
#declare use_area=0;  // controls use of area_lights
#macro sheet(cl,lm)
box{-.5,.5
 material{
  texture{
   pigment { color rgbf<1, 1, 1, 1> }
   finish { ambient 0 diffuse 0 }
  }
  interior{
   media {
    emission cl*lm
    intervals 10
    samples 1, 10
    confidence 0.9999
    variance 1/1000
   }
  }
 }
 hollow
 no_shadow
}
#end

// + build the lamps using diferent light types
// simply with the Light() macro:
#if (basic_lights)
union{
 Light(Cl1,lm1,x,z,0,0,1)
 object{sheet(Cl1,lm1)scale <20,.1,20> translate .9*y}
 translate <-200,249,450>
}
union{
 Light(Cl2,lm2,x,z,0,0,1)
 object{sheet(Cl2,lm2)scale <20,.1,20> translate .9*y}
 translate <-100,249,450>
}
union{
 Light(Cl3,lm3,x,z,0,0,1)
 object{sheet(Cl3,lm3)scale <20,.1,20> translate .9*y}
 translate <0,249,450>
}
union{
 Light(Cl4,lm4,x,z,0,0,1)
 object{sheet(Cl4,lm4)scale <20,.1,20> translate .9*y}
 translate <100,249,450>
}
union{
 Light(Cl5,lm5,x,z,0,0,1)
 object{sheet(Cl5,lm5)scale <20,.1,20> translate .9*y}
 translate <200,249,450>
}
#else
// ...or building light_sources with the auxiliar macros:
union{
 light_source{0
  Light_Color(Cl1,lm1)
  Light_Spot_Cos_Falloff(-y)
  Light_Fading()
 }
 object{sheet(Cl1,lm1)scale <20,.1,20> translate .9*y}
 translate <-200,249,450>
}
union{
 light_source{0
  Light_Color(Cl2,lm2)
  Light_Spot_Cos_Falloff(-y)
  Light_Fading()
 }
 object{sheet(Cl2,lm2)scale <20,.1,20> translate .9*y}
 translate <-100,249,450>
}
union{
 light_source{0
  Light_Color(Cl3,lm3)
  Light_Spot_Cos_Falloff(-y)
  Light_Fading()
 }
 object{sheet(Cl3,lm3)scale <20,.1,20> translate .9*y}
 translate <0,249,450>
}
union{
 light_source{0
  Light_Color(Cl4,lm4)
  Light_Spot_Cos_Falloff(-y)
  Light_Fading()
 }
 object{sheet(Cl4,lm4)scale <20,.1,20> translate .9*y}
 translate <100,249,450>
}
union{
 light_source{0
  Light_Color(Cl5,lm5)
  Light_Spot_Cos_Falloff(-y)
  Light_Fading()
 }
 object{sheet(Cl5,lm5)scale <20,.1,20> translate .9*y}
 translate <200,249,450>
}
#end


// *****************
// *** test room ***
// *****************

// + main room
union{
 box{-.5,.5 scale <500,250,2000> translate -500*z}
 box{-.5,.5 scale <1,250,100> translate < 150,0,450>}
 box{-.5,.5 scale <1,250,100> translate <  50,0,450>}
 box{-.5,.5 scale <1,250,100> translate <-150,0,450>}
 box{-.5,.5 scale <1,250,100> translate < -50,0,450>}
 box{-.5,.5 scale <40,100,40> translate < 200,-75,480>}
 box{-.5,.5 scale <40,100,40> translate < 100,-75,480>}
 box{-.5,.5 scale <40,100,40> translate <   0,-75,480>}
 box{-.5,.5 scale <40,100,40> translate <-100,-75,480>}
 box{-.5,.5 scale <40,100,40> translate <-200,-75,480>}
 hollow
 texture{
  pigment{White}
  finish{ambient 0}
 }
 translate <0,125,0>
}

// + metric references (10cm steps)
#declare ncm=250;
#declare icm=1;
#declare metric_ref=
union{
#while (icm<=ncm)
 #if (mod(icm,10)=0)
  box{-.5,.5 scale <10,1,1>
   texture{pigment{Gray10} finish{ambient 0 reflection{.1,.3 exponent .7}}}
   translate <0,icm,0>
  }
  box{-.5,.5 scale <10,10,.9>
   texture{pigment{White} finish{ambient 0 reflection{.1,.3 exponent .7}}}
   translate <0,icm,0>
  }
 #end
 #declare icm=icm+1;
#end
 box{-.5,.5 scale <1,250,1>
  texture{pigment{Gray10} finish{ambient 0 reflection{.1,.3 exponent .7}}}
  translate 125*y
 }
}
object{metric_ref rotate 90*y translate <-249,0,400>}
object{metric_ref rotate 90*y translate < 249,0,400>}
object{metric_ref translate <-200,0,499>}
object{metric_ref translate <-100,0,499>}
object{metric_ref translate <   0,0,499>}
object{metric_ref translate < 100,0,499>}
object{metric_ref translate < 200,0,499>}

// + some more reference objects
#declare color_chart=
union{
 box{-.5,.5 scale <20,20,1> pigment{Red} finish{ambient 0} translate <-10, 10,0>}
 box{-.5,.5 scale <20,20,1> pigment{Green} finish{ambient 0} translate < 10, 10,0>}
 box{-.5,.5 scale <20,20,1> pigment{Blue} finish{ambient 0} translate <-10,-10,0>}
 box{-.5,.5 scale <20,20,1> pigment{White} finish{ambient 0} translate < 10,-10,0>}
}
#declare color_chart2=
union{
 box{-.5,.5 scale <20,20,1> pigment{Magenta} finish{ambient 0} translate <-10, 10,0>}
 box{-.5,.5 scale <20,20,1> pigment{Cyan} finish{ambient 0} translate < 10, 10,0>}
 box{-.5,.5 scale <20,20,1> pigment{Yellow} finish{ambient 0} translate <-10,-10,0>}
 box{-.5,.5 scale <20,20,1> pigment{White} finish{ambient 0} translate < 10,-10,0>}
}
union{
 object{color_chart translate <228,202,499>}
 object{color_chart translate <128,202,499>}
 object{color_chart translate < 28,202,499>}
 object{color_chart translate <-72,202,499>}
 object{color_chart translate <-172,202,499>}
 object{color_chart translate <-228,160,499>}
 object{color_chart translate <-128,160,499>}
 object{color_chart translate < -28,160,499>}
 object{color_chart translate < 72,160,499>}
 object{color_chart translate < 172,160,499>}
 object{color_chart2 translate <-228,202,499>}
 object{color_chart2 translate <-128,202,499>}
 object{color_chart2 translate < -28,202,499>}
 object{color_chart2 translate <72,202,499>}
 object{color_chart2 translate <172,202,499>}
 object{color_chart2 translate < 228,160,499>}
 object{color_chart2 translate < 128,160,499>}
 object{color_chart2 translate <  28,160,499>}
 object{color_chart2 translate <-72,160,499>}
 object{color_chart2 translate <-172,160,499>}
 translate 10*y
}
union{
 sphere{<-200,120,480>,20}
 sphere{<-100,120,480>,20}
 sphere{<   0,120,480>,20}
 sphere{< 100,120,480>,20}
 sphere{< 200,120,480>,20}
 texture{pigment{White} finish{ambient 0 reflection{.1,.3 exponent .7}}}
}
union{
 sphere{<-200,20,0>,20 texture{pigment{rgb Light_Color(Cl1,10)}}}
 sphere{<-100,20,0>,20 texture{pigment{rgb Light_Color(Cl2,10)}}}
 sphere{<   0,20,0>,20 texture{pigment{rgb Light_Color(Cl3,10)}}}
 sphere{< 100,20,0>,20 texture{pigment{rgb Light_Color(Cl4,10)}}}
 sphere{< 200,20,0>,20 texture{pigment{rgb Light_Color(Cl5,10)}}}
 translate 430*z
}


// **************
// *** camera ***
// **************
camera{
 location <1,126,-450>
 up 2.0*y
 right 3.5*x
 direction 5*z
 look_at <-1,124,450>
}
