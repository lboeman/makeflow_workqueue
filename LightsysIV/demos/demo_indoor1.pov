/*
  Persistence of Vision Ray Tracer Scene Description File

  Demo scene showing usage of the main features of CIE.inc and LightsysIV.

  Shows the usage of the CIE include to obtain colors from emissive and
  reflective spectrums, for a given color system and specific viewing
  conditions. Lightsys is used to create realistic light sources with
  the colors from emissive spectrums. All the textures on the scene use
  colors from reflective spectrums, and the image maps are processed to 
  follow the system settings.

  Jaime Vives Piqueres, Apr-2003.

*/
// +w512 +h384

global_settings{
  assumed_gamma 1.0
  radiosity{

//   count 50
//   recursion_limit 2
//   error_bound .5
//   nearest_count 10

  }
}

#default{texture{finish{ambient 0}}}

#include "colors.inc"
#include "textures.inc"
#include "glass.inc"

// control center
#declare use_incandescent=1;
#declare use_fluorescent =1;
#declare use_halogen     =1;
#declare use_skylight    =0;
#declare use_area        =1;

// Include CIE color transformation macros by Ive
// used to convert spectrums and kelvin temperatures to RGB 
#include "CIE.inc"
CIE_ChromaticAdaption(0) // turning off chromatic adaption for a photographic look

// CIE Color system selection 
#declare My_ColSys = sRGB_ColSys;
//#declare My_ColSys = Adobe_ColSys;
//#declare My_ColSys = NTSC_ColSys;
//#declare My_ColSys = CIE_ColSys;
//#declare My_ColSys = Beta_ColSys;
CIE_ColorSystem(My_ColSys)

// Change color system white point for lights
//CIE_ColorSystemWhitepoint(My_ColSys, Illuminant_A)    // tungsten 2856K
//CIE_ColorSystemWhitepoint(My_ColSys, Blackbody2Whitepoint(3200)) // Film tungsten A
//CIE_ColorSystemWhitepoint(My_ColSys, Blackbody2Whitepoint(3400)) // Film tungsten A
//CIE_ColorSystemWhitepoint(My_ColSys, Illuminant_F11)  // fluorescent 4000K
//CIE_ColorSystemWhitepoint(My_ColSys, Illuminant_D50)  // daylight 5000K
CIE_ColorSystemWhitepoint(My_ColSys, Illuminant_D55)  // daylight 5500K
//CIE_ColorSystemWhitepoint(My_ColSys, Illuminant_D65)  // daylight 6504K
//CIE_ColorSystemWhitepoint(My_ColSys, Illuminant_D75)  // daylight 7500K

// Main lightsys include
#include "lightsys.inc" 
// Include predefined lumens, spectrums, kelvin temperatures
#include "lightsys_constants.inc" 

// Brightness control (global light multiplier):
#declare Lightsys_Brightness=1/6; // adjust for a brighter/dimmer image
#declare Lightsys_ExposureFake=1.0; // experimental.. try 0.625 for an eye-like adaptation

// Color filter (global color-correction):
//#declare Lightsys_Filter=CC20Y; // Yellow CC filter for daylight
//#declare Lightsys_Filter=CC10M; // Magenta CC filter for fluorescents

// light colors from emissive spectrums
#declare Cl_Incandescent=EmissiveSpectrum(ES_Incandescent_60w);
#declare Cl_Fluorescent =EmissiveSpectrum(ES_Cool_White_Fluor);
#declare Cl_Halogen     =EmissiveSpectrum(ES_Solux_Halog4700K);
#declare Cl_Daylight    =Daylight(7500);
#declare Cl_Sunlight    =Blackbody(5500);

