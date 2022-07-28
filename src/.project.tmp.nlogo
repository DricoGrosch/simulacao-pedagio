extensions [ nw ]

globals
[
  grid-x-inc               ;; the amount of patches in between two roads in the x direction
  grid-y-inc               ;; the amount of patches in between two roads in the y direction
  acceleration
  spawned-cars
  hour-of-the-day
  demand-routes
  roads
  current-house
  current-work
  must-end-simulation
  speed-mean
  cars-walked-on-toll
  total-cars-spawned
  simulation-total-stopped-ticks
  simulation-total-running-ticks

]



patches-own
[
  intersection?
]
breed [intersections intersection]
breed [nodes node]
breed [cars car]

intersections-own [
id
]

links-own [ weight ]

cars-own[
  can-change-route
speed
  speed-capacity
  up-car?
  work
  house
  goal
]

to setup
  clear-all
  setup-globals
  setup-patches
  reset-ticks
end


to setup-globals
  set grid-x-inc world-width / 5
  set grid-y-inc world-height / 6
  set spawned-cars 0
  set hour-of-the-day 8
  set acceleration 0.099
  set must-end-simulation false
  set cars-walked-on-toll 0
  set total-cars-spawned 0
end


to setup-patches
  ;; initialize the patch-owned variables and color the patches to a base-color
  ask patches [
    set intersection? false
    set pcolor brown + 3
  ]

  ;; initialize the global variables that hold patch agentsets
  set roads patches with [
    (floor ((pxcor + max-pxcor - floor (grid-x-inc - 1)) mod grid-x-inc) = 0) or
    (floor ((pycor + max-pycor) mod grid-y-inc) = 0)
  ]




  ask roads [
    ask patch -4 -3 [ set pcolor brown + 3 ]
    ask patch -4 -4 [ set pcolor brown + 3 ]
    ask patch -4 -2 [ set pcolor brown + 3 ]
    ask patch -4 -1 [ set pcolor brown + 3 ]
    ask patch -4 -0 [ set pcolor brown + 3 ]
;
    ask patch 11 0 [ set pcolor brown + 3 ]
    ask patch 11 -1 [ set pcolor brown + 3 ]
    ask patch 11 -2 [ set pcolor brown + 3 ]
    ask patch 11 -3 [ set pcolor brown + 3 ]
    ask patch 11 -4 [ set pcolor brown + 3 ]



  ask patch -4 6[ set pcolor brown + 3 ]
    ask patch -4 5 [ set pcolor brown + 3 ]
    ask patch -4 4 [ set pcolor brown + 3 ]
    ask patch -4 3 [ set pcolor brown + 3 ]
    ask patch -4 2 [ set pcolor brown + 3 ]
;
     ask patch 3 6[ set pcolor brown + 3 ]
    ask patch 3 5 [ set pcolor brown + 3 ]
    ask patch 3 4 [ set pcolor brown + 3 ]
    ask patch 3 3 [ set pcolor brown + 3 ]
    ask patch 3 2 [ set pcolor brown + 3 ]


    ask patch -4 -6 [ set pcolor brown + 3 ]
    ask patch -4 -7 [ set pcolor brown + 3 ]
    ask patch -4 -8 [ set pcolor brown + 3 ]
    ask patch -4 -9 [ set pcolor brown + 3 ]
    ask patch -4 -10 [ set pcolor brown + 3 ]


        ask patch -4 -12 [ set pcolor brown + 3 ]
    ask patch -4 -13 [ set pcolor brown + 3 ]
    ask patch -4 -14 [ set pcolor brown + 3 ]
    ask patch -4 -15 [ set pcolor brown + 3 ]
    ask patch -4 -16 [ set pcolor brown + 3 ]

    set pcolor white

  ]

  ask patches with [pcolor = white] [
    sprout-nodes 1 [
     set size 0.5
      set shape "circle"
      set color white
    ]
  ]
   ask nodes [
    create-links-with nodes-on neighbors4 [
      set color white
      set weight 1
    ]
  ]

  setup-intersections
  setup-tolls


end
to setup-tolls

;    ask patches with [  pxcor = -1 and pycor = -11 ] [set-toll]
;   ask patches with [  pxcor = -1 and pycor = -5 ] [set-toll]
;   ask patches with [  pxcor = -1 and pycor = 1 ] [set-toll]
;   ask patches with [  pxcor = -1 and pycor = 7 ] [set-toll]
;   ask patches with [  pxcor = 7 and pycor = 1 ] [set-toll]
;    ask patches with [  pxcor = -12 and pycor = 4 ] [set-toll]

