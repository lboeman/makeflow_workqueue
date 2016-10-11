/*
  Persistence of Vision Ray Tracer Scene Description File
  
  Line spectra test for CIE.inc
    
  render with:
  +w640 +h480 +A0.2 +AM2

  Ive, April-2003

*/

global_settings {assumed_gamma 1.0}
#default {finish {ambient 1 diffuse 0}}

#include "CIE.inc"
#include "lspd_elements.inc"
//CIE_ColorSystemWhitepoint(Beta_ColSys, Illuminant_D65)
//CIE_ColorSystem(HOT_ColSys)


//================================================

// mix your own thing !!!
/*
#declare Lspd_Mix = array[4] {
  LS_Silicon,
  LS_Neon,
  LS_Argon,
  LS_Xenon
} 
#declare F_Mix = array[4][2] {
  {0.56, 2}, // 55% Neon   I-II
  {0.10, 1}, // 10% Neon   I
  {0.14, 2}, // 15% Argon  I-II
  {0.20, 2}  // 20% Xenon  I-II
}   
*/

/*
#declare Lspd_Mix = array[3] {
  LS_Sodium,
  LS_Chlorine,
  LS_Silicon
} 
#declare F_Mix = array[3][2] {
  {0.05, 2}, //  5% Na   
  {0.05, 2}, //  5% Cl   
  {0.90, 2}  // 90% Si
}
*/

// or select just one element from lspd_elements.inc
///*
#declare LS_Test = LS_Sulfur;
//*/

//================================================
    

#macro LineSpectrumMixArray(LS,LF)
  #local NE = dimension_size(LS,1);
  #local E = 0; 
  #local Total = 0;
  #while (E<NE)
    #local Element = LS[E];
    #local Total = Total+dimension_size(Element,1); 
    #local E=E+1;
  #end
  #local E = 0; 
  #local Mix = array[Total][3];
  #local I=0;
  #while (E<NE)
    #local Element = LS[E];
    #local F = LF[E][0];
    #local Ion = LF[E][1];
    #local NK = dimension_size(Element,1); 
    #local K = 0;
    #while (K<NK)
      #local Mix[I][0] = Element[K][0]; 
      #if (Element[K][2]<=Ion)
        #local Mix[I][1] = Element[K][1]*F;
      #else                
        #local Mix[I][1] = 0;
      #end  
      #local Mix[I][2] = Element[K][2];
      #local K=K+1;
      #local I=I+1;
    #end 
    #local E=E+1;
  #end   
  Mix
#end
       
#ifndef (LS_Test)       
  #declare LS_Test = LineSpectrumMixArray(Lspd_Mix, F_Mix);
#else
#end
#declare BackColor = rgb 0.01;
#declare GridColor = rgb 0.10;
#declare Rainbow   = 0.1;

#declare R=0.005;

union {
  difference {
    box {<-3,-3,0.5> <6.8,5,1.5> pigment {rgb 0.5} }
    box {<0,0,0><3.8,2,1> pigment {BackColor} }
  }
  #local N = dimension_size(LS_Test,1);
  #local D=0;
  #local K = 0; 
  #while (K < N)
    #if (LS_Test[K][1]>D) #local D = LS_Test[K][1]; #end  
    #local K=K+1;
  #end 
  #local K = 0; 
  #local CM = 0;
  #local XYZ = 0;
  #while (K < N)     
    #local W = LS_Test[K][0];
    #local X = (W-380)/100;
    #local Y = LS_Test[K][1]*2/D;
    #if ((Y>0) & (W<=760))
      cylinder {<X,0,0.8>, <X,Y,0.8> 0.006 pigment {rgb Wavelength(W)} }
      cylinder {<X,-0.25,-0.1>, <X,-0.4,-0.1> 0.006 
        pigment {rgb Wavelength2RGB(W)*Rainbow+Wavelength(W)*CMF_xyz(W).y*Y*2} 
      }
    #end  
    #local K=K+1;
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
  #while (T<=1.0)
    text{ttf "cyrvetic" str(T*D,1,0) 1,0 scale 0.075 translate <-0.21, (T*2)-0.02, -0.1>}
    cylinder {<0,T*2,1> <3.8,T*2,1>, R pigment{GridColor}}
    #local T=T+0.1;
  #end
  
  // draw the rainbow spectrum
  union {
  #local WL=380;
  #while (WL<=760)
    #local X = (WL-380)/100;
    cylinder {<X,-0.25,0> <X,-0.4,0>, 0.01 pigment{rgb Wavelength2RGB(WL)*0.1}}
    #local WL=WL+2;
  #end
  }
  
  text{ttf "cyrvetic" "wavelength in nm" 1,0 scale 0.085 translate <1.5, -0.2, -0.1>}
  text{ttf "cyrvetic" "emissive value" 1,0 scale 0.085 rotate z*90 translate <-0.24, 0.75, -0.1>}
  
  pigment{rgb 0}
  scale 10
  translate <-18,-11,0>
}

#ifdef (LS_Test)
  #local XYZ = LineSpectrum2xyz(LS_Test,8);
  #local LAB = LineSpectrum2Lab(LS_Test,8);
  #local LCH = Lab2Lch(LAB);      
  #local RGB = LineSpectrum(LS_Test,8);
//  #local RGB = LineSpectrumMix(Lspd_Mix, F_Mix);

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
