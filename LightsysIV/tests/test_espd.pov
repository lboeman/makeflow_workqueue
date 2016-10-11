/*
  Persistence of Vision Ray Tracer Scene Description File
  
  Emissive spectra test for CIE.inc
  
  Shows (on request) the spectra for the standard illuminant D50 and D65 
  and also the (normalized) spectra for blackbody 5000 and 6500K together 
  with any other emissive spectrum selected by the user.
  Also the xyz, Lab, Lch, and (normalized) rgb value and the resulting 
  (gamma corrected by PoV) rgb color are displayed.
  
  Note: as we are only interested in the chromatisity values, the emissive 
  spectra are normalized and do not represent the emitted energy. The usual 
  normalization (also recommended by the CIE) divides all SPD wavelength 
  values by the peak at the wavelength of 560 nm. But this does not work very
  well for some of the fluorescent spectra so you can also set the variable
  AutoNormalize to true and the spectra is scaled within the range for 
  emissive values from 0.0 to 2.0.
    
  render with:
  +w640 +h480 +A0.2 +AM2

  Ive, April-2003

*/

global_settings {assumed_gamma 1.0}
#default {finish {ambient 1 diffuse 0}}

#include "CIE.inc"
#include "espd_lightsys.inc"
#include "espd_cie_standard.inc"

//================================================================

/* uncomment one of the following spectra: 
  ---------------------------------------------------------------*/
//#declare ES_Test = ES_GE_SW_Incandescent_60w;
//#declare ES_Test = ES_GE_SW_Incandescent_100w;

//#declare ES_Test = ES_GTE_341_Warm;
//#declare ES_Test = ES_GTE_341_Cool;

//#declare ES_Test = ES_Phillips_PLS_11w;
#declare ES_Test = ES_Phillips_Mastercolor_3K;
//#declare ES_Test = ES_Phillips_HPS;

//#declare ES_Test = ES_Osram_CoolBeam_20w;
//#declare ES_Test = ES_Osram_CoolFluor_36w;

//#declare ES_Test = ES_Mitsubishi_Metal_Halide;
//#declare ES_Test = ES_Mitsubishi_Daylight_Fluorescent;
//#declare ES_Test = ES_Mitsubishi_Moon_Fluorescent;
//#declare ES_Test = ES_Mitsubishi_Standard_Fluorescent;

//#declare ES_Test = ES_Solux_Halog4700K;
//#declare ES_Test = ES_Nikon_SB16_XenonFlash;
//#declare ES_Test = ES_Cornell_Box_Light;
//#declare ES_Test = ES_Sunlight;
//#declare ES_Test = ES_Extraterrestrial_Sun;
//#declare ES_Test = ES_Daylight_Fluor;

//#declare ES_Test = ES_Illuminant_B;
//#declare ES_Test = ES_Illuminant_C;
//#declare ES_Test = ES_Illuminant_E;
//#declare ES_Test = ES_Illuminant_F10;
  
/* and/or select one of the following standard illuminants: 
  ---------------------------------------------------------------*/
#declare Show_A   = false; // CIE Standard Illuminant A (per definition blackbody 2856K)
#declare Show_D50 = false; // CIE Standard Illuminant D50
#declare Show_D65 = true;  // CIE Standard Illuminant D65
#declare Show_B50 = false; // Blackbody radiation 5002K
#declare Show_B65 = true;  // Blackbody radiation 6504K

/* and/or show the blackbody radiation curve for any temperature: 
  ---------------------------------------------------------------*/
//#declare ShowBlackbody = 4700; 


/* you can also uncomment this color system statement 
   and play with the whitepoint temperature to simulate
   various 'film temperatures'. Watch the changes in the
   resulting rgb color.
  ---------------------------------------------------------------*/
//CIE_ColorSystemWhitepoint(Adobe_ColSys, Daylight2Whitepoint(4860))
//CIE_ColorSystem(Beta_ColSys)


/* automatic normalization (useful for most of the fluorescent 
   sources and illuminants)
  ---------------------------------------------------------------*/
#declare AutoNormalize = on;

//================================================================

#declare BackColor = rgb 0.01;
#declare GridColor = rgb 0.10;

#declare R=0.005;

union {

  #macro Generate_D(K)
    #local M1=0; #local M2=0;
    DaylightM1M2(K,M1,M2)
    #local D_Color = rgb Daylight(K)*0.33;
    #local I=0;
    #local X2 = 0;
    #local Y2 = (DS012[I][0] + M1*DS012[I][1] + M2*DS012[I][2])/100;
    #while (I<77)
      #local X1 = X2;
      #local Y1 = Y2;
      #local I=I+1;
      #local X2 = I/20;
      #local Y2 = (DS012[I][0] + M1*DS012[I][1] + M2*DS012[I][2])/100;
      sphere{<X1,Y1,0.9>, R pigment{D_Color}}
      cylinder{<X1,Y1,0.9>, <X2,Y2,0.9>, R pigment{D_Color}}
    #end
  #end
  
