/*
   Persistence of Vision Ray Tracer Scene Description File

   demonstrates the combined use of
     CIE.inc
     lightsys.inc
     and various spectral data bases

   Just a quick'n'dirty example scene, I've tried to keep modeling and
   texturing quite simple but ALL lightsources and colors are processes
   through the CIE xyz color model. It should demonstrate possible ways
   to obtain and handle colors by the use of CIE.inc.
   Feel free to play around with the various settings and see how the
   look of the sceene does change!

   The image used as material map is based on Piet Mondrian, Composition 
   with Red, Yellow and Blue, 1921
   ( ...and the 3 chairs do use the same color primaries)

   The LP (not CD!) is Cyndi Lauper's 'True Colors' from 1986

   +w640 +h480

   Ive, Mai-2003
*/

global_settings {
  assumed_gamma 1.0
  max_trace_level 15
  radiosity {
    count 130 error_bound 0.9
  }
}

#default { finish {ambient 0 diffuse 1} }

#declare CIE_MultiObserver = true;

//=====================================================================
#include "colors.inc"
#include "math.inc"
#include "CIE.inc"
#include "CIE_tools.inc"
#include "lightsys.inc"
#include "lightsys_constants.inc"
#include "espd_lightsys.inc"
#include "lspd_elements.inc"
#include "rspd_pantone_coated.inc"
#include "rspd_pantone_matte.inc"
#include "rspd_aster.inc"
#include "rspd_jvp.inc"

//-----------------------------------
// *** lightsys.inc settings ***
//-----------------------------------
#declare Lightsys_Brightness = 0.67; // adjust for a brighter/dimmer image

//-----------------------------------
// *** user settings ***
//-----------------------------------
#declare AreaLight = off;
#declare FocalBlur = off;
#declare HueShift  = 0.0; // 0.0 - 1.0 to rotate the primaries used by Mondrian within the Lch color circle
//#declare HueShift = 0.4; // I hope Piet would forgive me for doing this!

// remove objects for speed or if you don't like them
#declare PutMondrian = on;
#declare PutChairs   = on;
#declare PutDesk     = on;

#declare User_Tune         = 0;
#declare Daylight_Tune     = 1;
#declare Incandescent_Tune = 2;
#declare Fluorescent_Tune  = 3;

#declare Tune = 0;  // select 0..3 (see above)

//---------------------------------------------------------------------
#switch (Tune)
  #case (Daylight_Tune)
    #declare Film_Temperature = Kt_Daylight_Film;
    #declare L1  = off;// neon tubes
    #declare L2  = off;// incandescent lamps
    #declare L3  = off;// spotlight pointing at 'Mondrian'
    #declare LD  = on; // window
  #break
  #case (Incandescent_Tune)
    #declare Film_Temperature = Kt_Indoor_Film;
    #declare L1  = off;// neon tubes
    #declare L2  = on; // incandescent lamps
    #declare L3  = on; // spotlight
    #declare LD  = off;// window
  #break
  #case (Fluorescent_Tune)
    #declare Film_Temperature = Kt_Fluorescent_Film;
    #declare L1  = on; // neon tubes
    #declare L2  = off;// incandescent lamps
    #declare L3  = on; // spotlight
    #declare LD  = off;// window
  #break
  #else // set ImageTune = 0 and apply here any settings you like
    #declare Film_Temperature = Kt_TungstenA_Film;
    #declare L1  = on; // neon tubes
    #declare L2  = on; // incandescent lamps
    #declare L3  = on; // spotlight
    #declare LD  = off;// window
#end

//=====================================================================

// use the Judd/Vos modified observer
#if (CIE_MultiObserver)
  CIE_Observer(CIE_1978)
#end  

// try it without gamut mapping
CIE_GamutMapping(off);

// ColorSystem and Whitepoint for light sources
CIE_ColorSystemWhitepoint(Beta_ColSys, Blackbody2Whitepoint(Film_Temperature))

// mix line spectra for the neon tubes
#declare LS_NeAr = array[2] {
  LS_Neon,
  LS_Argon
}
#declare LR_NeAr = array[2][2] {
  {0.95, 2}, // 95% Neon
  {0.05, 2}, //  5% Argon
}

//spectra and lumens for light sources
#declare LC1 = LineSpectrumMix(LS_NeAr, LR_NeAr);
#declare LM1 = 300;

#declare LC2 = EmissiveSpectrum(ES_Incandescent_60w);
#declare LM2 = Lm_Incandescent_60w;

#declare LC3 = EmissiveSpectrum(ES_Mitsubishi_Standard_Fluorescent);
#declare LM3 = 965;

#declare LCD = Daylight(6600);
#declare LMD = 2100;

// no longer needed!
#undef LS_NeAr
#undef LR_NeAr

//=====================================================================
// ColorSystem and Whitepoint used for ALL pigment colors
#switch (Tune)
  #case (Daylight_Tune)
  #case (Incandescent_Tune)
  #case (Fluorescent_Tune)
    CIE_ColorSystem(Beta_ColSys) // reset to default color system whitepoint
  #break
  #else // (User_Tune)
    CIE_ColorSystemWhitepoint(Match_ColSys, Illuminant_B) // something else to play with
    CIE_ChromaticAdaption(off)
#end

//---------------------------------------------------------------------
// colors for pigment/texture definitions
#declare Wall_Color   = ReflectiveSpectrum(RS_White_Paint_1);           // from 'rspd_jvp.inc'
#declare Brick_Color  = ReflectiveSpectrum(RS_Red_smooth_faced_Brick);  // from 'rspd_aster.inc'
#declare Mortar_Color = ReflectiveSpectrum(RS_Construction_Concrete_1); // dito
#declare Floor_Color  = ReflectiveMix(RS_Green_M, RS_Black_3_M, 1, 3);  // mix of 2 spectra

#declare Mondrian_R_Lab = <52, 62, 55>;  // LAB values are taken from the
#declare Mondrian_Y_Lab = <80,  9, 70>;  // image with the color picker
#declare Mondrian_B_Lab = <45,-12,-30>;  // tool of Photoshop

// macro to transform a given L*a*b color through Lch with possible hue shift
#macro LchHueShift(LAB)
  #local LCH = Lab2Lch(LAB);
  rgb Lch2RGB(<LCH.x, LCH.y, LCH.z+(2*pi*HueShift)>); // return a rgb value
#end

#declare Mondrian_R_rgb = LchHueShift(Mondrian_R_Lab)
#declare Mondrian_Y_rgb = LchHueShift(Mondrian_Y_Lab)
#declare Mondrian_B_rgb = LchHueShift(Mondrian_B_Lab)

// texture definitions
#declare T_Floor = texture {
  pigment { crackle
    color_map {
      [0.0 rgb Mortar_Color*0.5 ]
      [0.1 rgb Floor_Color]
    }
    scale 12
  }
}

