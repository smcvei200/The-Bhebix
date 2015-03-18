globals
[
  num-caves
  num-food
  num-agents
  bhebix-list
  berry-list
  nearest-berry
  nearest-agent
  nearest-cave
  newfood
  day 
  nighttime
  partner-agent
  partner-energy
  pregnant-bhebix
  raining
  rainfall
  moisture
  interactions
  hunting-season
  taikubb-list
  nearest-prey
]

breed [ food berries ]    ;; these are the resources the agents will consume
breed [ agent bhebix ]    ;; these are the main agents
breed [ shelter cave ]    ;; will provide the bhebix with shelter
breed [ predator taikubb ]

agent-own
[
 energy ;; attribute to hold the energy of each individual agent
 affection ;; attribute to hold the affection level of each individual agent
 sleeping ;;
 age ;;
 pregnant ;;
 labour-steps ;;
 ask-cuddle
]

predator-own
[
  death
]

to setup
  clear-all  ;; clear the environment to start fresh
  reset-ticks
  
  set pregnant-bhebix 0;
  set nighttime 0
  set num-food 20 ;; set the initial number of food items
  set num-agents NumberAgents ;; set the initial number of agents
  set num-caves NumberCaves ;; set the number of caves in the terrain
  
  set day 0
  ask patches[ set pcolor green ]  ;; set background colour to green 
  
  set-default-shape food "berries" ;; set the shape of the food resources
  set-default-shape agent "bhebix" ;; set the shape of the agents
  set-default-shape shelter "cave" ;; set the shape of the shelter
  set-default-shape predator "taikubb"
  
  set raining 0
  set rainfall 0
  set moisture 100
  
  
  set interactions 0
  set hunting-season 0
  
  ask n-of num-food patches [ sprout-food 1 ]  ;; randomly generate food on patches 
  ask n-of num-agents patches with [ not any? turtles-here ][ sprout-agent 1 ] ;; generate agent on random patch as long as there is no other turtles
  ask n-of num-caves patches with [ not any? turtles in-radius 30 with [breed = shelter]  ][ sprout-shelter 1 ] ;; generate a cave on a random patch as long as there are no other turtles on that patch
  
  ask shelter [ set size 3 ]
  ask agent [ set size 2 ]
  ask agent [ set energy 100 ]
  ask agent [ set affection 100 ]
  ask agent [ set sleeping false ]
  ask agent [ set age 0 ]
  ask agent [ set pregnant 0 ]
  ask agent [ set ask-cuddle 0 ]
 
end

to go
   set bhebix-list [self] of agent
   set berry-list [self] of food
   set taikubb-list [self] of predator
   set num-agents (count turtles with [breed = agent])
   
   ask agent [ set label round ask-cuddle ]
  search
  eat
  interact
  generatefood
  sunset
  mate
  birth
  if day = 150 and hunting-season < 1500
  [
    if random 2 = 1
    [set raining 1]
    set moisture moisture - 20
  ]
  rain
  sleep
  set bhebix-list [self] of agent
  if hunting-season = 1500 and raining != 1
  [
    initialise-hunt
    ask patches [ set pcolor red ] 
  ]
  hunt
  set day day + 1
  set hunting-season hunting-season + 1
  
   tick
end