// textures with colors from reflective spectrums
#include "rspd_jvp.inc"
#include "rspd_aster.inc"
// change white point for reflective spectrums
CIE_ColorSystemWhitepoint(sRGB_ColSys, Blackbody2Whitepoint(5000)) 
#declare t_walls=
texture{
 pigment{rgb ReflectiveSpectrum(RS_White_Paint_1)} 
 normal{granite .1 scale 8}
 finish{Dull diffuse 1}
}
#declare t_white_plastic=
texture{
 pigment{rgb ReflectiveSpectrum(RS_White_Paint_1)} 
 finish{Shiny diffuse .7 reflection{.1,.3}}
}
#declare t_floor=
texture{
 pigment{
  checker 
  color rgb ReflectiveSpectrum(RS_ConstrStone1) 
  color rgb ReflectiveSpectrum(RS_ConstrStone3)
 }
 finish{diffuse .7 reflection{.05,.3}}
 scale 50 
 translate -5*z
}
#declare t_ceil=
texture{
 pigment{rgb ReflectiveSpectrum(RS_White_Paint_1)} 
 finish{Dull diffuse 1}
}
#declare t_leather=
texture{
// pigment{rgb ReflectiveSpectrum(RS_TanLeather)} 
// pigment{rgb ReflectiveSpectrum(RS_BlackLeather)} 
 pigment{rgb ReflectiveSpectrum(RS_BrownVelvet1)} 
 normal{quilted scale 10}
 finish{Phong_Shiny phong_size 30 diffuse .9 reflection{.01,.1}}
}
#declare t_wood=
texture{
 pigment{rgb ReflectiveSpectrum(RS_CherryWood1)} 
 finish{diffuse 1}
}
#declare t_wood2=
texture{
 pigment{rgb ReflectiveSpectrum(RS_DarkWood1)} 
 finish{diffuse 1}
}
#declare t_pot=
texture{
 pigment{rgb ReflectiveSpectrum(RS_ConstrStone4)}
 finish{Dull diffuse 1}
}
#declare t_leaf=
texture{
 pigment{rgb ReflectiveSpectrum(RS_UknownLeaf3)} 
 finish{diffuse 1}
}
#declare t_aluminum=
texture{
 pigment{rgb ReflectiveSpectrum(RS_WindowAluminum)} 
 finish{metallic diffuse .4 reflection{.5,.7}}
}
#declare t_lamp_shade=
texture{
 pigment{rgb ReflectiveSpectrum(RS_OldBookPaper) transmit .3 filter .1}
 finish{diffuse 1}
}
// processing image maps to follow color system
#macro CIE_Imagemap(im)
 #local output_0=ReferenceRGB(<0,0,0>);
 #local output_r=ReferenceRGB(<1,0,0>);
 #local output_g=ReferenceRGB(<0,1,0>);
 #local output_b=ReferenceRGB(<0,0,1>);
 #local fn = function { pigment{im} }
 pigment{
  average
  pigment_map{
   [function{fn(x,y,z).red}   color_map{[0 rgb output_0][1 rgb output_r*3]}]
   [function{fn(x,y,z).green} color_map{[0 rgb output_0][1 rgb output_g*3]}]
   [function{fn(x,y,z).blue}  color_map{[0 rgb output_0][1 rgb output_b*3]}]
  }
 }
#end
#declare im_frame1=CIE_Imagemap(pigment{image_map{png "test"}})
#declare im_frame2=CIE_Imagemap(pigment{image_map{png "bumpmap_"}})


// LIGHTS:

// incandescent lamp on the table
union{
 difference{ 
  cone{-15*y,22,5*y,10}
  cone{-15.1*y,21.9,5.1*y,9.9}
  hollow
  texture{t_lamp_shade}
 }
 #if (use_incandescent)
 cone{-15*y,22,5*y,10
  hollow no_shadow
  texture{pigment{rgbf 1} finish{ambient 0 diffuse 0}}
  interior{media{emission Light_Color(Cl_Incandescent,2)}}
  scale .99
 }
 #end
 union{
  cylinder{-5*y,-10*y,1}
  cylinder{-10*y,-30*y,3}
  cylinder{-30*y,-40*y,6}
  texture{t_aluminum}
 }
 #if (use_incandescent)
 object{
  light_source{
   0,Light_Color(Cl_Incandescent,420)
   #if (use_area)
   area_light 9*x,9*z,4,4 jitter adaptive 1 orient circular 
   #end
   Light_Fading()
  }
 }
 sphere{0,1 scale <2,3,2>
  texture{pigment{rgbf 1} finish{ambient 0 diffuse 0}}
  interior{media{emission Light_Color(Cl_Incandescent,220)}}
  hollow no_shadow
 }
 #end
 translate <120,80,155>
}

