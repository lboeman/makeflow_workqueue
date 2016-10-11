/*  
  Persistence of Vision Ray Tracer Scene Description File

  Cornell Box test scene for LightsysIV + CIE.inc
  
  Based entirely on the geometry from the "cornell.pov" scene, by Kari Kivisalo, 
  distributed as demo scene with POV-Ray 3.5.

  The purpouse is to obtain the colors from the original cornell-box at the
  Cornell university, with the use of the spectrums offered at their web site
  including reflectance spectrums for the materials.

  See http://www.Graphics.Cornell.edu/online/box/ for the original cornell box 
  (the recommended image size for comparisons is 512x512).
  
  Jaime Vives Piqueres, Apr-2003.

*/
global_settings{
  assumed_gamma 1.0
  radiosity{
    pretrace_start 0.04
    pretrace_end 0.01
    count 140
    recursion_limit 5
    nearest_count 20
    error_bound 0.5
    brightness 1.8
  }
}


// CIE color space macros
#include "CIE.inc"             
#include "CIE_tools.inc"             

// We are guessing some standard camera setup
#declare Cornell_ColSys=sRGB_ColSys;  
CIE_ColorSystemWhitepoint(Cornell_ColSys,Illuminant_D55)
#declare cornell_gamma=1/1.8;


// Main lightsys include
#include "lightsys.inc" 

// original cornell box light (spectrum from the data page)
#declare ES_CornellBox=spline{linear_spline
300,0.0
400,0.0
500,8.0/20
600,15.6/20
700,18.4/20
800,18.4/20
}
#declare Cl_Cornell=EmissiveSpectrum(ES_CornellBox);

// original reflectance spectrums from the cornell university
#include "rspd_cornell.inc" 
CIE_ColorSystemWhitepoint(Cornell_ColSys,Illuminant_D50) 
#declare cl_white=GammaRGB(ReflectiveSpectrum(RS_Cornell_White),cornell_gamma);
#declare cl_red=GammaRGB(ReflectiveSpectrum(RS_Cornell_Red),cornell_gamma);
#declare cl_green=GammaRGB(ReflectiveSpectrum(RS_Cornell_Green),cornell_gamma);
#declare White=texture{pigment{rgb cl_white} finish{diffuse 1 ambient 0}}
#declare Red=texture{pigment{rgb cl_red} finish{diffuse 1 ambient 0}}
#declare Green=texture{pigment{rgb cl_green} finish{diffuse 1 ambient 0}}


// light patches from the cornell.pov scene by Kari Kivisalo
#declare N=3;       // Divisions per side
#declare DX=13/N;   // Dimensions of sub patches
#declare DZ=10.5/N;

// Arbitrary light lumens to match original luminosity
#declare Lumens=40; 

// change color system white point for reflectance spectrum calculations
// subpatch using the light() include
#declare SubPatch=
 object{Light(Cl_Cornell,Lumens/(N*N),<DX,0,0>,<0,0,DZ>,N,N,1) 
   translate <27.8,54.88,27.95>
 }

// patches placement from the cornell.pov scene by Kari Kivisalo
#declare i=0;#while (i<N)
  #declare j=0;#while (j<N)
     light_source{SubPatch translate<i*DX-(13-DX)/2,0,j*DZ-(10.5-DZ)/2>}
  #declare j=j+1;#end
#declare i=i+1;#end


// camera from the cornell.pov scene by Kari Kivisalo
camera{
  location  <27.8, 27.3,-80.0>
  direction <0, 0, 1>
  up        <0, 1, 0>
  right     <-1, 0, 0>
  angle 39.5
}


// The rest of the scene geometry is from the cornell.pov scene by Kari 
// Kivisalo, only the light patch was changed to not interact with lighting

// Light Patch
box{
  <21.3,54.87,33.2><34.3,54.88,22.7> hollow no_shadow 
  pigment{rgbt 1} finish{diffuse 0 ambient 0} interior{media{emission Lumens*10}}
}