to search
   foreach bhebix-list
  [
    ifelse day < 500
    [
      ask ? [ ifelse ask-cuddle >  0
        [
          
          ask ? [set ask-cuddle ask-cuddle + 1]
          ask ? [if ask-cuddle > 10 [ set ask-cuddle 0 ]]
          stop
        ]
      [
        
        ifelse raining = 1
        [
          ask ? [ if energy > 30
            [
              set nearest-cave min-one-of shelter [ distance myself ]
              face nearest-cave
              fd MovementSpeed
          ]]
          ask ? [ if energy < 30 
            [
                 set nearest-berry min-one-of (turtles with [breed = food ] )[distance myself] ;; set the value of nearest berry to the closest berry 
                 if any? turtles in-radius 10  with [breed = food ][face nearest-berry]  ;; if there are any berries in a radius of 10 set the heading of the current turtle towards the nearest berry
                 if not any? turtles in-radius 10 with [breed = food][ rt random 90 lt random 90] ;; if no berries in radius 10 randomly change direction
                 fd MovementSpeed ;; move the current turtle forward 1
            ]
          ]
        ]
      
      [
      
    ask ? [if affection > 30 or energy < 30
              [
                 set nearest-berry min-one-of (turtles with [breed = food ] )[distance myself] ;; set the value of nearest berry to the closest berry 
                 if any? turtles in-radius 10  with [breed = food ][face nearest-berry]  ;; if there are any berries in a radius of 10 set the heading of the current turtle towards the nearest berry
                 if not any? turtles in-radius 10 with [breed = food][ rt random 90 lt random 90] ;; if no berries in radius 10 randomly change direction
                 fd MovementSpeed ;; move the current turtle forward 1
              ]
          ]
    
    ask ? [if affection < 30 and energy > 30 
              [
                 set nearest-agent min-one-of other agent [distance myself]
                 if num-agents > 1
                 [
                   face nearest-agent
                   fd MovementSpeed      
                   ask nearest-agent [if ask-cuddle = 0 [set ask-cuddle 1]];;face myself]
                 ]
              ]      
          ]
    
      
     ask ? [
             if energy > 0[ set energy(energy - 0.5)]
             if affection > 0 [ set affection(affection - AffectionMeter)]
           ]
     
     
     ]
    ]
      ]]
    [
      ask ? [
        ifelse sleeping 
        [
          stop
        ]
        [
              set nearest-cave min-one-of shelter [ distance myself ]
              face nearest-cave
              fd MovementSpeed
        ]
      ]
    ]
  
  ]
end

to eat
  foreach bhebix-list
  [
    ask ? [ if any? turtles-here with [breed = food] [ set energy (energy + 50) ]
            if energy > 100 [ set energy 100]]
   
  ]
  foreach berry-list
  [
    ask ? [ if any? turtles-here with [breed = agent][die]
            set num-food (num-food - 1)
      
      ]
    
  ]
 end


to interact
  foreach bhebix-list
  [
    ask ? [ if any? other turtles-here with [breed = agent][ set affection 100
        set ask-cuddle 0
         ask ? [if any? other agent-here with [affection < 30 ][set interactions interactions + 1]]]
    ]
    print interactions
     
   
  ]
end
     
to generatefood
  set num-food (count turtles with [breed = food])
  if num-food < 20 and moisture = 100
  [
    set newfood (20 - num-food)
    ask n-of newfood patches [sprout-food 1]
  ]
  
  if moisture >= 80
  [
    if num-food <= 15 [ ask n-of 3 patches [ sprout-food 1 ]] 
  ]
  
  if moisture < 80 and moisture >= 60 
  [
    if num-food <= 10 [ ask n-of 3 patches [ sprout-food 1 ]]
  ]
  
  if moisture < 60 
  [
    if num-food < 8 [ ask n-of 3 patches [ sprout-food 1 ]]
  ]

end

to sunset
  if day > 500 
  [
    
    ask patches[ if nighttime < 10
      [ set pcolor pcolor - 0.2 ]]
     ask patches [ if nighttime > 200 and nighttime < 210
       [ set pcolor pcolor + 0.2 ]]
       ask patches [ if nighttime > 210
         [ set nighttime 0
           set day 0
           
         ]]
       set nighttime nighttime + 1
       set moisture moisture + 10
       
    ]
end

to sleep
  foreach bhebix-list
  [
    if day > 500
    [
      ask ? [ if any? turtles-here with [ breed = shelter][
        set sleeping true
        set energy 100
        set affection 100
      ]
      ]
    ]
    if day = 0
    [
      ask ? [ set sleeping false ]
      ask ? [ set age age + 1 ]
    ]
    
    ask ? [if age = 1 [ set size 2 ]]
    ask ? [ if age = 6 or energy = 0 [die]]
  ]
    
  end
     
