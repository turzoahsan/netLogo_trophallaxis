breed [robots robot]
breed [boxes box]

robots-own [
  energy
  drag-ticks
  probability-transporting
  probability-resting
]

patches-own [
  charging-area?
  target-area?
]
globals
[
  red-boxes
  total-energy
  total-time
]

to setup
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  set total-energy 0
  set total-time 0
  setup-patches
  setup-robots
  setup-boxes
  do-plotting
end

to setup-patches
  ask patches [
    set charging-area? false
    set target-area? false
  ]
  ask ([patches in-radius charging-area-radius] of patch min-pxcor max-pycor) [
    set charging-area? true
    set pcolor white
  ]
  ask ([patches in-radius target-area-radius] of patch max-pxcor max-pycor) [
    set target-area? true
    set pcolor blue
  ]
end


to setup-robots

  set-default-shape robots "circle 2"
  create-robots number-of-bots [
    setxy random-xcor random-ycor
    set color green
    ;;set probability-transporting (random-float 1)
   ;; set probability-resting (random-float 1)
   set drag-ticks 0
    set heading (random-float 360)
    set energy (500 + random-float 500)
    set total-energy energy
  ]
end

to setup-boxes
  set-default-shape boxes "box"
  create-boxes number-of-boxes [
    setxy random-xcor random-ycor
    set color (ifelse-value (target-area?) [red] [green])
  ]
end


to go
  set total-time ticks
  ;;if (all? boxes [target-area? and not any? my-in-links]) [
 ;;   stop
 ;; ]
 ;set total-energy (count energy)
 set red-boxes (count boxes with [color = red])
 if (red-boxes = number-of-boxes)
   [stop]
  ask robots [
    set energy (energy - energy-decrement)

    ifelse (energy < minimum-charging-energy and energy > minimum-energy) ; Check whether the bot need charging and it is not transpornting boxes
    [
      if (any? my-out-links)
      [
        release-box
      ]
      set color cyan ; Just to show that the bot is searching for mututal charging
        let visible-robots ((robots in-cone vision-range vision-angle) ; Finding out the robots that are visible by the particular robot
          with [energy > minimum-charging-energy + transfer-energy-amount]) ; The visible robot is capable of sharing any energy or not
        ifelse (any? visible-robots) [
          mutual-charge (min-one-of visible-robots [distance myself]) ; Calling the mutual-charge function with parameter
        ]
        [
          wiggle ; If no bot fullfil the requirements the particular robot calls wiggle function
        ]
    ]

    [
    ifelse (energy < minimum-energy) [
      move-to-charge
    ]

    [
      ifelse (any? my-out-links) [
        move-to-target
      ]
      [
        let visible-boxes ((boxes in-cone vision-range vision-angle)
          with [not target-area? and not any? my-in-links]) ; Make sure not already in target, and not already linked.
        ifelse (any? visible-boxes) [
          transport (min-one-of visible-boxes [distance myself])
        ]
        [
          wiggle
        ]
      ]
    ]
    ifelse show-energy?
    [
      set label energy
    ]
    [
      set label ""
    ]
    ]
  ]
  tick
  do-plotting
end

to move-to-charge
  ifelse (charging-area?) [
    set color green
    set energy (500 + random 501)
    set total-energy energy
  ]
  [
    set color red
    if (any? my-out-links) [
      release-box
    ]
    facexy min-pxcor max-pycor
    forward (ifelse-value (energy < 0) [loaded-step-length] [unloaded-step-length])
  ]
end

;;to decide-to-transport-or-to-rest ;; robots procedure
  ;; if we find boxes probability of transporting will increase
  ;; if we dont find boxes probility of resting  will increase

  ;;fd 0.01
  ;;rt random 30 - random 30
 ;; ifelse(probability-transporting > probability-resting)
 ;; [
 ;;   transport
 ;; ]
 ;; [
  ;;  rest
  ;;]
;;end

to transport [selected-box]
  set energy (energy - energy-decrement * 2)
  face selected-box
  forward 1
  if (distance selected-box <= grab-range) [
    create-link-to selected-box [
      tie
      ask other-end [
        set color yellow
      ]
    ]
  ]
end