union{
  // Floor
  triangle{<55.28, 0.0, 0.0>,<0.0, 0.0, 0.0>,<0.0, 0.0, 55.92>}
  triangle{<55.28, 0.0, 0.0>,<0.0, 0.0, 55.92>,<54.96, 0.0, 55.92>}
  // Ceiling
  triangle{<55.60, 54.88, 0.0>,<55.60, 54.88, 55.92>,<0.0, 54.88, 55.92>}
  triangle{<55.60, 54.88, 0.0>,<0.0, 54.88, 55.92>,<0.0, 54.88, 0.0>}
  // Back wall
  triangle{<0.0, 54.88, 55.92>,<55.60, 54.88, 55.92>,<54.96, 0.0, 55.92>}
  triangle{<0.0, 54.88, 55.92>,<54.96, 0.0, 55.92>,<0.0, 0.0, 55.92>}
  texture {White}
}

union {
  // Right wall
  triangle{<0.0, 54.88, 0.0>,<0.0, 54.88, 55.92>,<0.0, 0.0, 55.92>}
  triangle{<0.0, 54.88, 0.0>,<0.0, 0.0, 55.92>,<0.0, 0.0, 0.0>}
  texture {Green}
}

union {
  // Left wall
  triangle{<55.28, 0.0, 0.0>,<54.96, 0.0, 55.92>,<55.60, 54.88, 55.92>}
  triangle{<55.28, 0.0, 0.0>,<55.60, 54.88, 55.92>,<55.60, 54.88, 0.0>}
  texture {Red}
}

union {
  // Short block
  triangle{<13.00, 16.50, 6.50>,<8.20, 16.50, 22.50>,<24.00, 16.50, 27.20>}
  triangle{<13.00, 16.50, 6.50>,<24.00, 16.50, 27.20>,<29.00, 16.50, 11.40>}
  triangle{<29.00, 0.0, 11.40>,<29.00, 16.50, 11.40>,<24.00, 16.50, 27.20>}
  triangle{<29.00, 0.0, 11.40>,<24.00, 16.50, 27.20>,<24.00, 0.0, 27.20>}
  triangle{<13.00, 0.0, 6.50>,<13.00, 16.50, 6.50>,<29.00, 16.50, 11.40>}
  triangle{<13.00, 0.0, 6.50>,<29.00, 16.50, 11.40>,<29.00, 0.0, 11.40>}
  triangle{<8.20, 0.0, 22.50>,<8.20, 16.50, 22.50>,<13.00, 16.50, 6.50>}
  triangle{<8.20, 0.0, 22.50>,<13.00, 16.50, 6.50>,<13.00, 0.0, 6.50>}
  triangle{<24.00, 0.0, 27.20>,<24.00, 16.50, 27.20>,<8.20, 16.50, 22.50>}
  triangle{<24.00, 0.0, 27.20>,<8.20, 16.50, 22.50>,<8.20, 0.0, 22.50>}
  texture {White}
}

union {
  // Tall block
  triangle{<42.30, 33.00, 24.70>,<26.50, 33.00, 29.60>,<31.40, 33.00, 45.60>}
  triangle{<42.30, 33.00, 24.70>,<31.40, 33.00, 45.60>,<47.20 33.00 40.60>}
  triangle{<42.30, 0.0, 24.70>,<42.30, 33.00, 24.70>,<47.20, 33.00, 40.60>}
  triangle{<42.30, 0.0, 24.70>,<47.20, 33.00, 40.60>,<47.20, 0.0, 40.60>}
  triangle{<47.20, 0.0, 40.60>,<47.20, 33.00, 40.60>,<31.40, 33.00, 45.60>}
  triangle{<47.20, 0.0, 40.60>,<31.40, 33.00, 45.60>,<31.40, 0.0 45.60>}
  triangle{<31.40, 0.0, 45.60>,<31.40, 33.00, 45.60>,<26.50, 33.00, 29.60>}
  triangle{<31.40, 0.0, 45.60>,<26.50, 33.00, 29.60>,<26.50, 0.0, 29.60>}
  triangle{<26.50, 0.0, 29.60>,<26.50, 33.00, 29.60>,<42.30, 33.00, 24.70>}
  triangle{<26.50, 0.0, 29.60>,<42.30, 33.00, 24.70>,<42.30, 0.0, 24.70>}
  texture {White}
}
