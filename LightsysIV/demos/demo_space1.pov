/*
  Persistence of Vision Ray Tracer Scene Description File

  Demo scene showing usage of CIE.inc and LightsysIV for space scenes. 
  
  Creates a starfield with colors of known kelvin temperatures, and a 
  planetary nebulae with real elements colors.

  Jaime Vives Piqueres, Apr-2003.

*/
global_settings{
 assumed_gamma 1.5
 max_trace_level 16
}

// include predefined functions to use as nebulae shape
#include "functions.inc"


// *** CIE & LIGHTSYS ***
#include "CIE.inc"
//CIE_ChromaticAdaption(off)      
CIE_ColorSystem(CIE_ColSys)
//CIE_ColorSystem(HOT_ColSys)
#include "lspd_elements.inc"     // elements line spectra and macros 
#include "lightsys.inc"          // for the central star light


// *** UNIVERSE DATA ***
#declare universe=20000;  // universe shell dimension
#declare vision=12;  // starfield section angle
#declare use_stars=1;     
#declare star_type=1;    // 0=round, 1=spiky
#declare star_size=100;   
#declare r_s=seed(17);   // stars random seed
#declare num_stars=1000;
#declare use_nebulae=1;
#declare r_u=seed(219);   // nebulae random seed


// *** STARFIELD ***
#if (use_stars)
// using starfield macro to generate some background stars
#include "demo_starfield.inc"
object{
 Starfield(universe,vision,num_stars,star_type,star_size,r_s)
}
#end 


// *** NEBULAE ***
#if (use_nebulae)

// nebulae shape functions
#declare dp=100*rand(r_u);
#declare f_Nebulae=
function{
 pigment{
//  spherical
  spiral1 4
  pigment_map{
   [0 crackle 
      translate dp 
      scale 25 warp{turbulence 1} scale 1/25
      warp{spherical}
   ]
   [dp*.1 marble 
      translate dp*2 
      scale 25 warp{turbulence 1} scale 1/25
      warp{spherical}
   ]
   [1 bumps 
      translate dp/2 
      scale 25 warp{turbulence 1} scale 1/25
      warp{spherical}
   ]
  }
 // scale .5
 }
}

// basic nebulae density
#declare d_nebulae_emission=
density{
    function{f_Nebulae(abs(x),abs(y),abs(z)).gray}
    density_map{
     [0.00 rgb 0]
     [.10 rgb LineSpectrum(LS_Carbon,1)]
     #if (rand(r_u)>.5)
     [.1+.05*rand(r_u) rgb 0]
     #end
     #if (rand(r_u)>.5)
     [.15+.10*rand(r_u) rgb 0]
     #end
     [.25 rgb LineSpectrum(LS_Helium,2)]
     #if (rand(r_u)>.5)
     [.25+.05*rand(r_u) rgb 0]
     #end
     #if (rand(r_u)>.5)
     [.30+.10*rand(r_u) rgb 0]
     #end
     [.40 rgb LineSpectrum(LS_Hydrogen,1)]
     #if (rand(r_u)>.5)
     [.40+.05*rand(r_u) rgb 0]
     #end
     #if (rand(r_u)>.5)
     [.45+.10*rand(r_u) rgb 0]
     #end
     [.55 rgb LineSpectrum(LS_Neon,1)]
     #if (rand(r_u)>.5)
     [.55+.05*rand(r_u) rgb 0]
     #end
     #if (rand(r_u)>.5)
     [.60+.10*rand(r_u) rgb 0]
     #end
     [.70 rgb LineSpectrum(LS_Krypton,2)]
     #if (rand(r_u)>.5)
     [.70+.05*rand(r_u) rgb 0]
     #end
     #if (rand(r_u)>.5)
     [.75+.10*rand(r_u) rgb 0]
     #end
     [.85 rgb LineSpectrum(LS_Oxygen,3)]
     #if (rand(r_u)>.5)
     [.85+.15*rand(r_u) rgb 0]
     #end
     [1.00 rgb 0]
    } 
    phase rand(r_u)
}

// fade basic density spherically
#declare ttmp=100*rand(r_u);
#declare d_sph_neb_emission=
   density{
    spherical
    density_map{
     [0.0 rgb 0]
     [1.0 d_nebulae_emission]
    }
    scale 25 warp{turbulence .2+.2*rand(r_u) lambda 3} scale 1/25
   }

// nebulae object
#declare Nebulae=
sphere{0,1 
 hollow //no_shadow
 pigment{rgbt 1}
 interior{ 
  media{
   intervals 3
   scattering{4,.00005}
   density{d_sph_neb_emission}
   scale .5
  }
 }
 finish{ambient 0 diffuse 0 brilliance 0}
}

// placement
object{Nebulae scale 1500 
 rotate <360*rand(r_u),360*rand(r_u),360*rand(r_u)>
 translate <0,0,1000>
}
#declare lc=Blackbody(30000+70000*rand(r_u));
light_source{
 0
 Light_Color(1,1000000)
 Light_Fading()
}

// Central nebulae star, behind it to avoid seing the container
object{Star(star_type,lc) scale 40} 
#end


camera{
 location -5000*z
 direction 4*z
 look_at 1000*z
}
