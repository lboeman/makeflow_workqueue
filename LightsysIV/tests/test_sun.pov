/*
  Persistence of Vision Ray Tracer Scene Description File
  
  Solar spectrum test for CIE.inc
  
  Shows the spectrum for the sun (without the filtering of the 
  earth atmosphere) based on the "Wehrli Spectrum". 
  The blackbody radiation curve for any user defined temperature
  is displayed for comparision.
  Also the xyz, (normalized) rgb value and the resulting (gamma 
  corrected) rgb color.
  
  Even if the resolution of the spectrum is not small enough, the 
  rainbow spectrum below shows already some major absorption caused
  by the elements present in the atmosphere of the sun. Those dark
  lines are known as "Fraunhofer lines".
  G-line at 430.8nm for Fe & Ca
  F-line at 486.1nm for H 
  E-line at 527 nm  for Fe
  for more details look e.g at: 
    http://www.harmsy.freeuk.com/fraunhofer.html 
    
  see also "What colour is the Sun?" 
    http://casa.colorado.edu/~ajsh/colour/Tspectrum.html  
    
  render with:
  +w800 +h600 +A0.1 +AM2

  Ive, April-2003

*/

global_settings {assumed_gamma 1.0}
#default {finish {ambient 1 diffuse 0}}

#declare CIE_MultiObserver = true;
#include "CIE.inc"
#include "espd_sun.inc"

CIE_Observer(CIE_1931)
//CIE_Observer(CIE_1964)
//CIE_Observer(CIE_1978)
                               
/* set the integral step to 1 instead of 5 to fit for those small 
   peaks in the solar spectrum
 */  
#declare CIE_IntegralStep = 1;
 
//================================================================
/* the blackbody radiation curve for the given temperature: 
  ---------------------------------------------------------------*/
  
/* 5780 Kelvin is the surface temperature of the sun 
 */ 
#declare ShowBlackbody = 5780;   

/* 5885 Kelvin seems to be a quite good color
   approximation for the 1931 CMF
 */
//#declare ShowBlackbody = 5885;


/* you can also uncomment this color system statement 
   and play with the whitepoint temperature to simulate
   various 'film temperatures'. Watch the changes in the
   resulting rgb color.
  ---------------------------------------------------------------*/
//CIE_ColorSystemWhitepoint(Adobe_ColSys, Daylight2Whitepoint(5500))

//================================================================

#declare BackColor = rgb 0.01;
#declare GridColor = rgb 0.10;

#declare R=0.0025;

union {

  difference {
    box {<-3,-3,0.5> <6.8,5,1.5> pigment {rgb 0.5} }
    box {<0,0,0><3.8,2,1> pigment {BackColor} }
  }

  #local D = ES_Sun(560).y;
  #local C = rgb EmissiveSpectrum(ES_Sun);
  #local WL = 380;
  #local X2 = 0;
  #local Y2 = ES_Sun(WL).y/D;
  #while (WL < 760)
    #local WL=WL+0.5;
    #local X1 = X2;
    #local Y1 = Y2;
    #local X2 = (WL-380)/100;
    #local Y2 = ES_Sun(WL).y/D;
    sphere{<X1,Y1,0.8>, R pigment{C}}
    cylinder{<X1,Y1,0.8>, <X2,Y2,0.8>, R pigment{C}}
  #end                  

  
  #ifdef (ShowBlackbody)
    #local D=PlanckBlackBody(560*1e-9, ShowBlackbody);
    #local B_Color = rgb Blackbody(ShowBlackbody)*0.3;
    #local I=0;
    #local X2 = 0;                
    #local WL = 380;
    #local Y2 = PlanckBlackBody(WL*1e-9, ShowBlackbody)/D;
    #while (I<77)
      #local X1 = X2;
      #local Y1 = Y2;
      #local I=I+1;
      #local WL=WL+5;
      #local X2 = I/20;
      #local Y2 = PlanckBlackBody(WL*1e-9, ShowBlackbody)/D;
      sphere{<X1,Y1,0.9>, R pigment{B_Color}}
      cylinder{<X1,Y1,0.9>, <X2,Y2,0.9>, R pigment{B_Color}}
    #end
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
    cylinder {<X,-0.25,0> <X,-0.4,0>, 0.01 pigment{rgb vnormalize(Wavelength2RGB(WL))*ES_Sun(WL).y/2}}
    #local WL=WL+0.5;
  #end
  }
  
  text{ttf "cyrvetic" "wavelength in nm" 1,0 scale 0.085 translate <1.5, -0.2, -0.1>}
  text{ttf "cyrvetic" "emissive value" 1,0 scale 0.085 rotate z*90 translate <-0.2, 0.75, -0.1>}
  
  pigment{rgb 0}
  scale 10
  translate <-18,-11,0>
}


#local s_XYZ = Emissive2xyz(ES_Sun);
#local s_RGB = MapGamutNorm(xyz2RGB(s_XYZ));

#ifdef (ShowBlackbody)
  #local b_XYZ = Blackbody2xyz(ShowBlackbody);
  #local b_RGB = MapGamutNorm(xyz2RGB(b_XYZ));
#end

#macro CStr(N,C,D) concat(N," ",str(C.x,1,D),", ", str(C.y,1,D),", ", str(C.z,1,D)) #end

union {
  box {<0.9, 0.9, 0.6> <5.1, 5.1, 1> pigment {rgb 0.4}}
#ifdef (ShowBlackbody)  
  box {<1.0, 3.0, 0.5> <5.0, 5.0, 1> pigment {rgb s_RGB}}
  box {<1.0, 1.0, 0.5> <5.0, 3.0, 1> pigment {rgb b_RGB}}
#else
  box {<1.0, 1.0, 0.5> <5.0, 5.0, 1> pigment {rgb s_RGB}}
#end  
  translate <3,9.5,0>
}

union {
  text {ttf "cyrvetic" "Solar spectrum" 1,0 translate y*6.4 }
  text {ttf "cyrvetic" CStr("XYZ:",s_XYZ,4) 1,0 translate y*5.2 }
  text {ttf "cyrvetic" CStr("RGB:",s_RGB,4) 1,0 translate y*4.0 }
#ifdef (ShowBlackbody)
  text {ttf "cyrvetic" concat("Blackbody ",str(ShowBlackbody,1,0),"K") 1,0 translate y*2.4 }
  text {ttf "cyrvetic" CStr("XYZ:",b_XYZ,4) 1,0 translate y*1.2 }
  text {ttf "cyrvetic" CStr("RGB:",b_RGB,4) 1,0 translate y*0.0 }
#end  
  pigment{rgb 0}
  scale 0.75
  translate <9,9.7,0>
}

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