#declare T_Brick_Wall = texture {
  pigment {brick color Mortar_Color color Brick_Color scale 2.5 turbulence 0.05}
  normal {brick scale 2.5 turbulence 0.05}
  rotate y*90
  translate <0.5, 0.1,0>
}

#declare T_White_Wall = texture {
  pigment { wrinkles
    color_map {
      [0 rgb Wall_Color]
      [1 rgb Wall_Color*0.92]
    }
    scale 7
  }
}

#declare T_Olive_Paint = texture {
  pigment{rgb ReflectiveSpectrum(RS_Olive_green_gloss_paint)}
  finish {diffuse 0.8 brilliance 2 specular 0.33 roughness 0.009 metallic 0.4
          reflection{0.01 0.075 falloff 2} }
  normal {wrinkles 0.1}
}

#declare T_Black_Plastic = texture {
  pigment{rgb ReflectiveSpectrum(RS_Black_5_C)}
  finish {diffuse 0.8 specular 0.3 roughness 0.009}
}

#declare T_Chrome = texture {
  pigment{rgb ReflectiveSpectrum(RS_Cool_Gray_6_C)}
  finish {diffuse 0.3 brilliance 4 metallic reflection{0.7 metallic} }
}

#declare F_Mondrian = finish {specular 0.3 brilliance 2 roughness 0.011}
#declare T_Mondrian = texture {
  material_map { png "ryb"
    texture {pigment{rgb ReferenceRGB(<0.1,0.09,0.07>)} finish {F_Mondrian} }
    texture {pigment{Mondrian_B_rgb} finish {F_Mondrian} }
    texture {pigment{Mondrian_Y_rgb} finish {F_Mondrian} }
    texture {pigment{Mondrian_R_rgb} finish {F_Mondrian} }
    texture {pigment{rgb ReferenceRGB(<0.91,0.89,0.86>)} finish {F_Mondrian} }
  }
}

#declare T_Bulb_off = texture {
  pigment{rgb ReflectiveSpectrum(RS_Warm_Gray_1_C)}
  finish {diffuse 0.7 specular 0.3 roughness 0.005 reflection{0.1 0.3}}
}

#declare T_Media = texture{pigment{rgbt 1} finish{ambient 0 diffuse 0}}


//=====================================================================
// Camera
camera {
  location <-8, 135, -236>
  right    x*image_width/image_height
  look_at  <34, 128,  0>
  angle 55
 #if (FocalBlur)
  aperture 3.2
  blur_samples 100
  focal_point <20, 128, -25>
  confidence 0.99
  variance 0.00001
 #end
}

//=====================================================================
// Lamps
#declare Tube = union{ // fluorescent tube on the wall
  union {
    box{<-32,-2,-3>, <32,2,3>}
    cylinder {<-32,-2,0>, <-30,-2,0> 3 }
    cylinder {< 32,-2,0>, < 30,-2,0> 3 }
    pigment{rgb ReflectiveSpectrum(RS_Warm_Gray_4_C)}
    #if (L1) finish {ambient 0.6 diffuse 0.01} #end
  }
 #if (L1)
  cylinder{<0,-1,0>, <0,1,0>, 1  
    texture{T_Media}   
    interior{ 
      media{ 
        emission rgb LC1*LM1
        density {         
          cylindrical 
          density_map {
            [0.0 rgb 0]
            [0.5 rgb 0.0004]
            [0.8 rgb 0.001]
          }  
        }
      }
    }      
    scale <4,33,4>
    rotate z*90 translate -y*4
    hollow no_shadow
  }  
 #else
  cylinder{<-30,-4,0>, <30,-4,0>, 2 
    texture{T_Bulb_off}
  }
 #end  
 #if (L1)     
  #local C=Light_Color(LC1,LM1*1/3);
  light_source { 0, rgb C
   #if (AreaLight) area_light 20*x,7*z, 3, 2 adaptive 2 jitter #end 
    Light_Fading()
    translate <-20,-6,0>
  }
  light_source { 0, rgb C
   #if (AreaLight) area_light 20*x,7*z, 3, 2 adaptive 2 jitter #end 
    Light_Fading()
    translate <0,-6,0>
  }
  light_source { 0, rgb C
   #if (AreaLight) area_light 20*x,7*z, 3, 2 adaptive 2 jitter #end 
    Light_Fading()
    translate <20,-6,0>
  }
 #end    
}

#declare Lamp = union { // lamps
  union {
    difference {
      sphere {0, 10}
      plane {y, 1}
      sphere {0, 9.9 pigment {rgb ReflectiveSpectrum(RS_Cool_Gray_1_C)} 
        #if (L2) finish {ambient 0.8 diffuse 0.2} #end }
      translate -y*1.2
    }
    cone {y*8, 4.2, y*15, 3.2}
    cylinder {y*13, y*120, 0.45 texture {T_Black_Plastic} }
    texture{T_Chrome}
  }
  sphere {y*0.5, 2.8
 #if (L2)
    texture{T_Media}
    interior{media{emission Light_Color(LC2,LM2)}}
    hollow no_shadow
 #else
    texture{T_Bulb_off}
 #end
  }
 #if (L2)
  light_source { 0
    Light_Color(LC2,LM2)
  #if (AreaLight) area_light x*7, z*7 4,4 adaptive 2 jitter circular orient #end
    Light_Spot_Cos_Falloff(vcross(x,z))
    Light_Fading()
    translate y*1
  }
 #end
}

#declare Spot = union { // spotlight
  union {
    difference {
      sphere {0, 8}
      plane {y, 0}
      sphere {0, 7.9 pigment {rgb ReflectiveSpectrum(RS_Cool_Gray_1_C)}}
    }
    cone {y*6.5, 4, y*15, 3}
    cylinder {y*1, y*90, 1
      rotate x*30 translate y*10
      texture {T_Black_Plastic}
    }
    texture{T_Chrome}
  }
  sphere {y*0.8, 2.5
 #if (L3)
    texture{T_Media}
    interior{media{emission Light_Color(LC2,LM2)}}
    hollow no_shadow
 #else
    texture{T_Bulb_off}
 #end
  }
 #if (L3)
  light_source { 0
    Light_Color(LC3,LM3)
   #if (AreaLight) area_light x*5, z*5 4,4 adaptive 2 jitter circular orient #end
    spotlight radius 24 falloff 35 tightness 15 point_at -y
    Light_Fading()
    translate y*1
  }
 #end
}    

#declare Window = union {
  box { <-50, 0,0> <50,140,-1> pigment {rgb ReflectiveSpectrum(RS_Warm_Gray_3_C)} }
  box { <-40,10,0> <40,130,0.01>
 #if (LD)
    texture{T_Media}
    interior{media{emission Light_Color(LCD,LMD)}}
    hollow no_shadow
 #else
    pigment {rgb ReflectiveSpectrum(RS_Cool_Gray_10_M)}
    finish {
      diffuse 0.1 specular 0.4 roughness 0.05
      reflection {1 fresnel} conserve_energy}
    interior {ior 1.5}  
 #end
  }
 #if (LD)
  light_source { 0
    Light_Color(LCD,LMD)
   #if (AreaLight) area_light x*80, y*120 6,8 adaptive 2 jitter #end
    Light_Fading()
    Light_Spot_Cos_Falloff(z)
    translate <0,70,9>
  }
 #end
}

