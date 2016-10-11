/*
  Persistence of Vision Ray Tracer Scene Description File
  
  Reflective spectra test for cie.inc
  
  Shows any reflective spectrum selected by the user.
  Also the xyz, Lab, Lch, and rgb value and the resulting
  (gamma corrected) rgb color.
  If the rgb color is outside of the color system's gamut
  a message is displayd (e.g. RS_Orange_021_C with sRGB)!

  Ive, April-2003

  render with:
  +w640 +h480 +A0.2 +AM2  
*/

global_settings {assumed_gamma 1.0}            
#default {finish {ambient 1 diffuse 0}} 
        
//#declare CIE_MultiObserver = true;
#include "CIE.inc"
#include "rspd_jvp.inc"
#include "rspd_aster.inc"
#include "rspd_lunar.inc"
#include "rspd_pantone_coated.inc"
#include "rspd_pantone_uncoated.inc"
#include "rspd_pantone_matte.inc"

//=========================================================
/* some examples of reflective spectral data samples from
   the various rsdp files.
   uncomment one of them: 
  ---------------------------------------------------------*/
 
//#declare RS_Test = RS_Red_smooth_faced_Brick; 
//#declare RS_Test = RS_Olive_green_gloss_paint;
//#declare RS_Test = RS_Warm_Red_C;
#declare RS_Test = RS_Orange_021_C;
//#declare RS_Test = RS_EYEONE_WhiteRef;
//#declare RS_Test = RS_OldJohnDeere_Paint;
//#declare RS_Test = RS_ConstrStone8;
//#declare RS_Test = RS_Pearl; ?!?!
//#declare RS_Test = RS_CircuitGreen1;
//#declare RS_Test = RS_Copper_Metal;
//#declare RS_Test = RS_Lunar_Highlands_1;
//#declare RS_Test = RS_Terra_Cotta_Tiles; 

//=========================================================
/* cie.inc settings
   there are many ways to use the various system setting,
   just play with some of them:
  ---------------------------------------------------------*/

//CIE_ColorSystem(sRGB_ColSys) // <- default
//CIE_ColorSystem(Adobe_ColSys)
//CIE_ColorSystem(Match_ColSys)
//CIE_ColorSystem(NTSC_ColSys)
// - or -
//CIE_ColorSystemWhitepoint(sRGB_ColSys, Illuminant_C)
CIE_ColorSystemWhitepoint(sRGB_ColSys, Illuminant_F8)
// - or -
//CIE_ColorSystemWhitepoint(Beta_ColSys, Blackbody2Whitepoint(6500))

//CIE_ReferenceWhite(Illuminant_A)
//CIE_ReferenceWhite(Illuminant_C)
//CIE_ReferenceWhite(Illuminant_D50) // <- default
//CIE_ReferenceWhite(Illuminant_D65)
//CIE_ReferenceWhite(Illuminant_E)

//CIE_ChromaticAdaption(off)
//CIE_ChromaticAdaption(VonKries_ChromaMatch)
//CIE_ChromaticAdaption(Bradford_ChromaMatch) // <- default 

//CIE_GamutMapping(off)

//=========================================================

#local XYZ = Reflective2xyz(RS_Test);
#local LAB = Reflective2Lab(RS_Test); 
#local LCH = Lab2Lch(LAB);
#local RGB = xyz2RGB(XYZ);
#local OutOfGamut = (min(RGB.red, RGB.green, RGB.blue) < 0.0);
#local RGB = MapGamut(RGB);

#declare BackColor = rgb 0.01;
#declare GridColor = rgb 0.10;
#declare SpecColor = rgb vnormalize(RGB);

#declare R=0.005;

union {
  
  difference {                               
    box {<-3,-3,0.5> <6.8,5,1.5> pigment {rgb 0.5}}
    box {<0,0,0><3.8,2,1> pigment {BackColor}}
  }  

