/*
  Persistence of Vision Ray Tracer Scene Description File

  CIE.inc test : kelvin blackbody and daylight conversion test tool
  
  Ive, March-2003

*/

global_settings {assumed_gamma 1.0}
#default {finish {ambient 1 diffuse 0}}

#include "colors.inc"

// *** CIE color macros ***
#declare CIE_MultiObserver = true; 
#include "CIE.inc"  

// * select a color system *
//CIE_ColorSystem(CIE_ColSys)
//CIE_ColorSystem(ITU_ColSys)
//CIE_ColorSystem(sRGB_ColSys)   // <- default
//CIE_ColorSystem(NTSC_ColSys)
//CIE_ColorSystem(Adobe_ColSys)
//CIE_ColorSystem(Match_ColSys)
//CIE_ColorSystem(Beta_ColSys)

// * select observer *
//CIE_Observer(CIE_1931)  // <- default
//CIE_Observer(CIE_1964)
//CIE_Observer(CIE_1978)  


//=========================================================

#macro CStr(C)
  concat("<", str(C.x,1,4), ", ", str(C.y,1,4), ", ", str(C.z,1,4), ">")
#end

union {
#declare T=1000;
#while (T<=12000)
  #local Y=12.2-(T/490);      
  #local C = Blackbody(T);
  
  box { <-12,Y-0.02,0> <-7.5,Y+1.0,1> pigment {rgb C} }  
  text{ttf "cyrvetic.ttf" str(T,5,0) 1,0 pigment{Black}
    scale 0.72 translate <-15,Y+0.2,0>
  }
  text{ttf "cyrvetic.ttf" CStr(C)  1,0 pigment{Black}
    scale 0.72 translate <-2,Y+0.2,0>
  }
  #if (T>=4000)
    #local D = Daylight(T);
    
    box { <-7.5,Y-0.02,0> <-3,Y+1.0,1>  pigment {rgb D} }
    text{ttf "cyrvetic.ttf" CStr(D) 1,0 pigment{Black}
      scale 0.75 translate <7.5,Y+0.2,0>
    }
  #end
  #declare T=T+500;
#end

  text{ttf "cyrvetic.ttf" "kelvin"     1,0 pigment{Black}
    scale 0.8 translate <-14.9,11.5,0>  
  }
  text{ttf "cyrvetic.ttf" "blackbody"  1,0 pigment{Black}
    scale 0.8 translate <-12.0,11.5,0>  
  }
  text{ttf "cyrvetic.ttf" "daylight"   1,0 pigment{Black}
    scale 0.8 translate < -7.0,11.5,0>  
  }  
  text{ttf "cyrvetic.ttf" "rgb blackbody" 1,0 pigment{Black}
    scale 0.8 translate < -2.0,11.5,0>  
  }
  text{ttf "cyrvetic.ttf" "rgb daylight" 1,0 pigment{Black}
    scale 0.8 translate <  7.5,11.5,0>  
  }

  scale <1,0.92,1>
  translate -y*0.6
}

text{ttf "cyrvetic.ttf"
  CIE_Observer_String("Observer: ") 1,0 pigment{Black}
  scale 0.8 translate <-15,11.2,0>
}
text{ttf "cyrvetic.ttf"
  CIE_ColorSystem_String("Color System: ") 1,0 pigment{Black}
  scale 0.8 translate <1,11.2,0>
}


background{Gray50}

camera{
  orthographic
  location <0,0,-100>
  direction 4.0*z
  look_at 0
}