object {Lamp translate < 65, 185, 40> }
object {Lamp translate <-65, 185, 40> }
object {Tube rotate <90,90,0> translate <200, 228, 66> }
object {Tube rotate <90,90,0> translate <200, 228,-66> }
#if (PutMondrian)
 object {Spot rotate -x*32 translate <38,275,180> }
#end

//======================================================================
// Room

// floor
plane {y, 0 texture {T_Floor} }
// ceiling
box {<-200,290,-250> <200,300,250> pigment {rgb ReferenceRGB(LightWood)} }
// front wall
union {
  box {<-205,0,250> <205,300,255> texture {T_White_Wall} }
  box {<-200,0,249> <200,4,250>  texture {T_Black_Plastic} }
 #if (PutMondrian)
  box { 0, 1 texture {T_Mondrian} scale <35,39,2>*2.5 translate <-6,112,247>}
 #end   
}
// right wall
union {
  box {< 200,0,-250> < 205,300,250> texture {T_Brick_Wall} }
  box {< 199,0,-250> < 200,  4,250> texture {T_Black_Plastic} }
}
// left wall (with the "window" ) 
union {
  difference {
    box {<-200,0,-250> <-210,300,250> }
    box {<-199,90,-110> <-211,230,-10>  }
    texture {T_White_Wall}
  }  
  box {<-199,0,-250> <-200,  4,250> texture {T_Black_Plastic} }
  object {Window rotate y*90 translate <-209,90,-60> } 
}
// rear wall
union {
  box {<-205,0,-250> < 205,300,-255> texture {T_White_Wall} }
  box {<-200,0,-249> <200,4,-250>  texture {T_Black_Plastic} }
}    
// pipes at right wall
cylinder {<197,0,130> <197,290,130> 3 texture {T_Olive_Paint} }
cylinder {<197,0,139> <197,290,139> 3 texture {T_Olive_Paint} }

//======================================================================
// Chairs

#declare Chair = union {
  difference {
    superellipsoid { <0.25, 0.25> scale <25,2.5,25> }
    sphere { 0, 1 scale <33, 5, 33> translate y*6.1 }
    translate y*50
  }                                     
  #local R = 75;
  #local P1l = vrotate(<0,0,R>,-y*18);
  #local P2l = vrotate(<0,6,R>,-y*19.2);
  #local P1r = <-P1l.x,P1l.y,P1l.z>;
  #local P2r = <-P2l.x,P2l.y,P2l.z>;
  union {
    difference {
      union {
        torus {R, 1.4 }
        cylinder {y*0, y*6, R+1.4}
        torus {R, 1.4 translate y*6}
      }
      plane { x,0 rotate  z*13 rotate -y*18}
      plane {-x,0 rotate -z*13 rotate  y*18}
      cylinder {y*-0.1, y*6.1, R-1.4}
    }        
    sphere {P1l, 1.4} sphere {P2l, 1.4} cylinder {P1l, P2l, 1.4}
    sphere {P1r, 1.4} sphere {P2r, 1.4} cylinder {P1r, P2r, 1.4}
    cylinder { <0,-50, R> <0, 5, R> 1.3 rotate  z*6 rotate -y*16}
    cylinder { <0,-50, R> <0, 5, R> 1.3 rotate  z*3 rotate -y*8}
    cylinder { <0,-50, R> <0, 5, R> 1.3 }
    cylinder { <0,-50, R> <0, 5, R> 1.3 rotate -z*3 rotate  y*8}
    cylinder { <0,-50, R> <0, 5, R> 1.3 rotate -z*6 rotate  y*16}
    rotate x*7
    translate <0,110,-R+29.5>
  }
  cone {<-21,-1,-21> 1.9 <-18,50,-18> 2.8}
  cone {<-21,-1, 21> 1.9 <-18,50, 18> 2.8}
  cone {< 21,-1,-21> 1.9 < 18,50,-18> 2.8}
  cone {< 21,-1, 21> 1.9 < 18,50, 18> 2.8}
  finish {
    diffuse 0.9 brilliance 2 specular 0.275 roughness 0.012
    reflection {0.02 0.1 falloff 2  metallic 0.4}
  }
}

#if (PutChairs)
 object { Chair pigment{Mondrian_Y_rgb} rotate -y*15 translate <-45,0,195> }
 object { Chair pigment{Mondrian_B_rgb} rotate  y*12 translate < 68,0,185> }
 object { Chair pigment{Mondrian_R_rgb} rotate  y*30 translate <150,0,170> }
#end

//======================================================================
// Desk

#declare T_DeskWood = texture {
  pigment{
    wood
    color_map {
      [0.0 rgb ReflectiveSpectrum(RS_DarkWood1)]
      [0.3 rgb ReflectiveSpectrum(RS_DarkWood2)]
      [0.5 rgb ReflectiveSpectrum(RS_DarkWood3)]
      [1.0 rgb ReflectiveSpectrum(RS_DarkWood4)]
    }
    turbulence 0.12
  }
  finish {diffuse 0.8 brilliance 2 specular 0.25 roughness 0.007 reflection{0.09 falloff 2}}
  scale 2.5
  rotate y*90
}

#declare Desk = union {
  box { <-65, 72, -41> <65, 75, 41> texture {T_DeskWood} }
  cylinder { <-57, 0,-33> <-57, 72,-33> 2 texture{T_Chrome} }
  cylinder { <-57, 0, 33> <-57, 72, 33> 2 texture{T_Chrome} }
  cylinder { < 57, 0,-33> < 57, 72,-33> 2 texture{T_Chrome} }
  cylinder { < 57, 0, 33> < 57, 72, 33> 2 texture{T_Chrome} }   
}

//======================================================================
// GretagMacbeth(tm) Colour Checker Chart

// definition for the chart in xyY-format
#declare MacChart_xyY = array[24] {
<0.4398,0.3802, 9.941>,<0.4150,0.3764,35.933>,<0.2764,0.3022,18.545>,<0.3654,0.4513,13.265>,<0.3007,0.2865,23.347>,<0.2865,0.3893,41.598>,
<0.5317,0.4116,30.209>,<0.2356,0.2177,11.179>,<0.5001,0.3293,19.806>,<0.3282,0.2522, 6.534>,<0.4001,0.5001,43.776>,<0.4938,0.4435,44.867>,
<0.2022,0.1585, 5.748>,<0.3266,0.5105,23.111>,<0.5783,0.3253,12.502>,<0.4681,0.4718,61.095>,<0.4201,0.2708,19.576>,<0.2130,0.3003,18.429>,
<0.3491,0.3628,88.558>,<0.3460,0.3589,58.449>,<0.3454,0.3587,35.642>,<0.3473,0.3602,19.488>,<0.3445,0.3582, 8.687>,<0.3462,0.3566, 3.122>
}