  #local WL=380;
  #local X2 = 0;
  #local Y2 = RS_Test(WL).y*2;
  #while (WL<760)
    #local WL=WL+1; 
    #local X1 = X2;
    #local Y1 = Y2;
    #local X2 = (WL-380)/100;
    #local Y2 = RS_Test(WL).y*2;
    sphere{<X1,Y1,0.9>, R pigment{SpecColor}}
    cylinder{<X1,Y1,0.9>, <X2,Y2,1>, R pigment{SpecColor}} 
  #end 
  
  #local WL=380;
  #while (WL<=760)
    #local X = (WL-380)/100;
    cylinder {<X,0,1> <X,2,1>, R pigment{GridColor}}
    cylinder {<X,-0.25,0> <X,-0.15,0>, R pigment{rgb 0.4}}
    text{ttf "cyrvetic" str(WL,1,0) 1,0 scale 0.075 translate <(WL-385)/100, -0.1, -0.1>}      
    #local WL=WL+20;
  #end   

  #local T=0;
  #while (T<=1.0)
    text{ttf "cyrvetic" str(T,1,1) 1,0 scale 0.075 translate <-0.15, (T*2)-0.02, -0.1>}
    cylinder {<0,T*2,1> <3.8,T*2,1>, R pigment{GridColor}}
    #local T=T+0.1;
  #end
  
  union {
  #local WL=380;
  #while (WL<=760)
    #local X = (WL-380)/100;
    cylinder {<X,-0.25,0> <X,-0.4,0>, 0.01 pigment{rgb Wavelength2RGB(WL)}}
    #local WL=WL+2;
  #end   
  }
  
  text{ttf "cyrvetic" "wavelength in nm" 1,0 scale 0.085 translate <1.5, -0.2, -0.1>}
  text{ttf "cyrvetic" "reflectance value" 1,0 scale 0.085 rotate z*90 translate <-0.2, 0.7, -0.1>}
  
  pigment{rgb 0}
  scale 10
  translate <-18,-11,0>
}

#macro CStr(N,C,D) concat(N," ",str(C.x,1,D),", ", str(C.y,1,D),", ", str(C.z,1,D)) #end           

union {
  box {<0.9, 0.9, 0.6> <5.1, 5.1, 1> pigment {rgb 0.4}}
  box {<1.0, 1.0, 0.5> <5.0, 5.0, 1> pigment {rgb RGB}}
  translate <3,9.5,0>
}  

union {
  text {ttf "cyrvetic" CStr("XYZ:",XYZ,4) 1,0 translate y*5.6 }
  text {ttf "cyrvetic" CStr("LAB:",LAB,1) 1,0 translate y*4.2 }
  text {ttf "cyrvetic" CStr("LCH:",LCH,1) 1,0 translate y*2.8 }
  text {ttf "cyrvetic" CStr("RGB:",RGB,4) 1,0 translate y*1.4 }
 #if (OutOfGamut)
  text {ttf "cyrvetic" "out of gamut!" 1,0 translate y*0.0 }
 #end
  pigment{rgb 0} 
  scale 0.85
  translate <9.0,9.7,0>
}    

union {
  text{ttf "cyrvetic" CIE_Observer_String("Color match function: ") 1,0        translate y*5.6 }
  text{ttf "cyrvetic" CIE_ColorSystem_String("Color system: ") 1,0             translate y*4.2 }
  text{ttf "cyrvetic" CIE_Whitepoint_String("Whitepoint: ") 1,0                translate y*2.8 } 
  text{ttf "cyrvetic" CIE_ReferenceWhite_String("Reference White: ") 1,0       translate y*1.4 }      
  text{ttf "cyrvetic" CIE_ChromaticAdaption_String("Chromatic adaption: ") 1,0 translate y*0.0 }
  pigment {rgb 0}
  scale 0.85
  translate <-18,9.7,0>
}  

camera{    
  orthographic
  location -32*z
  look_at 0
}