;      ask patches with [  pxcor = -12 and pycor = 8 ] [set-toll]
;  ask patches with [  pxcor = 15 and pycor = -11 ] [set-toll]


;  ask n-of 2 roads  [
;    set-toll
;  ]

end
to set-toll
   set pcolor red
      ask nodes-here [
        ask my-links [
          set weight 5
        ]
      ]
end
to setup-intersections
  let index 1
  let intersection-patches roads with [
    (floor ((pxcor + max-pxcor - floor (grid-x-inc - 1)) mod grid-x-inc) = 0) and
    (floor ((pycor + max-pycor) mod grid-y-inc) = 0)
  ]
  foreach sort intersection-patches[intersection-patch ->
    ask intersection-patch  [
      sprout-intersections 1 [
        set size 1
        set index index + 1
        set id index
        set shape "circle"
      ]
    ]
  ]

  ask intersections [
    if (list pxcor pycor) = (list -4 1)
    or (list pxcor pycor) = (list -4 -5)
    or (list pxcor pycor) = (list -4 -11)
    or (list pxcor pycor) = (list -4 -18)
    or (list pxcor pycor) = (list -4 7)
    or (list pxcor pycor) = (list 3 7)
    or (list pxcor pycor) = (list 11 -5)
    or (list pxcor pycor) = (list 11 -11)
    or (list pxcor pycor) = (list 11 -18)
    or (list pxcor pycor) = (list 3 13)
    or (list pxcor pycor) = (list -4 13)
    or (list pxcor pycor) = (list 3 1)
    [
      die
    ]

  ]


end


to setup-cars
  set speed 0
  ifelse intersection? [
    ifelse random 2 = 0
      [ set up-car? true ]
      [ set up-car? false ]
  ]
  [
    ifelse (floor ((pxcor + max-pxcor - floor(grid-x-inc - 1)) mod grid-x-inc) = 0)
      [ set up-car? true ]
      [ set up-car? false ]
  ]
  ifelse up-car?
    [ set heading 180 ]
    [ set heading 90 ]
end


to create-demand-routes
  let new-routes (list)

  repeat ((count intersections * 2) / 3 ) [
    let temp1 one-of intersections
    let temp2 one-of intersections with [ self != temp1]
    set new-routes lput (list temp1 temp2) new-routes
  ]
  set demand-routes new-routes
end

to start-new-demand
  set hour-of-the-day hour-of-the-day + 1
  set spawned-cars 0

  if hour-of-the-day <= 18[


    let cars-to-spawn 100
    if hour-of-the-day > 11 and hour-of-the-day < 15[
    set cars-to-spawn cars-to-spawn * 2
    ]
    set total-cars-spawned total-cars-spawned + cars-to-spawn
    create-cars cars-to-spawn [
      create-demand-routes
      set can-change-route true
      let route one-of demand-routes
      setup-cars
      set house first route
      set work last route
      set goal work
      move-to house
      set-car-speed
      set shape "car"
      set spawned-cars spawned-cars + 1
      set speed-capacity random-float 0.7 + 0.3
;      create-link-with goal [
;        set color red
;      ]
    ]
 ]

end

to go

  if is-new-hour[
    start-new-demand

  ]

  ask cars [
      let node-on-current-car-path one-of nodes-on patch-here
      let node-on-current-car-goal-path 0
      ask goal [
        set node-on-current-car-goal-path one-of nodes-on patch-here
      ]

      let target min-one-of nodes-on neighbors4 [
        length nw:turtles-on-weighted-path-to node-on-current-car-goal-path "weight"
      ]
        if can-change-route [
        let old-speed speed
        let current-car self
        face target
        car-following


      if speed <= old-speed  [
        if old-speed - speed < 0.5[
;          show "vai trocar a rota"
          set can-change-route false
          let best-speed-mean 0
          ask nodes-on neighbors4 [
            let path-speed-mean 0
              foreach nw:turtles-on-path-to node-on-current-car-goal-path [ x ->
              ifelse count cars-here > 0
              [set path-speed-mean path-speed-mean + mean [speed] of cars-here]
              [set path-speed-mean path-speed-mean + 1]

              if path-speed-mean >= best-speed-mean[
                set best-speed-mean path-speed-mean
                set target self
              ]
            ]
          ]
        ]

      ]
    ]
      face target
      car-following
      fd speed
    set simulation-total-running-ticks simulation-total-running-ticks + 1
    if speed = 0 [
      set simulation-total-stopped-ticks simulation-total-stopped-ticks + 1
    ]
    ask patch-here [
      if pcolor = red [
      set cars-walked-on-toll cars-walked-on-toll + 1
      ]
    ]
    set speed-mean speed-mean +  mean [speed] of cars
      if  distance [ goal ] of self < 1 [
        die
      ]

  ]
  if count cars = 0 and hour-of-the-day > 18 [set must-end-simulation true]
  if must-end-simulation [
;    print "ticks dos percursos dos carros"
    print "["
    print simulation-total-running-ticks
    print ","
;    print "ticks de carros parados"
    print simulation-total-stopped-ticks
    print "],"

    setup
  ]

  tick