#declare MacChart = union {
  union {
    box {<-16,0,-10> <16,.1,10>}
    box {<-15,0,-11> <15,.1,11>}
    cylinder {<-15,0,-10><-15,.1,-10> 1 }
    cylinder {<-15,0, 10><-15,.1, 10> 1 }
    cylinder {< 15,0,-10>< 15,.1,-10> 1 }
    cylinder {< 15,0, 10>< 15,.1, 10> 1 }
    pigment {rgb ReflectiveSpectrum(RS_Black_4_M)}
  }
  #local Row=0;
  #while (Row<4)
    #local Col=0;
    #while (Col<6)
      box { <-2.2,.05,-2.2> <2.2,.105,2.2>
      #local xyY = MacChart_xyY[Row*6+Col];   // get the xyY color from the table
      #local xyY = <xyY.x, xyY.y, xyY.z/100>; // Y given in different scale!
      pigment {rgb MapGamut(xyz2RGB(ChromaMatchSource(xyY2xyz(xyY))))} // convert xyY->rgb
      finish {diffuse 0.95 specular 0.05 roughness 0.009}
      translate <-12.5+Col*5, 0, 7.5-Row*5>
    }
    #local Col=Col+1;
  #end
  #local Row=Row+1;
  text {ttf "cyrvetic" "GretagMacbeth    Colour Checker Chart" 0.1,0
   pigment{rgb ReflectiveSpectrum(RS_Warm_Gray_1_M)}
   rotate x*90  translate <-9,0.105,-10.6>
  }
#end
}

//======================================================================
// a simple glass to prevent the chart from falling
// and another to hold a pen

#declare C_GlassGold = ReferenceRGB(Goldenrod);
#declare C_GlassBlue = ReferenceRGB(SkyBlue);

#declare F_Glass = finish {
  diffuse 0.15 specular 0.6 roughness 0.005
  reflection {1 fresnel on falloff 2}
  conserve_energy 
}

#declare M_GlassGold = material {
  texture {
    pigment {color rgb C_GlassGold filter 1 }
    finish {F_Glass}
  }   
  interior {
    ior 1.5 fade_distance 1.2  fade_power 1001
    fade_color VPow(C_GlassGold,3)
  }
}

#declare M_GlassBlue = material {
  texture {
    pigment {color rgb C_GlassBlue filter 1 }
    finish {F_Glass}
  }   
  interior {
    ior 1.5 fade_distance 1.2 fade_power 1001
    fade_color VPow(C_GlassBlue,3)
  }
}

#declare Glass = merge {
  difference {
    cylinder {<0,0.5,0> <0,12,0> 3.5 }
    cylinder {<0,2.0,0> <0,13,0> 3.1 }
    sphere {0, 3.1 scale <1,0.4,1> translate y*2}
  }
  torus {3.3, 0.2 translate y*12}
  torus {3.0, 0.5 translate y*0.5}
  cylinder {<0,0,0> <0,0.51,0> 3.0}
//  split_union off
}

#local PenBlack  = ReferenceRGB(Gray10);
#local PenWood   = ReferenceRGB(LightWood);
#local PenOrange = ReferenceRGB(<0.8, 0.45, 0.1>);
#local PenRed    = ReferenceRGB(IndianRed);
#declare Pen = union {
  cone {y*0, 0, y*0.15, 0.5}
  cylinder {y*0.15, y*0.97, 0.5}
  sphere {0, 0.5 scale <1,0.035,1> translate y*0.97 }
  pigment { gradient y
    color_map {
      [0.00 rgb PenBlack] [0.04 rgb PenBlack]
      [0.04 rgb PenWood]  [0.15 rgb PenWood]
      [0.15 rgb PenOrange][0.88 rgb PenOrange]
      [0.88 rgb PenBlack] [0.90 rgb PenBlack]
      [0.90 rgb PenOrange][0.92 rgb PenOrange]
      [0.92 rgb PenBlack] [0.94 rgb PenBlack]
      [0.94 rgb PenRed]   [1.00 rgb PenRed]
    }
  }
  scale <1,15,1>
}

#declare GoldGlass = union {
  object {Glass material{M_GlassGold}}
  object {Pen rotate -z*28 translate <-2.8,1.9,0> }
}

#declare BlueGlass = object {Glass material{M_GlassBlue}}

//======================================================================
// Cyndi Lauper's "True Colors" LP
// the sleeve image map was created by using a scanner with Reference
// White of D50, no gamma correction and the Beta_RGB ICC profile. 
                    
#declare PC = CIE_Imagemap(pigment{image_map{png "cyndi" once interpolate 2}})

#declare T_Sleeve_Image = texture{
  pigment{ PC translate -0.5 rotate <90,-90,0> }
  finish{diffuse 0.85 brilliance 2.5 specular 0.275 roughness 0.0065 reflection {0.1 metallic 0.5} } 
}

#declare T_Sleeve_Edge = texture {
  pigment {rgb ReferenceRGB(<0.3, 0.1, 0.01>) }
  finish { diffuse 1 specular 0.2 roughness 0.02 }
}

#declare T_LP = texture {
  pigment {rgb ReferenceRGB(<0.033, 0.032, 0.030>) }
  finish {diffuse 0.8 brilliance 3 specular 0.8 roughness 0.005}
  normal {wood 0.15 triangle_wave rotate x*90 scale 0.01 }
}

//***  Release memory allocated by CIE.inc and SPD's ***
// do this AFTER all colors are processed and before using some memory 
// consuming things like meshes or putting 10 million grass blades!
CIE_ReleaseMemory()