// fluorescent tube on the ceil
union{
 box{-.5,.5 
  scale <50,4,50>
  texture{t_aluminum}
 }
 #if (use_fluorescent)
 box{-.5,.5
  scale <45,.01,45>
  texture{pigment{rgbf 1} finish{ambient 0 diffuse 0}}
  interior{media{emission Light_Color(Cl_Fluorescent,900)}}
  hollow no_shadow
  translate -2.01*y
 }
 object{
  Light(Cl_Fluorescent,900*4*(pi/2),15*x,15*z,5*use_area,5*use_area,1) 
  translate -2.1*y
 }
 #else
 box{-.5,.5
  scale <45,.01,45>
  texture{t_white_plastic}
  translate -2.01*y
 }
 #end
 translate <0,248,0>
}

// halogen panel on the corner
#if (use_halogen)
#declare halogen=
union{
 cylinder{-.01*y,.01*y,10
  texture{pigment{rgbf 1} finish{ambient 0 diffuse 0}}
  interior{media{emission Light_Color(Cl_Halogen,500)}}
  hollow no_shadow
 }
 light_source{ 0
  Light_Color(Cl_Halogen,1000)
  spotlight radius 15 falloff 45 tightness 0 point_at -250*y
  #if (use_area)
  area_light 9*x,9*z,4,4 jitter adaptive 1 circular
  #end
  Light_Fading()
 }
}
object{halogen translate <-130,249.9,175>}
#end

// skylight patch on the window
#if (use_skylight)
union{
 box{-.5,.5
  scale <120.1,.01,140.1>
  texture{pigment{rgbf 1} finish{ambient 0 diffuse 0}}
  interior{media{emission Light_Color(Cl_Daylight,400)}}
  hollow no_shadow
 }
 light_source{ 0
  Light_Color(Cl_Daylight,1200)
  spotlight radius 90 falloff 90 tightness 0 point_at -y
  #if (use_area)
  area_light 48*x,56*z,6,7 jitter adaptive 1
  #end
  Light_Fading()
 }
 rotate 90*z
 translate <-265,90+60,0>
}
#end


// ROOM:  no more use of CIE or lightsys beyond here, you can ignore it.

// walls
union{
 box{-.5,.5 
  scale <300,250,10>
  translate 200*z
 }
 box{-.5,.5 
  scale <10,250,100>
  translate <-155,0,200-55>
 }
 box{-.5,.5 
  scale <100,250,10>
  translate <-200,0,200-100-5>
 }
 difference{
  box{-.5,.5
   scale <10,250,200>
  }
  box{-.5,.5
   scale <11,120,140>
   translate <0,-125+90+60,0>
  }
  translate <-255,0,0>
 }
 difference{
  box{-.5,.5
   scale <10,250,400>
  }
  box{-.5,.5
   scale <11,200,100> translate <0,-125+100,40>
  }
  translate <155,0,0>
 }
 texture{t_walls}
 translate <0,125,0>
}
box{-.5,.5
 scale <300,250,10>
 translate -300*z
 texture{t_walls}
 no_image
}
union{
 box{-.5,.5 
  scale <300,10,12>
  translate 200*z
 }
 box{-.5,.5 
  scale <12,10,101>
  translate <-155,0,200-55>
 }
 box{-.5,.5 
  scale <101,10,12>
  translate <-200,0,200-100-5>
 }
 box{-.5,.5
  scale <12,10,200>
  translate <-255,0,0>
 }
 difference{
  box{-.5,.5
   scale <12,10,400>
  }
  box{-.5,.5
   scale <13,200,100> translate <0,-125+100,40>
  }
  translate <155,0,0>
 }
 texture{t_wood}
 translate <0,5,0>
}

