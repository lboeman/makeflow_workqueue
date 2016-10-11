/*
  Persistence of Vision Ray Tracer Scene Description File

  CIE.inc demo: altering image_map color system. 

  There are several examples: the first two show how to "correct" the temperature 
  of a badly taken photo. On the second pair, we show how a image will look under 
  a different color system.

  Jaime Vives Piqueres, Oct-2003.

*/

global_settings{
// assumed_gamma 1.0  // depends on image stored gamma! Not for jpg!
}

#include "colors.inc"        
#include "finish.inc"


// *** CIE color macros ***
#include "CIE.inc"

// *** switch between the 4 examples ***
#declare example=1;


// *** Example 1 ***
#if (example=1)
// White balance correction of a bad photo (daylight film on incandescent).
// Input image: taken by me with a friend camera (SONY MVC FD88).
#declare input_image=pigment{image_map{jpeg "im_test_inc.jpg"}}
// Input color system :
CIE_ColorSystemWhitepoint(Adobe_ColSys,Illuminant_D50)
#declare input_0=RGB2xyz(<0,0,0>);
#declare input_r=RGB2xyz(<1,0,0>);
#declare input_g=RGB2xyz(<0,1,0>);
#declare input_b=RGB2xyz(<0,0,1>);
#declare input_w=RGB2xyz(<1,1,1>);
// Ouput color system:
#declare My_ColSys=array[4][4];
#declare My_ColSys[0][0]=input_r.x;
#declare My_ColSys[0][1]=input_r.y;
#declare My_ColSys[1][0]=input_g.x;
#declare My_ColSys[1][1]=input_g.y;
#declare My_ColSys[2][0]=input_b.x;
#declare My_ColSys[2][1]=input_b.y;
#declare My_ColSys[3][0]=input_w.x;
#declare My_ColSys[3][1]=input_w.y;
CIE_ColorSystemWhitepoint(My_ColSys,Blackbody2Whitepoint(3400))
#declare output_0=(xyz2RGB(input_0));
#declare output_r=(xyz2RGB(input_r));
#declare output_g=(xyz2RGB(input_g));
#declare output_b=(xyz2RGB(input_b));
#end


// *** Example 2 ***
#if (example=2)
// White balance correction of a bad photo (indoor film on daylight).
// Input image: taken by me with a friend camera (SONY MVC FD88)
#declare input_image=pigment{image_map{jpeg "im_test_day.jpg"}}
// Input color system :
CIE_ColorSystemWhitepoint(CIE_ColSys,Illuminant_A)
#declare input_0=RGB2xyz(<0,0,0>);
#declare input_r=RGB2xyz(<1,0,0>);
#declare input_g=RGB2xyz(<0,1,0>);
#declare input_b=RGB2xyz(<0,0,1>);
#declare input_w=RGB2xyz(<1,1,1>);
// Ouput color system:
#declare My_ColSys=array[4][4];
#declare My_ColSys[0][0]=input_r.x;
#declare My_ColSys[0][1]=input_r.y;
#declare My_ColSys[1][0]=input_g.x;
#declare My_ColSys[1][1]=input_g.y;
#declare My_ColSys[2][0]=input_b.x;
#declare My_ColSys[2][1]=input_b.y;
#declare My_ColSys[3][0]=input_w.x;
#declare My_ColSys[3][1]=input_w.y;
CIE_ColorSystemWhitepoint(My_ColSys,Daylight2Whitepoint(5500))
#declare output_0=xyz2RGB(input_0);
#declare output_r=xyz2RGB(input_r);
#declare output_g=xyz2RGB(input_g);
#declare output_b=xyz2RGB(input_b);
#end

// *** Example 3 ***
#if (example=3)
// How an sRGB image will look if it where an Adobe image.
// Input image: courtesy of Norman Koren (www.normankoren.com)
#declare input_image=pigment{image_map{jpeg "im_test_sRGB.jpg"}}
// Input color system :
CIE_ColorSystemWhitepoint(sRGB_ColSys,Illuminant_D50)
#declare input_0=RGB2xyz(<0,0,0>);
#declare input_r=RGB2xyz(<1,0,0>);
#declare input_g=RGB2xyz(<0,1,0>);
#declare input_b=RGB2xyz(<0,0,1>);
// Ouput color system:
CIE_ColorSystemWhitepoint(Adobe_ColSys,Illuminant_D50)
#declare output_0=MapGamut(xyz2RGB(input_0));
#declare output_r=MapGamut(xyz2RGB(input_r));
#declare output_g=MapGamut(xyz2RGB(input_g));
#declare output_b=MapGamut(xyz2RGB(input_b));
#end


// *** Example 4 ***
#if (example=4)
// How an Adobe image will look if it where an sRGB.
// Input image: courtesy of Norman Koren (www.normankoren.com)
#declare input_image=pigment{image_map{jpeg "im_test_Adobe.jpg"}}
// Input color system :
CIE_ColorSystemWhitepoint(Adobe_ColSys,Illuminant_D50)
#declare input_0=RGB2xyz(<0,0,0>);
#declare input_r=RGB2xyz(<1,0,0>);
#declare input_g=RGB2xyz(<0,1,0>);
#declare input_b=RGB2xyz(<0,0,1>);
// Ouput color system:
CIE_ColorSystemWhitepoint(sRGB_ColSys,Illuminant_D50)
#declare output_0=(xyz2RGB(input_0));
#declare output_r=(xyz2RGB(input_r));
#declare output_g=(xyz2RGB(input_g));
#declare output_b=(xyz2RGB(input_b));
#end

// *** transform ***
#declare fn = function { pigment{input_image} }
#declare t_output_image=
texture{
 pigment{
 average
  pigment_map{
   [function{fn(x,y,z).red}   color_map{[0 rgb output_0][1 rgb output_r*3]}]
   [function{fn(x,y,z).green} color_map{[0 rgb output_0][1 rgb output_g*3]}]
   [function{fn(x,y,z).blue}  color_map{[0 rgb output_0][1 rgb output_b*3]}]
  }
 }
 finish{ambient 1}
}


#include "screen.inc"
Screen_Plane(texture{t_output_image},1,<0,0,0>,<1,1,0>)