#declare LP = union {
 union {
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.038, 0.250> <0.250, 0.037, 0.325> <0.250, 0.032, 0.425> <0.250, 0.029, 0.500>
  <0.325, 0.035, 0.250> <0.325, 0.034, 0.325> <0.325, 0.027, 0.425> <0.325, 0.025, 0.500>
  <0.425, 0.025, 0.250> <0.425, 0.024, 0.325> <0.425, 0.020, 0.425> <0.425, 0.019, 0.500>
  <0.500, 0.019, 0.250> <0.500, 0.018, 0.325> <0.500, 0.016, 0.425> <0.500, 0.015, 0.500>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.038, 0.250> <0.325, 0.035, 0.250> <0.425, 0.025, 0.250> <0.500, 0.019, 0.250>
  <0.250, 0.039, 0.175> <0.325, 0.036, 0.175> <0.425, 0.025, 0.175> <0.500, 0.019, 0.175>
  <0.250, 0.036, 0.075> <0.325, 0.033, 0.075> <0.425, 0.024, 0.075> <0.500, 0.019, 0.075>
  <0.250, 0.036, 0.000> <0.325, 0.033, 0.000> <0.425, 0.024, 0.000> <0.500, 0.018, 0.000>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.038, 0.250> <0.175, 0.041, 0.250> <0.075, 0.041, 0.250> <0.000, 0.040, 0.250>
  <0.250, 0.037, 0.325> <0.175, 0.040, 0.325> <0.075, 0.040, 0.325> <0.000, 0.040, 0.325>
  <0.250, 0.032, 0.425> <0.175, 0.034, 0.425> <0.075, 0.037, 0.425> <0.000, 0.038, 0.425>
  <0.250, 0.029, 0.500> <0.175, 0.031, 0.500> <0.075, 0.036, 0.500> <0.000, 0.037, 0.500>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.038, 0.250> <0.250, 0.039, 0.175> <0.250, 0.036, 0.075> <0.250, 0.036, 0.000>
  <0.175, 0.041, 0.250> <0.175, 0.042, 0.175> <0.175, 0.039, 0.075> <0.175, 0.039, 0.000>
  <0.075, 0.041, 0.250> <0.075, 0.041, 0.175> <0.075, 0.041, 0.075> <0.075, 0.041, 0.000>
  <0.000, 0.040, 0.250> <0.000, 0.041, 0.175> <0.000, 0.040, 0.075> <0.000, 0.040, 0.000>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.036, 0.000> <0.325, 0.033, 0.000> <0.425, 0.024, 0.000> <0.500, 0.018, 0.000>
  <0.250, 0.035, -0.075> <0.325, 0.032, -0.075> <0.425, 0.024, -0.075> <0.500, 0.018, -0.075>
  <0.250, 0.038, -0.175> <0.325, 0.035, -0.175> <0.425, 0.024, -0.175> <0.500, 0.018, -0.175>
  <0.250, 0.036, -0.250> <0.325, 0.033, -0.250> <0.425, 0.023, -0.250> <0.500, 0.018, -0.250>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.036, 0.000> <0.250, 0.035, -0.075> <0.250, 0.038, -0.175> <0.250, 0.036, -0.250>
  <0.175, 0.039, 0.000> <0.175, 0.039, -0.075> <0.175, 0.042, -0.175> <0.175, 0.039, -0.250>
  <0.075, 0.041, 0.000> <0.075, 0.041, -0.075> <0.075, 0.044, -0.175> <0.075, 0.041, -0.250>
  <0.000, 0.040, 0.000> <0.000, 0.040, -0.075> <0.000, 0.043, -0.175> <0.000, 0.040, -0.250>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.036, -0.250> <0.325, 0.033, -0.250> <0.425, 0.023, -0.250> <0.500, 0.018, -0.250>
  <0.250, 0.033, -0.325> <0.325, 0.030, -0.325> <0.425, 0.022, -0.325> <0.500, 0.017, -0.325>
  <0.250, 0.029, -0.425> <0.325, 0.028, -0.425> <0.425, 0.017, -0.425> <0.500, 0.016, -0.425>
  <0.250, 0.019, -0.500> <0.325, 0.018, -0.500> <0.425, 0.016, -0.500> <0.500, 0.015, -0.500>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.036, -0.250> <0.250, 0.033, -0.325> <0.250, 0.029, -0.425> <0.250, 0.019, -0.500>
  <0.175, 0.039, -0.250> <0.175, 0.037, -0.325> <0.175, 0.029, -0.425> <0.175, 0.020, -0.500>
  <0.075, 0.041, -0.250> <0.075, 0.038, -0.325> <0.075, 0.031, -0.426> <0.075, 0.020, -0.500>
  <0.000, 0.040, -0.250> <0.000, 0.037, -0.325> <0.000, 0.031, -0.426> <0.000, 0.020, -0.500>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.000, 0.040, -0.250> <-0.075, 0.040, -0.250> <-0.175, 0.035, -0.250> <-0.250, 0.031, -0.250>
  <0.000, 0.043, -0.175> <-0.075, 0.043, -0.175> <-0.175, 0.036, -0.175> <-0.250, 0.033, -0.175>
  <0.000, 0.040, -0.075> <-0.075, 0.039, -0.075> <-0.175, 0.033, -0.075> <-0.250, 0.030, -0.075>
  <0.000, 0.040, 0.000> <-0.075, 0.039, 0.000> <-0.175, 0.033, 0.000> <-0.250, 0.030, 0.000> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.000, 0.040, -0.250> <0.000, 0.037, -0.325> <0.000, 0.031, -0.426> <0.000, 0.020, -0.500>
  <-0.075, 0.040, -0.250> <-0.075, 0.037, -0.325> <-0.075, 0.031, -0.426> <-0.075, 0.020, -0.500>
  <-0.175, 0.035, -0.250> <-0.175, 0.033, -0.325> <-0.175, 0.029, -0.425> <-0.175, 0.020, -0.500>
  <-0.250, 0.031, -0.250> <-0.250, 0.030, -0.325> <-0.250, 0.029, -0.425> <-0.250, 0.020, -0.500>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.000, 0.040, 0.000> <-0.075, 0.039, 0.000> <-0.175, 0.033, 0.000> <-0.250, 0.030, 0.000>
  <0.000, 0.040, 0.075> <-0.075, 0.039, 0.075> <-0.175, 0.034, 0.075> <-0.250, 0.031, 0.075>
  <0.000, 0.041, 0.175> <-0.075, 0.040, 0.175> <-0.175, 0.038, 0.175> <-0.250, 0.034, 0.175>
  <0.000, 0.040, 0.250> <-0.075, 0.040, 0.250> <-0.175, 0.038, 0.250> <-0.250, 0.035, 0.250>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.000, 0.040, 0.250> <-0.075, 0.040, 0.250> <-0.175, 0.038, 0.250> <-0.250, 0.035, 0.250>
  <0.000, 0.040, 0.325> <-0.075, 0.039, 0.325> <-0.175, 0.038, 0.325> <-0.250, 0.035, 0.325>
  <0.000, 0.038, 0.425> <-0.075, 0.038, 0.425> <-0.175, 0.036, 0.425> <-0.250, 0.033, 0.425>
  <0.000, 0.037, 0.500> <-0.075, 0.037, 0.500> <-0.175, 0.035, 0.500> <-0.250, 0.033, 0.500>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <-0.250, 0.035, 0.250> <-0.250, 0.034, 0.175> <-0.250, 0.031, 0.075> <-0.250, 0.030, 0.000>
  <-0.325, 0.031, 0.250> <-0.325, 0.031, 0.175> <-0.325, 0.028, 0.075> <-0.325, 0.027, 0.000>
  <-0.425, 0.023, 0.250> <-0.425, 0.024, 0.175> <-0.425, 0.023, 0.075> <-0.425, 0.023, 0.000>
  <-0.500, 0.018, 0.250> <-0.500, 0.019, 0.175> <-0.500, 0.020, 0.075> <-0.500, 0.020, 0.000>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <-0.250, 0.035, 0.250> <-0.325, 0.031, 0.250> <-0.425, 0.023, 0.250> <-0.500, 0.018, 0.250>
  <-0.250, 0.035, 0.325> <-0.325, 0.032, 0.325> <-0.425, 0.023, 0.325> <-0.500, 0.018, 0.325>
  <-0.250, 0.033, 0.425> <-0.325, 0.031, 0.425> <-0.425, 0.022, 0.425> <-0.500, 0.018, 0.425>
  <-0.250, 0.033, 0.500> <-0.325, 0.030, 0.500> <-0.425, 0.022, 0.500> <-0.500, 0.018, 0.500>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <-0.250, 0.030, 0.000> <-0.250, 0.030, -0.075> <-0.250, 0.033, -0.175> <-0.250, 0.031, -0.250>
  <-0.325, 0.027, 0.000> <-0.325, 0.027, -0.075> <-0.325, 0.030, -0.175> <-0.325, 0.028, -0.250>
  <-0.425, 0.023, 0.000> <-0.425, 0.023, -0.075> <-0.425, 0.023, -0.175> <-0.425, 0.023, -0.250>
  <-0.500, 0.020, 0.000> <-0.500, 0.020, -0.075> <-0.500, 0.020, -0.175> <-0.500, 0.019, -0.250>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <-0.250, 0.031, -0.250> <-0.250, 0.030, -0.325> <-0.250, 0.029, -0.425> <-0.250, 0.020, -0.500>
  <-0.325, 0.028, -0.250> <-0.325, 0.027, -0.325> <-0.325, 0.028, -0.425> <-0.325, 0.020, -0.500>
  <-0.425, 0.023, -0.250> <-0.425, 0.023, -0.325> <-0.425, 0.019, -0.425> <-0.425, 0.019, -0.500>
  <-0.500, 0.019, -0.250> <-0.500, 0.019, -0.325> <-0.500, 0.018, -0.425> <-0.500, 0.018, -0.500>
  }
  texture {T_Sleeve_Image}
 }
 union {
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.001, 0.250> <0.250, 0.001, 0.175> <0.250, 0.002, 0.075> <0.250, 0.002, 0.000>
  <0.175, 0.001, 0.250> <0.175, 0.001, 0.175> <0.175, 0.001, 0.075> <0.175, 0.002, 0.000>
  <0.075, -0.000, 0.250> <0.075, -0.001, 0.175> <0.075, 0.001, 0.075> <0.075, 0.001, 0.000>
  <0.000, 0.000, 0.250> <0.000, -0.000, 0.175> <0.000, 0.000, 0.075> <0.000, 0.000, 0.000>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.001, 0.250> <0.175, 0.001, 0.250> <0.075, -0.000, 0.250> <0.000, 0.000, 0.250>
  <0.250, 0.002, 0.325> <0.175, 0.002, 0.325> <0.075, 0.000, 0.325> <0.000, 0.000, 0.325>
  <0.250, 0.003, 0.425> <0.175, 0.003, 0.425> <0.075, 0.002, 0.425> <0.000, 0.002, 0.425>
  <0.250, 0.004, 0.500> <0.175, 0.004, 0.500> <0.075, 0.002, 0.500> <0.000, 0.002, 0.500>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.001, 0.250> <0.250, 0.002, 0.325> <0.250, 0.003, 0.425> <0.250, 0.004, 0.500>
  <0.325, 0.002, 0.250> <0.325, 0.003, 0.325> <0.325, 0.003, 0.425> <0.325, 0.004, 0.500>
  <0.425, 0.003, 0.250> <0.425, 0.002, 0.325> <0.425, 0.003, 0.425> <0.425, 0.003, 0.500>
  <0.500, 0.003, 0.250> <0.500, 0.003, 0.325> <0.500, 0.003, 0.425> <0.500, 0.002, 0.500>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.001, 0.250> <0.325, 0.002, 0.250> <0.425, 0.003, 0.250> <0.500, 0.003, 0.250>
  <0.250, 0.001, 0.175> <0.325, 0.002, 0.175> <0.425, 0.003, 0.175> <0.500, 0.004, 0.175>
  <0.250, 0.002, 0.075> <0.325, 0.002, 0.075> <0.425, 0.003, 0.075> <0.500, 0.004, 0.075>
  <0.250, 0.002, 0.000> <0.325, 0.003, 0.000> <0.425, 0.004, 0.000> <0.500, 0.004, 0.000>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.002, 0.000> <0.250, 0.003, -0.075> <0.250, 0.004, -0.175> <0.250, 0.004, -0.250>
  <0.175, 0.002, 0.000> <0.175, 0.002, -0.075> <0.175, 0.004, -0.175> <0.175, 0.004, -0.250>
  <0.075, 0.001, 0.000> <0.075, 0.001, -0.075> <0.075, 0.002, -0.175> <0.075, 0.002, -0.250>
  <0.000, 0.000, 0.000> <0.000, 0.001, -0.075> <0.000, 0.002, -0.175> <0.000, 0.002, -0.250>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.002, 0.000> <0.325, 0.003, 0.000> <0.425, 0.004, 0.000> <0.500, 0.004, 0.000>
  <0.250, 0.003, -0.075> <0.325, 0.003, -0.075> <0.425, 0.004, -0.075> <0.500, 0.004, -0.075>
  <0.250, 0.004, -0.175> <0.325, 0.005, -0.175> <0.425, 0.004, -0.175> <0.500, 0.004, -0.175>
  <0.250, 0.004, -0.250> <0.325, 0.005, -0.250> <0.425, 0.004, -0.250> <0.500, 0.004, -0.250>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.004, -0.250> <0.250, 0.005, -0.325> <0.250, -0.001, -0.425> <0.250, 0.003, -0.500>
  <0.175, 0.004, -0.250> <0.175, 0.004, -0.325> <0.175, -0.001, -0.425> <0.175, 0.003, -0.500>
  <0.075, 0.002, -0.250> <0.075, 0.003, -0.325> <0.075, -0.002, -0.425> <0.075, 0.003, -0.500>
  <0.000, 0.002, -0.250> <0.000, 0.003, -0.325> <0.000, -0.002, -0.425> <0.000, 0.003, -0.500>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.250, 0.004, -0.250> <0.325, 0.005, -0.250> <0.425, 0.004, -0.250> <0.500, 0.004, -0.250>
  <0.250, 0.005, -0.325> <0.325, 0.005, -0.325> <0.425, 0.004, -0.325> <0.500, 0.004, -0.325>
  <0.250, -0.001, -0.425> <0.325, -0.001, -0.425> <0.425, 0.004, -0.425> <0.500, 0.004, -0.425>
  <0.250, 0.003, -0.500> <0.325, 0.003, -0.500> <0.425, 0.003, -0.500> <0.500, 0.003, -0.500>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.000, 0.002, -0.250> <0.000, 0.003, -0.325> <0.000, -0.002, -0.425> <0.000, 0.003, -0.500>
  <-0.075, 0.002, -0.250> <-0.075, 0.003, -0.325> <-0.075, -0.002, -0.425> <-0.075, 0.003, -0.500>
  <-0.175, 0.004, -0.250> <-0.175, 0.005, -0.325> <-0.175, -0.001, -0.425> <-0.175, 0.003, -0.500>
  <-0.250, 0.004, -0.250> <-0.250, 0.005, -0.325> <-0.250, -0.001, -0.425> <-0.250, 0.003, -0.500>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.000, 0.002, -0.250> <-0.075, 0.002, -0.250> <-0.175, 0.004, -0.250> <-0.250, 0.004, -0.250>
  <0.000, 0.002, -0.175> <-0.075, 0.002, -0.175> <-0.175, 0.004, -0.175> <-0.250, 0.004, -0.175>
  <0.000, 0.001, -0.075> <-0.075, 0.001, -0.075> <-0.175, 0.002, -0.075> <-0.250, 0.003, -0.075>
  <0.000, 0.000, 0.000> <-0.075, 0.001, 0.000> <-0.175, 0.002, 0.000> <-0.250, 0.002, 0.000> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.000, 0.000, 0.000> <-0.075, 0.001, 0.000> <-0.175, 0.002, 0.000> <-0.250, 0.002, 0.000> 
  <0.000, 0.000, 0.075> <-0.075, 0.001, 0.075> <-0.175, 0.002, 0.075> <-0.250, 0.003, 0.075> 
  <0.000, -0.000, 0.175> <-0.075, 0.000, 0.175> <-0.175, 0.003, 0.175> <-0.250, 0.003, 0.175> 
  <0.000, 0.000, 0.250> <-0.075, 0.000, 0.250> <-0.175, 0.003, 0.250> <-0.250, 0.003, 0.250> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.000, 0.000, 0.250> <-0.075, 0.000, 0.250> <-0.175, 0.003, 0.250> <-0.250, 0.003, 0.250> 
  <0.000, 0.000, 0.325> <-0.075, 0.001, 0.325> <-0.175, 0.003, 0.325> <-0.250, 0.003, 0.325> 
  <0.000, 0.002, 0.425> <-0.075, 0.001, 0.425> <-0.175, 0.003, 0.425> <-0.250, 0.003, 0.425> 
  <0.000, 0.002, 0.500> <-0.075, 0.002, 0.500> <-0.175, 0.003, 0.500> <-0.250, 0.003, 0.500> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <-0.250, 0.003, 0.250> <-0.250, 0.003, 0.175> <-0.250, 0.003, 0.075> <-0.250, 0.002, 0.000> 
  <-0.325, 0.003, 0.250> <-0.325, 0.003, 0.175> <-0.325, 0.002, 0.075> <-0.325, 0.002, 0.000> 
  <-0.425, 0.002, 0.250> <-0.425, 0.002, 0.175> <-0.425, 0.001, 0.075> <-0.425, 0.001, 0.000> 
  <-0.500, 0.001, 0.250> <-0.500, 0.001, 0.175> <-0.500, 0.001, 0.075> <-0.500, 0.001, 0.000> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <-0.250, 0.003, 0.250> <-0.325, 0.003, 0.250> <-0.425, 0.002, 0.250> <-0.500, 0.001, 0.250> 
  <-0.250, 0.003, 0.325> <-0.325, 0.004, 0.325> <-0.425, 0.002, 0.325> <-0.500, 0.002, 0.325> 
  <-0.250, 0.003, 0.425> <-0.325, 0.003, 0.425> <-0.425, 0.003, 0.425> <-0.500, 0.003, 0.425> 
  <-0.250, 0.003, 0.500> <-0.325, 0.003, 0.500> <-0.425, 0.003, 0.500> <-0.500, 0.003, 0.500> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <-0.250, 0.002, 0.000> <-0.250, 0.003, -0.075> <-0.250, 0.004, -0.175> <-0.250, 0.004, -0.250> 
  <-0.325, 0.002, 0.000> <-0.325, 0.003, -0.075> <-0.325, 0.004, -0.175> <-0.325, 0.004, -0.250> 
  <-0.425, 0.001, 0.000> <-0.425, 0.002, -0.075> <-0.425, 0.003, -0.175> <-0.425, 0.003, -0.250> 
  <-0.500, 0.001, 0.000> <-0.500, 0.001, -0.075> <-0.500, 0.002, -0.175> <-0.500, 0.002, -0.250> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <-0.250, 0.004, -0.250> <-0.250, 0.005, -0.325> <-0.250, -0.001, -0.425> <-0.250, 0.003, -0.500>
  <-0.325, 0.004, -0.250> <-0.325, 0.005, -0.325> <-0.325, -0.002, -0.425> <-0.325, 0.003, -0.500>
  <-0.425, 0.003, -0.250> <-0.425, 0.003, -0.325> <-0.425, 0.003, -0.425> <-0.425, 0.003, -0.500>
  <-0.500, 0.002, -0.250> <-0.500, 0.002, -0.325> <-0.500, 0.002, -0.425> <-0.500, 0.002, -0.500>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.500, 0.015, -0.500> <0.500, 0.011, -0.500> <0.500, 0.007, -0.500> <0.500, 0.003, -0.500> 
  <0.500, 0.016, -0.425> <0.500, 0.012, -0.425> <0.500, 0.007, -0.425> <0.500, 0.004, -0.425> 
  <0.500, 0.017, -0.325> <0.500, 0.013, -0.325> <0.500, 0.008, -0.325> <0.500, 0.004, -0.325> 
  <0.500, 0.018, -0.250> <0.500, 0.014, -0.250> <0.500, 0.009, -0.250> <0.500, 0.004, -0.250> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.500, 0.015, -0.500> <0.500, 0.011, -0.500> <0.500, 0.007, -0.500> <0.500, 0.003, -0.500> 
  <0.425, 0.016, -0.500> <0.425, 0.013, -0.500> <0.425, 0.007, -0.500> <0.425, 0.003, -0.500> 
  <0.325, 0.018, -0.500> <0.325, 0.017, -0.505> <0.325, 0.004, -0.505> <0.325, 0.003, -0.500> 
  <0.250, 0.019, -0.500> <0.250, 0.019, -0.505> <0.250, 0.004, -0.505> <0.250, 0.003, -0.500> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.500, 0.015, 0.500> <0.500, 0.011, 0.500> <0.500, 0.006, 0.500> <0.500, 0.002, 0.500> 
  <0.500, 0.016, 0.425> <0.500, 0.012, 0.425> <0.500, 0.006, 0.425> <0.500, 0.003, 0.425> 
  <0.500, 0.018, 0.325> <0.500, 0.013, 0.325> <0.500, 0.008, 0.325> <0.500, 0.003, 0.325> 
  <0.500, 0.019, 0.250> <0.500, 0.014, 0.250> <0.500, 0.008, 0.250> <0.500, 0.003, 0.250> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <-0.500, 0.018, 0.500> <-0.500, 0.014, 0.500> <-0.500, 0.008, 0.500> <-0.500, 0.003, 0.500> 
  <-0.500, 0.018, 0.425> <-0.500, 0.014, 0.425> <-0.500, 0.007, 0.425> <-0.500, 0.003, 0.425> 
  <-0.500, 0.018, 0.325> <-0.500, 0.013, 0.325> <-0.500, 0.007, 0.325> <-0.500, 0.002, 0.325> 
  <-0.500, 0.018, 0.250> <-0.500, 0.013, 0.250> <-0.500, 0.006, 0.250> <-0.500, 0.001, 0.250> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <-0.500, 0.018, -0.500> <-0.500, 0.013, -0.500> <-0.500, 0.007, -0.500> <-0.500, 0.002, -0.500> 
  <-0.425, 0.019, -0.500> <-0.425, 0.014, -0.500> <-0.425, 0.007, -0.500> <-0.425, 0.003, -0.500> 
  <-0.325, 0.020, -0.500> <-0.325, 0.019, -0.505> <-0.325, 0.003, -0.505> <-0.325, 0.003, -0.500> 
  <-0.250, 0.020, -0.500> <-0.250, 0.020, -0.505> <-0.250, 0.004, -0.505> <-0.250, 0.003, -0.500> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <-0.500, 0.018, -0.500> <-0.500, 0.013, -0.500> <-0.500, 0.007, -0.500> <-0.500, 0.002, -0.500> 
  <-0.500, 0.018, -0.425> <-0.500, 0.014, -0.425> <-0.500, 0.007, -0.425> <-0.500, 0.002, -0.425> 
  <-0.500, 0.019, -0.325> <-0.500, 0.014, -0.325> <-0.500, 0.007, -0.325> <-0.500, 0.002, -0.325> 
  <-0.500, 0.019, -0.250> <-0.500, 0.014, -0.250> <-0.500, 0.007, -0.250> <-0.500, 0.002, -0.250> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <-0.500, 0.019, -0.250> <-0.500, 0.020, -0.175> <-0.500, 0.020, -0.075> <-0.500, 0.020, 0.000> 
  <-0.500, 0.014, -0.250> <-0.500, 0.014, -0.175> <-0.500, 0.014, -0.075> <-0.500, 0.015, 0.000> 
  <-0.500, 0.007, -0.250> <-0.500, 0.007, -0.175> <-0.500, 0.007, -0.075> <-0.500, 0.007, 0.000> 
  <-0.500, 0.002, -0.250> <-0.500, 0.002, -0.175> <-0.500, 0.001, -0.075> <-0.500, 0.001, 0.000> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <-0.500, 0.020, 0.000> <-0.500, 0.020, 0.075> <-0.500, 0.019, 0.175> <-0.500, 0.018, 0.250> 
  <-0.500, 0.015, 0.000> <-0.500, 0.014, 0.075> <-0.500, 0.014, 0.175> <-0.500, 0.013, 0.250> 
  <-0.500, 0.007, 0.000> <-0.500, 0.007, 0.075> <-0.500, 0.006, 0.175> <-0.500, 0.006, 0.250> 
  <-0.500, 0.001, 0.000> <-0.500, 0.001, 0.075> <-0.500, 0.001, 0.175> <-0.500, 0.001, 0.250> 
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.500, 0.018, -0.250> <0.500, 0.018, -0.175> <0.500, 0.018, -0.075> <0.500, 0.018, 0.000> 
  <0.500, 0.014, -0.250> <0.500, 0.014, -0.175> <0.500, 0.014, -0.075> <0.500, 0.014, 0.000> 
  <0.500, 0.009, -0.250> <0.500, 0.009, -0.175> <0.500, 0.009, -0.075> <0.500, 0.009, 0.000> 
  <0.500, 0.004, -0.250> <0.500, 0.004, -0.175> <0.500, 0.004, -0.075> <0.500, 0.004, 0.000>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.500, 0.018, 0.000> <0.500, 0.019, 0.075> <0.500, 0.019, 0.175> <0.500, 0.019, 0.250>
  <0.500, 0.014, 0.000> <0.500, 0.014, 0.075> <0.500, 0.014, 0.175> <0.500, 0.014, 0.250>
  <0.500, 0.009, 0.000> <0.500, 0.008, 0.075> <0.500, 0.008, 0.175> <0.500, 0.008, 0.250>
  <0.500, 0.004, 0.000> <0.500, 0.004, 0.075> <0.500, 0.004, 0.175> <0.500, 0.003, 0.250>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <-0.250, 0.003, -0.500> <-0.175, 0.003, -0.500> <-0.075, 0.003, -0.500> <0.000, 0.003, -0.500>
  <-0.250, 0.004, -0.505> <-0.175, 0.004, -0.505> <-0.075, 0.004, -0.505> <0.000, 0.004, -0.505>
  <-0.250, 0.020, -0.505> <-0.175, 0.020, -0.505> <-0.075, 0.020, -0.505> <0.000, 0.020, -0.505>
  <-0.250, 0.020, -0.500> <-0.175, 0.020, -0.500> <-0.075, 0.020, -0.500> <0.000, 0.020, -0.500>
  }
  bicubic_patch { type 1 flatness 0 u_steps 3 v_steps 3
  <0.000, 0.003, -0.500> <0.075, 0.003, -0.500> <0.175, 0.003, -0.500> <0.250, 0.003, -0.500>
  <0.000, 0.004, -0.505> <0.075, 0.004, -0.505> <0.175, 0.004, -0.505> <0.250, 0.004, -0.505>
  <0.000, 0.020, -0.505> <0.075, 0.019, -0.505> <0.175, 0.019, -0.505> <0.250, 0.019, -0.505>
  <0.000, 0.020, -0.500> <0.075, 0.020, -0.500> <0.175, 0.020, -0.500> <0.250, 0.019, -0.500>
  }
  texture {T_Sleeve_Edge}
 }
 cylinder { y*0.007, y*0.015, 0.49 texture {T_LP} translate z*0.15 } // LP
 scale 30.8
} 


#if (PutDesk)
  object{Desk rotate y*3   translate <-8,0,-40> }
  object{LP rotate y*120 translate <25,75,-65> }
  object{MacChart translate z*11 rotate -x*35 rotate -y*6 translate <-27,75,-60>}
  object {BlueGlass translate <-25, 75.01, -39> } // behind the chart
  object {GoldGlass rotate y*9 translate < -5, 75.01, -32> } // one more
#end

//---------------------------------------------------------------------