to mate
  foreach bhebix-list
  [
    ask ? [ if energy > 80 and affection > 80 and pregnant = 0 and age > 0 and day > 20
      [ if any? other agent-here with [ energy > 50 and affection > 50 and pregnant != 1  and age > 0 and day < 500 ]
        [
          set partner-agent other agent-here
          ask partner-agent [ set partner-energy energy]
          ask ? [if energy < partner-energy and age > 0[ set pregnant 1 
              
             ;;ask ? [ set pregnant 1 
              set pregnant-bhebix pregnant-bhebix + 1
              print pregnant-bhebix]]
        ]
        ]
      ]
  ]
  
  end

to birth
  foreach bhebix-list
  [
    ask ? [ if pregnant = 1
      [ ifelse labour-steps = 200
        [ 
          ask patch-here [sprout-agent 1]
            ask max-one-of turtles-here[who] [
              set energy 100
              set affection 100
              set pregnant 0
              set sleeping false
              set size 1
              set labour-steps 0
              set age 0
              set ask-cuddle 0] 
          ask ? [ set pregnant 2
            set labour-steps 0 ]
        ]
        [
          ask ? [ set labour-steps labour-steps + 1 ]
        ]
      ]
    ]
  ]
        
            
end
  

to rain
  if raining = 1
  [
    ask patches [ set pcolor green ]
   
    ask n-of 75 patches [ set pcolor blue + 1 ]
      ;;ask n-of 50 patches [ set pcolor green ]
    set rainfall rainfall + 1
    
  ]
  
  if rainfall = 100
  [
    if moisture < 100 [ set moisture moisture + 40 ]
    if moisture > 100 [ set moisture 100 ]
    set raining 0
    ask patches [ set pcolor green ]
    set rainfall 0
  ]
end

to initialise-hunt
  ask patches with [ pxcor = -50 and pycor = 20 ][ sprout-predator 1 ]
  ask patches with [ pxcor = -50 and pycor = -20 ][ sprout-predator 1 ] 
  ask patches with [ pxcor = 50 and pycor = 20 ][ sprout-predator 1 ]
  ask patches with [ pxcor = 50 and pycor = -20 ][ sprout-predator 1 ]
  ask predator [ set size 3 
                 set death 0]
end

to hunt 
  ifelse hunting-season < 1600
  [
  foreach taikubb-list
  [
    ask ? [ 
      if num-agents > 0
      [
        set nearest-prey min-one-of agent [ distance myself ]
        ifelse any? turtles in-radius 5 with [ breed = agent ]
        [
          face nearest-prey
          fd 1
        ]
        [
          rt random 90 lt random 90 
          fd 1
        ]
      ]       
    ]
  ]
  foreach bhebix-list 
  [
    ask ? [ if any? turtles-here with [ breed = predator][ die ] ]
  ]
  ]
  [
    foreach taikubb-list
    [
      ask ? [ if xcor <= 0 and ycor <= 0 [ facexy -55 -23
                                           fd 1 ] ]
      ask ? [ if xcor <= 0 and ycor > 0 [ facexy -55 23
                                           fd 1 ] ]
      ask ? [ if xcor > 0 and ycor <= 0 [ facexy 55 -23
                                           fd 1 ] ]
      ask ? [ if xcor > 0 and ycor > 0 [ facexy 55 23
                                           fd 1 ] ]
      ask ? [ if xcor < -50 and ycor < -20 [ set death 1 ] ]
      ask ? [ if xcor < -50 and ycor > 20  [ set death 1 ] ]
      ask ? [ if xcor >  50 and ycor < -20 [ set death 1 ] ]
      ask ? [ if xcor >  50 and ycor > 20  [ set death 1 ] ]
    ]
    ask predator [ if death > 0 [ die ] ]
    if count predator = 0
  [
    set hunting-season 0 
    ask patches [ set pcolor green ]
  ]
  ]
  
  
  
end







@#$#@#$#@
GRAPHICS-WINDOW
205
11
1325
512
55
23
10.0
1
10
1
1
1
0
1
1
1
-55
55
-23
23
1
1
1
ticks
30.0

BUTTON
6
10
70
43
Setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
70
10
134
44
Go
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

SLIDER
6
43
178
76
AffectionMeter
AffectionMeter
1
5
5
0.1
1
NIL
HORIZONTAL

SLIDER
6
76
178
109
MovementSpeed
MovementSpeed
0.1
1
1
0.1
1
NIL
HORIZONTAL

SLIDER
6
108
178
141
NumberAgents
NumberAgents
2
20
20
1
1
NIL
HORIZONTAL

SLIDER
6
141
178
174
NumberCaves
NumberCaves
1
5
5
1
1
NIL
HORIZONTAL

MONITOR
6
174
63
219
Bhebix
count turtles with [breed = agent]
17
1
11

MONITOR
62
174
119
219
Berries
count turtles with [breed = food]
17
1
11

PLOT
6
218
166
338
Agents Population
ticks
NumAgents
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"numAgents" 1.0 0 -5825686 true "" "plot count turtles with [breed = agent]"

MONITOR
118
174
198
219
Interactions
interactions
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

berries
true
0
Circle -2674135 true false 21 156 108
Circle -2674135 true false 124 158 108
Line -6459832 false 75 155 165 50
Line -6459832 false 179 155 168 48
Rectangle -7500403 true true 164 45 170 51
Line -6459832 false 167 49 188 45

bhebix
false
0
Rectangle -5825686 true false 90 90 210 225
Rectangle -5825686 true false 30 120 60 120
Rectangle -5825686 true false 30 120 105 135
Rectangle -5825686 true false 210 120 270 120
Rectangle -5825686 true false 180 120 270 135
Rectangle -5825686 true false 120 210 120 270
Rectangle -5825686 true false 120 210 135 270
Rectangle -5825686 true false 165 225 180 270
Circle -11221820 true false 114 99 42
Circle -11221820 true false 144 99 42
Rectangle -16777216 true false 120 165 180 180
Rectangle -16777216 true false 120 120 135 135
Rectangle -16777216 true false 150 120 165 135

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

cave
false
0
Polygon -6459832 true false 30 225 30 90 90 30 210 30 270 90 270 225
Polygon -16777216 true false 75 225 75 105 105 75 195 75 225 105 225 225

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

taikubb
false
0
Polygon -13345367 true false 15 210 45 180 15 150 75 150 15 90 90 105 60 45 105 75 120 15 135 75 165 0 180 75 225 30 210 105 270 60 225 135 285 135 225 180 285 195 225 210
Circle -1 true false 105 105 30
Circle -1 true false 135 105 30
Polygon -16777216 true false 120 120 120 135 135 135 135 120 120 120
Polygon -16777216 true false 150 120 150 135 165 135 165 120 150 120
Polygon -2674135 true false 120 150 165 150 165 165 150 150 135 165 135 150 120 165 120 150 105 165 105 150
Polygon -2674135 true false 120 195 165 195 165 180 150 195 135 180 135 195 120 180 120 195 105 180 105 195
Polygon -2064490 true false 105 165 105 180 120 195 120 180 135 195 135 180 150 195 165 180 165 165 150 150 135 165 135 150 120 165 120 150
Polygon -13791810 true false 120 210 120 225 105 225 105 240 135 240 135 210 120 210
Polygon -13791810 true false 165 210 165 225 180 225 180 240 150 240 150 210 165 210
Polygon -13791810 true false 195 150 195 120 180 120 180 90 195 105 195 90 210 105 225 90 225 120 210 120 210 165 180 165 180 150
Polygon -13791810 true false 75 150 75 120 90 120 90 90 75 105 75 90 60 105 45 90 45 120 60 120 60 165 90 165 90 150

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