to move-to-target
  ;;ifelse ([target-area?] of one-of out-link-neighbors) [
    ;; and (([distancexy max-pxcor max-pycor] of one-of out-link-neighbors) * random-float 1 < 1)) [
   ;; release-box
   ;; right 180 ; nothing else to do in target area.
 ;; ]
 ;; [
    facexy max-pxcor max-pycor
    forward loaded-step-length
    set drag-ticks (drag-ticks + 1)
    if ([target-area?] of one-of out-link-neighbors)[
      release-box
      right 180
  ]
end


to wiggle
  right ((random-float max-wiggle-angle) - (random-float max-wiggle-angle))
  ifelse (can-move? unloaded-step-length) [
    forward unloaded-step-length
  ]
  [
    set heading (random-float 360)
  ]
end

to release-box
  ask my-out-links [
    ask other-end [
      set color (ifelse-value (target-area?) [red] [green])
    ]
    die
  ]
end

to do-plotting
  set-current-plot "Average Energy"
  plotxy ticks (mean [energy] of robots)
  set-current-plot "Robot Utilization"
  plotxy ticks (count robots with [any? my-out-links] / count robots)
end

to mutual-charge [selected-bot]
  face selected-bot
  forward 1
  ;ask selected-bot [set color yellow]
  ;set color cyan
  if (distance selected-bot <= maximum-charging-distance) ; checking whether charging is possible or not
  [
    set  energy (energy + transfer-energy-amount)
    set color blue ; The bot which gained energy turns into blue just to show it in model.
    ask selected-bot [set energy (energy - transfer-energy-amount)]
    ask selected-bot [set color yellow] ; The bot which gained energy turns into yellow just to show it in model.
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
177
10
892
423
41
22
8.5
1
10
1
1
1
0
0
0
1
-41
41
-22
22
1
1
1
ticks
30.0

BUTTON
10
500
80
533
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
130
165
163
number-of-bots
number-of-bots
1
100
20
1
1
NIL
HORIZONTAL

SLIDER
10
10
165
43
charging-area-radius
charging-area-radius
0
20
16
1
1
NIL
HORIZONTAL

SLIDER
10
290
165
323
minimum-energy
minimum-energy
0
500
40
5
1
NIL
HORIZONTAL

BUTTON
83
501
158
534
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
330
165
363
energy-decrement
energy-decrement
0
1
0.49
0.01
1
NIL
HORIZONTAL

SLIDER
10
90
165
123
number-of-boxes
number-of-boxes
1
100
60
1
1
NIL
HORIZONTAL

SLIDER
10
50
165
83
target-area-radius
target-area-radius
0
20
10
1
1
NIL
HORIZONTAL

SLIDER
10
210
165
243
unloaded-step-length
unloaded-step-length
0
1
0.19
0.01
1
NIL
HORIZONTAL

SLIDER
10
250
165
283
loaded-step-length
loaded-step-length
0
unloaded-step-length
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
10
370
165
403
vision-range
vision-range
1
10
6.5
0.1
1
NIL
HORIZONTAL

SLIDER
10
410
165
443
vision-angle
vision-angle
0
60
25
1
1
NIL
HORIZONTAL

SLIDER
10
450
165
483
grab-range
grab-range
0
vision-range
3.5
0.1
1
NIL
HORIZONTAL

SLIDER
10
170
165
203
max-wiggle-angle
max-wiggle-angle
0
45
18
1
1
NIL
HORIZONTAL

MONITOR
1041
12
1172
65
Number-agents
count turtles
3
1
13

SWITCH
1176
23
1296
56
show-energy?
show-energy?
1
1
-1000

PLOT
1039
111
1328
283
Average Energy
NIL
NIL
0.0
100.0
0.0
150.0
true
true
"" ""
PENS
"energy" 1.0 0 -13840069 true "" ""

PLOT
1040
293
1330
468
Robot Utilization
NIL
NIL
0.0
100.0
0.0
1.0
true
true
"" ""
PENS
"robot with box" 1.0 0 -16777216 true "" ""

SLIDER
179
451
368
484
maximum-charging-distance
maximum-charging-distance
1
5
1
1
1
NIL
HORIZONTAL

SLIDER
367
452
559
485
minimum-charging-energy
minimum-charging-energy
0
400
80
10
1
NIL
HORIZONTAL

SLIDER
578
453
763
486
transfer-energy-amount
transfer-energy-amount
10
500
150
5
1
NIL
HORIZONTAL

MONITOR
957
12
1029
57
NIL
red-boxes
0
1
11

MONITOR
913
373
988
418
NIL
total-energy
0
1
11

MONITOR
910
315
993
360
NIL
total-time
0
1
11

@#$#@#$#@
## WHAT IS IT?

This section could give a general understanding of what the model is trying to show or explain.

## HOW IT WORKS

This section could explain what rules the agents use to create the overall behavior of the model.

## HOW TO USE IT

This section could explain how to use the model, including a description of each of the items in the interface tab.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## CREDITS AND REFERENCES

This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Time" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="6000"/>
    <metric>mean [drag-ticks] of robots / ticks</metric>
    <enumeratedValueSet variable="number-of-bots">
      <value value="5"/>
      <value value="10"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-boxes">
      <value value="5"/>
      <value value="10"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="robot utilization" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4000"/>
    <metric>count robots with [any? my-out-links] / count robots</metric>
    <steppedValueSet variable="number-of-boxes" first="5" step="5" last="20"/>
    <steppedValueSet variable="number-of-bots" first="5" step="5" last="20"/>
  </experiment>
  <experiment name="enrgy" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4000"/>
    <metric>mean [energy] of robots</metric>
    <steppedValueSet variable="number-of-boxes" first="10" step="10" last="40"/>
    <steppedValueSet variable="number-of-bots" first="10" step="10" last="40"/>
  </experiment>
  <experiment name="total-energy" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>total-energy</metric>
    <enumeratedValueSet variable="number-of-boxes">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="charging-area-radius">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-area-radius">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-energy-amount">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-bots">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-charging-distance">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="unloaded-step-length">
      <value value="0.19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-wiggle-angle">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-decrement">
      <value value="0.49"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loaded-step-length">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision-range">
      <value value="6.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision-angle">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-energy">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-charging-energy">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grab-range">
      <value value="3.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="total-time" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>total-time</metric>
    <enumeratedValueSet variable="number-of-boxes">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="charging-area-radius">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-area-radius">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-energy-amount">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-bots">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-charging-distance">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="unloaded-step-length">
      <value value="0.19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-wiggle-angle">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-decrement">
      <value value="0.49"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loaded-step-length">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision-range">
      <value value="6.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision-angle">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-energy">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-charging-energy">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grab-range">
      <value value="3.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="time-and-energy" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>total-time total-energy</metric>
    <enumeratedValueSet variable="number-of-boxes">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="charging-area-radius">
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="target-area-radius">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transfer-energy-amount">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-bots">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-energy?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="maximum-charging-distance">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="unloaded-step-length">
      <value value="0.19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-wiggle-angle">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-decrement">
      <value value="0.49"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loaded-step-length">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision-range">
      <value value="6.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vision-angle">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-energy">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="minimum-charging-energy">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="grab-range">
      <value value="3.5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