end
to-report is-new-hour
  report ticks mod 30 = 0
end

to car-following
  set-car-speed
end

to set-car-speed  ;; turtle procedure

    ifelse up-car?
    [ set-speed 0 -1 ]
    [ set-speed 1 0 ]

end

to set-speed [ delta-x delta-y ]
  let turtles-ahead cars-at delta-x delta-y
  ifelse any? turtles-ahead [
    ifelse any? (turtles-ahead with [ up-car? != [ up-car? ] of myself ]) [
      set speed 0
    ]
    [
      set speed [speed] of one-of turtles-ahead
      slow-down
    ]
  ]
  [ speed-up ]
end

to slow-down
  ifelse speed <= 0
    [ set speed 0 ]
    [ set speed speed - acceleration ]
end

to speed-up  ;; turtle procedure
  ifelse speed > 1
    [ set speed 1 ]
    [ set speed  speed + acceleration ]
end
@#$#@#$#@
GRAPHICS-WINDOW
327
10
668
352
-1
-1
9.0
1
15
1
1
1
0
0
0
1
-18
18
-18
18
1
1
1
ticks
30.0

BUTTON
220
45
305
78
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
220
10
304
43
Setup
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

MONITOR
185
125
290
170
Hour of the day
hour-of-the-day
3
1
11

MONITOR
40
115
157
160
cars-walked-on-toll
cars-walked-on-toll
17
1
11

MONITOR
10
15
182
60
simulation-total-stopped-ticks
simulation-total-stopped-ticks
17
1
11

@#$#@#$#@
## Reconhecimento

Modelo apresentado para matéria de Engenharia de Software Orientada a Agentes, desenvolvendo uma simução de transito utilizando postos de pedágio.

## O que é?

Um trafico de veiculos de uma cidade qualquer, a fim de identificar os congestionamentos das vias/ruas, assim para resolver esse problema, é definido pedágios em algumas ruas, para dissipar o congestionamento, pois com pedágio o custo para o motorista passa a ser maoior, dependendo do seu destino ele pode optar por trafegar em rotas alternativas.

## Como funciona
Os carros selecionam seu destino ao qual estão tentando chegar (trabalho ou casa etc..) e tentam avançar na velocidade atual pré definida. Se a velocidade atual for menor que o limite de velocidade(limite positivo) e não houver nenhum carro diretamente à sua frente, eles aceleram. Se houver um carro mais lento na frente deles, eles correspondem à velocidade do carro mais lento e desaceleram (utilizando a estratégia de car-following). 


## Como usar

Clique em Setup para definir o mundo/mapa
Clique em GO para iniciar a simulação, para os veiculos andarem.

### Buttons

SETUP -- Define os patches, ruas , pedágios, definido o mapa como um todo, e seu funcionamento.

GO -- Inicia a simulação, gerando os veiculos, que a partir disso definem suas rotas.




### Plots

Hours of the day -- Apresenta o horário atual da simulação, assim simulando o horário da vida real.

simulation-total-stopped-ticks -- Quantidade de carroq a ponto de parar o carro (velocidade igual 0) esse input é incrementado.

cars-walked-on-toll -- Quantidade de carros que passaram por um pedágio

## THINGS TO NOTICE

How is this model different than the Traffic Grid model? The one thing you may see at first glance is that cars move in all directions instead of only left to right and top to bottom. You will probably agree that this looks much more realistic.

