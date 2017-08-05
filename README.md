# iioScript

A scripting language for rapid animation development.

This language could be used for any platform, though it requires an interface to translate the script to a runnable application in the native environment.

A JavaScript interface is provided in this repo using Jison [https://zaa.ch/jison/] and iio Engine [http://iioengine.com], which allows iioScript apps to run on HTML5 Canvas.

### Authors

Created by Sebastian Bierman-Lytle (@sbiermanlytle) and Shuo Zheng (@shzhng)

## Source Code

`grammar.jison` defines all iioScript language syntax with hooks into the iioEngine API.

`lib/iioScript.js` is a .iio -> .js transpiler, precompiled from `grammar.jison` with Jison.

`lib/iioEngine.js` is an external library that powers the animation engine.

## How to write iioScript

iioScript is always assumed to be running in an environment with a Graphical User Interface (GUI).

One of the first things to do in a GUI application is set the background color. In iioScript the GUI is the default context, so just use the `set` command.

```
set color red end
```

Note that while the use of the `color` parameter name clarifies the usage of the `red` color keyword, it is not necessary. iioScript allows named and unnamed parameters.

```
set red end
```

### Drawing Shapes

The next thing to do in a GUI application is draw shapes on the screen. In iioScript this is done with the `add` command.

```
add blue square
  pos center
  size 100
end
```

This code will add a 100x100px blue square to the center of the screen.

Here is the same code written in a single line without named parameters.

```
add center blue square 100 end
```

Note that `center` will be the center vector of the current context, which in this case would be the center of the screen. To set a different position, use the vector syntax `x:y`

```
add 20:20 blue square 100 end
```

This code will add the square to the position 20, 20.

Note that you can put spaces in between vector values `x : y`.

### Animating Shapes

The next thing to do with shapes is to animate them. In iioScript this is accomplished with a physics engine.

Simply give a shape a velocity and/or acceleration, and the engine will take care of the rest, at a default frame rate of 60FPS.

```
add blue square
  pos center
  size 100
  vel 1:0
  acc .01:0
end
```

This code will add the blue square to the screen, and move it to the right at 1px per frame, while also accelerating the movement by .01px per frame.

Note that `vel` and `acc` must always be passed as named parameters, otherwise their vectors assign the shapes position.

### Updating Shapes

The next important aspect of making a GUI app is updating a shape's animation behavior. In iioScript this is done by assigning a shape to a variable, and then calling the `set` command on that variable.

```
var mySquare = add blue square
  pos center
  size 100
  vel 1:0
end

...

mySquare.set vel -1:0 end
```

This code creates the variable `mySquare` using the `var` keyword, then assigns to it the same blue square created in the previous example. Later on in the code, the `.` syntax is used to call the `set` command on that variable to reverse its velocity.

Note that `...` is just a indicator for 'later on' and is not valid iioScript syntax.

### Mathematical Operations

As animations become more complex, math can be used to generate property values without having to pre-calculate them.

In iioScript, numbers can be assigned to variables, and arithmetic can be performed. Order of operations is PEMDAS, but can be overridden with `()` characters.

```
var a = 2
var b = 3
var c = a + b
var d = a - b
var e = a * b
var f = a / b
var g = a ^ b
var h = a * (a - b)
```

### Conditional Operations

Sometimes something should only occur if some condition is true. In iioScript this is accomplished with `if` `else` statements and boolean evaluations.

```
var shouldAddBlueShape = true

if shouldAddBlueShape
  add center blue square 100 end
else
  add center red square 100 end
end
```

Note that `true` is not the only "truthy" value. Any value that exists except for `0` will be evaluated to `true`.

`false` can be used in the opposite case, and the `!` operator can be used to negate any boolean value.

### Randomness

Sometimes a random value is more useful than a specified one. In iioScript this is done with the `random` command.

```
var a = random 1 to 10
```

In this code, `a` will be set to a random floating point number in between 1 and 10.

The `random` command can also be used for colors.

```
var c = random color
```

### Loops

Sometimes a single statement needs to run multiple times. In iioScript this is accomplished with `for` and `while` loops.

```
for var i = 1 to 10
  add blue square 100 
    pos random 0 to width : random 0 to height
  end
end
```

This code will create 10 blue squares in random positions within the bounds of the screen.

### Functions

If a single statement is ever used more than once, it is best to define it as a reusable function. In iioScript, functions are created with the `fn` keyword.

```
var addBlueSquare = fn()
  add blue square 100 
    pos random 0 to width : random 0 to height
  end
end

for var i = 1 to 10
  addBlueSquare()
end

addBlueSquare()
```

This code defines a function called `addBlueSquare`, then calls it 10 times in a loop, and then once after the loop.

Sometimes the statement defined in a function needs to be altered slightly. In iioScript, unnamed parameters can be used to pass values into functions.

```
var addBlueSquare = fn( sizeValue )
  add blue square sizeValue
    pos random 0 to width : random 0 to height
  end
end

addBlueSquare( 50 )
```

This function will add a blue square to a random spot on the screen, with a given size of 50.

### Detecting Screen Size Changes

Many screens change sizes - like when a user resizes their window or turns their phone sideways. iioScript handles screen size changes in a generic way with the `onresize` hook.

```
var repositionShapes = fn()
  ...
end

onresize repositionShapes
```

## Practical Example: Particle Engines

This example is live here: http://iioscript.iioengine.com/demos/squares.html

Many animations include a large group of shapes with similar but slightly different properties. These systems are called Particle Engines.

Creating a particle engine with iioScript is very straightforward using the features discussed above.

```
for var i = 0 to 200
  add red circle
    pos random 0 to width : random 0 to height
    size random 60 to 140
    vel random -.5 to .5 : random -.5 to .5
    alpha random .3 to .6
  end
end
```

# iioScript Specification

### Syntax

iioScript is a series of statements, which can be composed of one or more expressions.

An expression can be a:
```
definition
assignment
conditional
loop
command
function call
hook
```

Expressions are composed of:
```
keywords
variables
operators
values
```

Whitespace is used to delineate statements, expressions, keywords, functions, and values. New lines are counted as spaces, and are not required for valid syntax.

### Definitions

Named variables are created using the `var` keyword.
```
var i
```

### Assignments

Values are assigned using the `=` operator.
```
i = newValue
```

### Data Types

iioScript has 4 data types:
```
Boolean
Number
Range
Color
```

#### Boolean Data

`true` or `false`. All non-undefined data types other than `0` will evaluate as `true`

The `!` symbol is used to negate boolean values

#### Number Data

All numbers are floating point. There are 2 special number keywords:

```
PI
E
```

The following mathematical operators are available:

`+ - * / ^ ()`

#### Range Data
  
Ranges are defined with two values seperated by a `to` keyword.
```
0 to 100
```

#### Color Data

There are color keywords and `random color` values

### Conditionals

Conditional blocks are created using the following syntax:
```
if boolean_value
  ...
else if boolean_value
  ...
else
  ...
end
```

### Loops

Looping blocks are created using the following syntax:
```
for var index = start to end [by step]
  ...
end
```

Or:

```
while boolean_value
  ...
end
```

### Commands

Commands are called by adding the function keyword, a set of named parameters, and an 'end' keyword
```
set
  property value 
  ...
end
```

There are only a few commands:
```
new
add
set
draw
clear
random
```

### Functions

Functions are variables that can be defined with the `fn` keyword. The `end` keyword is required at the end of the function body.
```
var myFunction = fn(params...)
  ...
end
```

Ordered parameters may be defined within trailing parentheses. Whitespace is used to delineate parameters.
```
var myFunction = fn( arg0 arg1 ... )
  ...
end
```

The `return` keyword can be used to short circuit the body a function.

### Function Calls

Functions are called by adding a training parentheses to the function name.
```
myFunction()
```

Unnamed parameters can be passed:
```
myFunction( a0 a1 ... )
```

Or named parameters can be passed:
```
myFunction( arg0: a0 arg1: a1)
```

### Hooks

Hooks are special assignments to events that affect the apps environment. Currently there is only an `onresize` hook.

```
onresize aFunctionToBeCalledOnResize
```

### Shapes

Shapes are created within the `new` and `add` commands. A set of unordered properties can be passed in the function block.
```
var myShape = new circle
  size 40
  ...
end
```

The default shape is a `square`.

```
add size 40 end
```

#### Shape Types

```
square
rectangle
circle
ellipse
grid
x
```

`o` is an alias for `circle`

```
add o size 40 end
```

#### Shape Properties
```
pos       x : y : z
vel       x : y
acc       x : y
width
height
lineWidth
color
alpha
shrink
```

The `grid` shape has additional properties:

```
R
C
res
```