// floor
box{-.5,.5
 scale <400,1,400>
 texture{t_floor}
 translate -50*x
}

// ceil
box{-.5,.5
 scale <400,1,400>
 texture{t_ceil}
 translate <-50,250.5,0>
}

// pictures
#declare frame=
union{
 box{-.5,.5 scale <64,3,1> translate <0,23,0>}
 box{-.5,.5 scale <64,3,1> translate <0,-23,0>}
 box{-.5,.5 scale <3,48,1> translate <32,0,0>}
 box{-.5,.5 scale <3,48,1> translate <-32,0,0>}
 texture{t_wood2}
}
union{
 object{frame}
 box{-.5,.5
  pigment{im_frame1 translate -.5}
  finish{reflection{.1,.3} diffuse .7}
  scale <61,43,1>
  translate .5*z
 }
 scale 1.6
 translate <0,150,194>
}
union{
 object{frame}
 box{-.5,.5
  pigment{im_frame2 translate -.5}
  finish{reflection{.1,.3} diffuse .7}
  scale <61,43,1>
  translate .5*z
 }
 scale 1.1
 translate <-197,151,89>
}

// sofas
#include "functions.inc"
#macro rbox(R)
 #local Min=<-1,-1,-1>;
 #local Max=<1,1,1>;
 #local S=(Max-Min)/2;
 #local Sx=S.x;
 #local Sy=S.y;
 #local Sz=S.z;
 isosurface{
  function{f_rounded_box(x,y,z,R,Sx,Sy,Sz)}
   max_gradient 1
   contained_by{box{-S,S}}
   translate Min+S
  scale .5
 }
#end
#declare br=1;
#declare sofa=
union{
 object{rbox(br*.5)
  scale <70,30,70>
  translate -20*y
 }
 object{rbox(br)
  scale <80,80,40>
  translate <0,10,30>
 }
 object{rbox(br*.75)
  scale <20,80,60>
  translate <-40,-20,0>
 }
 object{rbox(br*.75)
  scale <20,80,60>
  translate <40,-20,0>
 }
 texture{t_leather}
}
#declare sillon=
union{
 object{rbox(br*.5)
  scale <140,30,70>
  translate <0,-20,0>
 }
 object{rbox(br)
  scale <150,80,40>
  translate <0,10,30>
 }
 object{rbox(br*.75)
  scale <20,80,60>
  translate <-70,-20,0>
 }
 object{rbox(br*.75)
  scale <20,80,60>
  translate <70,-20,0>
 }
 texture{t_leather}
}
object{sofa translate <-4,42,140>}
//object{sillon translate <0,42,140>}
object{sofa rotate -90*y translate <-190,42,0>}
object{sofa rotate -90*y translate <-190,42,-130>}

// table
union{
 cylinder{-1.5*y,1.5*y,34}
 cylinder{-40*y,-1*y,3 translate -29*z rotate 90*0*y}
 cylinder{-40*y,-1*y,3 translate -29*z rotate 90*1*y}
 cylinder{-40*y,-1*y,3 translate -29*z rotate 90*2*y}
 cylinder{-40*y,-1*y,3 translate -29*z rotate 90*3*y}
 box{-.5,.5 scale <29*2,2,2> translate <0,-20,0>}
 box{-.5,.5 scale <2,2,29*2> translate <0,-20,0>}
 texture{t_wood}
 rotate 33*y
 translate <112,40,150>
}

// plant
#declare pot1=
union{
 difference{
  cone{<0,0,0>,9,<0,16,0>,13}
  cone{<0,1,0>,8,<0,17,0>,12}
  texture{t_pot}
 }
 scale 1.2
}