Another thing to notice is that, sometimes, cars get stuck: as explained in the book this is because the cars are mesuring the distance to their goals "as the bird flies", but reaching the goal sometimes require temporarily moving further from it (to get around a corner, for instance). A good way to witness that is to try the WATCH A CAR button until you find a car that is stuck. This situation could be prevented if the agents were more cognitively sophisticated. Do you think that it could also be avoided if the streets were layed out in a pattern different from the current one?

## THINGS TO TRY

You can change the "granularity" of the grid by using the GRID-SIZE-X and GRID-SIZE-Y sliders. Do cars get stuck more often with bigger values for GRID-SIZE-X and GRID-SIZE-Y, resulting in more streets, or smaller values, resulting in less streets? What if you use a big value for X and a small value for Y?

In the original Traffic Grid model from the model library, removing the traffic lights (by setting the POWER? switch to Off) quickly resulted in gridlock. Try it in this version of the model. Do you see a gridlock happening? Why do you think that is? Do you think it is more realistic than in the original model?

## EXTENDING THE MODEL

Can you improve the efficiency of the cars in their commute? In particular, can you think of a way to avoid cars getting "stuck" like we noticed above? Perhaps a simple rule like "don't go back to the patch you were previously on" would help. This should be simple to implement by giving the cars a (very) short term memory: something like a `previous-patch` variable that would be checked at the time of choosing the next patch to move to. Does it help in all situations? How would you deal with situations where the cars still get stuck?

Can you enable the cars to stay at home and work for some time before leaving? This would involve writing a STAY procedure that would be called instead moving the car around if the right condition is met (i.e., if the car has reached its current goal).

At the moment, only two of the four arms of each intersection have traffic lights on them. Having only two lights made sense in the original Traffic Grid model because the streets in that model were one-way streets, with traffic always flowing in the same direction. In our more complex model, cars can go in all directions, so it would be better if all four arms of the intersection had lights. What happens if you make that modification? Is the flow of traffic better or worse?

## RELATED MODELS

- "Traffic Basic": a simple model of the movement of cars on a highway.

- "Traffic Basic Utility": a version of "Traffic Basic" including a utility function for the cars.

- "Traffic Basic Adaptive": a version of "Traffic Basic" where cars adapt their acceleration to try and maintain a smooth flow of traffic.

- "Traffic Basic Adaptive Individuals": a version of "Traffic Basic Adaptive" where each car adapts individually, instead of all cars adapting in unison.

- "Traffic 2 Lanes": a more sophisticated two-lane version of the "Traffic Basic" model.

- "Traffic Intersection": a model of cars traveling through a single intersection.

- "Traffic Grid": a model of traffic moving in a city grid, with stoplights at the intersections.

- "Gridlock HubNet": a version of "Traffic Grid" where students control traffic lights in real-time.

- "Gridlock Alternate HubNet": a version of "Gridlock HubNet" where students can enter NetLogo code to plot custom metrics.

The traffic models from chapter 5 of the IABM textbook demonstrate different types of cognitive agents: "Traffic Basic Utility" demonstrates _utility-based agents_, "Traffic Grid Goal" demonstrates _goal-based agents_, and "Traffic Basic Adaptive" and "Traffic Basic Adaptive Individuals" demonstrate _adaptive agents_.

## HOW TO CITE

This model is part of the textbook, “Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo.”

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Rand, W., Wilensky, U. (2008).  NetLogo Traffic Grid Goal model.  http://ccl.northwestern.edu/netlogo/models/TrafficGridGoal.  Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the textbook as:

* Wilensky, U. & Rand, W. (2015). Introduction to Agent-Based Modeling: Modeling Natural, Social and Engineered Complex Systems with NetLogo. Cambridge, MA. MIT Press.

## COPYRIGHT AND LICENSE

Copyright 2008 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2008 Cite: Rand, W., Wilensky, U. -->
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
true
0
Polygon -7500403 true true 180 15 164 21 144 39 135 60 132 74 106 87 84 97 63 115 50 141 50 165 60 225 150 285 165 285 225 285 225 15 180 15
Circle -16777216 true false 180 30 90
Circle -16777216 true false 180 180 90
Polygon -16777216 true false 80 138 78 168 135 166 135 91 105 106 96 111 89 120
Circle -7500403 true true 195 195 58
Circle -7500403 true true 195 47 58

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
NetLogo 6.2.1
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
1
@#$#@#$#@