  #macro Generate_Blackbody(K)
    #local D=PlanckBlackBody(560*1e-9, K);
    #local B_Color = rgb Blackbody(K)*0.33;
    #local I=0;
    #local X2 = 0;                
    #local WL = 380;
    #local Y2 = PlanckBlackBody(WL*1e-9, K)/D;
    #while (I<77)
      #local X1 = X2;
      #local Y1 = Y2;
      #local I=I+1;
      #local WL=WL+5;
      #local X2 = I/20;
      #local Y2 = PlanckBlackBody(WL*1e-9, K)/D;
      sphere{<X1,Y1,0.9>, R pigment{B_Color}}
      cylinder{<X1,Y1,0.9>, <X2,Y2,0.9>, R pigment{B_Color}}
    #end
  #end

  difference {
    box {<-3,-3,0.5> <6.8,5,1.5> pigment {rgb 0.5} }
    box {<0,0,0><3.8,2,1> pigment {BackColor} }
  }

  #ifdef (ES_Test) // graph for the user selected SPD
    #local D = ES_Test(560).y;
    #if (AutoNormalize) 
      #local W = 380;
      #while (W < 760)  // search for max. peak
        #if (ES_Test(W).y/D > 2)
          #local D = ES_Test(W).y/2;
        #end
        #local W=W+1;
      #end
    #else 
    #end  
    #local C = rgb EmissiveSpectrum(ES_Test);
    #local W = 380;
    #local X2 = 0;
    #local Y2 = ES_Test(W).y/D;
    #while (W < 760)
      #local W=W+1;
      #local X1 = X2;
      #local Y1 = Y2;
      #local X2 = (W-380)/100;
      #local Y2 = ES_Test(W).y/D;
      sphere{<X1,Y1,0.8>, R pigment{C}}
      cylinder{<X1,Y1,0.8>, <X2,Y2,0.8>, R pigment{C}}
    #end
  #end  

  #if (Show_D50) // graph for the D50 illuminant
    Generate_D(BoltzmannCorrect(5000))
    text {ttf "cyrvetic" "D50" 1,0 pigment{rgb 0.3} scale 0.08 translate <0.01,0.18,0> }
  #end
 
  #if (Show_D65) // graph for the D65 illuminant
    Generate_D(BoltzmannCorrect(6500))
    text {ttf "cyrvetic" "D65" 1,0 pigment{rgb 0.3} scale 0.08 translate <0.01,0.44,0> }
  #end

  #if (Show_A) // graph for the A illuminant 
    Generate_Blackbody(2856)
  #end
                                                
  #if (Show_B50) // graph for blackbody 5000K
    Generate_Blackbody(5000)
  #end
  
  #if (Show_B65) // graph for blackbody 6500K
    Generate_Blackbody(6500)
  #end  
  
  #ifdef (ShowBlackbody)
    #if (ShowBlackbody>0) Generate_Blackbody(ShowBlackbody) #end
  #end

  // draw the grid lines
  #local WL=380;
  #while (WL<=760)
    #local X = (WL-380)/100;
    cylinder {<X,0,1> <X,2,1>, R pigment{GridColor}}
    cylinder {<X,-0.25,0> <X,-0.15,0>, R pigment{rgb 0.4}}
    text{ttf "cyrvetic" str(WL,1,0) 1,0 scale 0.075 translate <(WL-385)/100, -0.1, -0.1>}
    #local WL=WL+20;
  #end
  #local T=0;
  #while (T<=2.0)
    text{ttf "cyrvetic" str(T,1,1) 1,0 scale 0.075 translate <-0.15, T-0.02, -0.1>}
    cylinder {<0,T,1> <3.8,T,1>, R pigment{GridColor}}
    #local T=T+0.1;
  #end
  
  // draw the rainbow spectrum
  union {
  #local WL=380;
  #while (WL<=760)
    #local X = (WL-380)/100;
    cylinder {<X,-0.25,0> <X,-0.4,0>, 0.01 pigment{rgb Wavelength2RGB(WL)}}
    #local WL=WL+2;
  #end
  }
  
  text{ttf "cyrvetic" "wavelength in nm" 1,0 scale 0.085 translate <1.5, -0.2, -0.1>}
  text{ttf "cyrvetic" "emissive value" 1,0 scale 0.085 rotate z*90 translate <-0.2, 0.75, -0.1>}
  
  pigment{rgb 0}
  scale 10
  translate <-18,-11,0>
}

#ifdef (ES_Test)
  #local XYZ = Emissive2xyz(ES_Test);
  #local LAB = Emissive2Lab(ES_Test);
  #local LCH = Lab2Lch(LAB);
  #local RGB = EmissiveSpectrum(ES_Test);

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
    pigment{rgb 0}
    scale 0.85
    translate <9,9.7,0>
  }
#end  

union {
  text{ttf "cyrvetic" CIE_Observer_String("Color match function: ") 1,0 translate y*5.6 }
  text{ttf "cyrvetic" CIE_ColorSystem_String("Color system: ") 1,0      translate y*4.2 }
  text{ttf "cyrvetic" CIE_Whitepoint_String("Whitepoint: ") 1,0         translate y*2.8 }
  pigment {rgb 0}
  scale 0.85
  translate <-18,9.7,0>
}

camera{
  orthographic
  location -32*z
  look_at 0
}
