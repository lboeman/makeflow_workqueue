/*
  Persistence of Vision Ray Tracer Scene Description File

  Starfield macros for the demo scene "demo_space.pov". 
  
  Creates a starfield with colors of known kelvin temperatures.

  Jaime Vives Piqueres, Apr-2003.

*/

// individual star
#macro Star(star_type,star_color)

#local star0=
sphere{0,1
   hollow no_shadow
   pigment{rgbt 1}
   interior{
    media{
     emission 1
     density{
      spherical cubic_wave
      density_map{
       [0.0 rgb 0]
       [1.0 rgb star_color]
      }
     }
     scale .4
    }
   }
   finish{ambient 0 diffuse 0 brilliance 0}
}
#local star1=
union{
  sphere{0,1}
  cone{0,1,16*y,.01 rotate 45*0*z}
  cone{0,1,8*y,.01 rotate 45*1*z}
  cone{0,1,16*y,.01 rotate 45*2*z}
  cone{0,1,8*y,.01 rotate 45*3*z}
  cone{0,1,16*y,.01 rotate 45*4*z}
  cone{0,1,8*y,.01 rotate 45*5*z}
  cone{0,1,16*y,.01 rotate 45*6*z}
  cone{0,1,8*y,.01 rotate 45*7*z}
  hollow no_shadow
  scale .1
  pigment{rgbt 1}
  interior{
   media{
    emission .5
    density{
     spherical turbulence .1
     density_map{
      [0.0 rgb 0]
      [1.0 rgb star_color]
     }
    }
   }
  }
  finish{ambient 0 diffuse 0 brilliance 0}
}

#switch (star_type)
 #case (1)
  object{star1}
  #break
 #case (2)
  object{star1 rotate 45*z}
  #break
 #else
  object{star0}
#end

#end  // star macro

// starfield
#macro Starfield(universe,vision,num_stars,star_type,star_size,r_u)

#local StarO=Blackbody(40000);
#local StarB=Blackbody(20000);
#local StarA=Blackbody(10000);
#local StarF=Blackbody(7500);
#local StarG=Blackbody(5500);
#local StarK=Blackbody(4500);
#local StarM=Blackbody(3000);
#local StarColors=array[7]{StarO, StarB, StarA, StarF, StarG, StarK, StarM}
#local i=0;

#declare sbg=universe*1;
#local StrFld=
union{
 // individual stars
 #while (i<num_stars)
 #local star_color=StarColors[int(6.9999999*rand(r_u))];
 object{Star(star_type,star_color)
  // random size
  scale .1+(star_size*((rand(r_u)>.9?.9:.2+rand(r_u)*.3))*rand(r_u)) 
  translate (universe+universe*rand(r_u))*z  // random position
  rotate (-vision+vision*2*rand(r_u))*x             
  rotate (-vision+vision*2*rand(r_u))*y            
 }
 #local i=i+1;
 #end
}

object{StrFld}

#end // macro