// *** achmea-like plant ***
#macro achmea_leaf(lsize,lthick,lwidth)
intersection{
 difference{
  sphere{0,1 scale lsize}
  sphere{0,1 scale lsize-lthick}
 }
 plane{y,0 inverse}
 sphere{0,1 scale <lwidth,lsize*2+.1,lsize*2-.1> translate -lsize*z}
 translate (lsize+lwidth)*z
}
#end
#macro achmea_plant1(lsize,lthick,lwidth,nleafs,nchilds,t_leaf,rplant)
#local ichilds=0;
#local rp=seed(rplant);
#local lw=lwidth;
#local nl=nleafs;
union{
#while (ichilds<nchilds)
 #local ileafs=0;
 #while (ileafs<nl)
  object{
   achmea_leaf(lsize,lthick,lw)
   scale (1-.5*(ichilds/nchilds))
   scale <1,1,.25+rand(rp)>
   texture{t_leaf}
   rotate -10*(sin(pi*ichilds/nchilds))*x
   rotate (360*(ileafs/nl)-5+10*rand(rp))*y
   translate lw*ichilds*y
  }
  #debug "."
  #local ileafs=ileafs+1;
 #end
 #local nl=nleafs*.5+nleafs*.5*(ichilds/nchilds);
 #local lw=lwidth*.5+lwidth*.5*(ichilds/nchilds);
 #local ichilds=ichilds+1;
#end
}
#end
#declare pedestal=
union{
 cylinder{<0,0,0>,<0,2,0>,14}
 torus{12,2 translate 3*y}
 torus{10,2 translate 5*y}
 difference{
  cylinder{<0,5,0>,<0,35,0>,9}
  cylinder{<-9,5,0>,<-9,35,0>,2}
  cylinder{< 9,5,0>,<9,35,0>,2}
  cylinder{<0,5,0>,<0,35,-9>,2}
  cylinder{<0,5,0>,<0,35,9>,2}
  cylinder{<-9,5,0>,<-9,35,0>,2 rotate 45*y}
  cylinder{<-9,5,0>,<-9,35,0>,2 rotate 45*3*y}
  cylinder{<-9,5,0>,<-9,35,0>,2 rotate 45*5*y}
  cylinder{<-9,5,0>,<-9,35,0>,2 rotate 45*7*y}
 }
 torus{9,1 translate 35*y}
 torus{10,2 translate 37*y}
 cylinder{<0,37,0>,<0,40,0>,12}
 texture{t_pot}
}
#declare r_p1=seed(963);
#declare plant1=
union{
 object{pedestal}
 object{pot1 translate 41*y}
 object{achmea_plant1(10,.1,3,16,4,t_leaf,r_p1) scale 1.5 translate 52*y}
}
object{plant1 translate <-110,.5,155>}

// window
union{
 union{
  box{-.5,.5 scale <10,120,10> translate <0,0,-65>}
  box{-.5,.5 scale <10,120,10> translate <0,0, 65>}
  box{-.5,.5 scale <10,10,140> translate <0,55,0>}
  box{-.5,.5 scale <10,10,140> translate <0,-55,0>}
  texture{t_aluminum}
 }
 #if (use_skylight=0)
 box{-.5,.5
  scale <.2,120,140>
  texture{Mirror normal{quilted scale 3}}
  translate -2*x
 }
 #end
 translate <-265,90+60,0>
}

// door
union{
 union{
  box{-.5,.5 scale <10,200,10> translate <0,0,-45>}
  box{-.5,.5 scale <10,200,10> translate <0,0, 45>}
  box{-.5,.5 scale <10,10,100> translate <0,95,0>}
  texture{t_wood2}
 }
 box{-.5,.5
  scale <4,200,100>
  texture{t_wood}
  translate 2*x
 }
 translate <154,100,40>
}


// **************
// *** camera ***
// **************
camera{
 location <-75,126,-450>
 up 2.4*y
 right 3.2*x
 direction 3.5*z
 look_at <-65,124,200>
}
