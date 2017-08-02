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

One of the first things to do in a GUI application is set the background color. In iioScript, the GUI is the default context, so just use the `set` command:

```
set color red end
```

Note that while the use of the `color` parameter name clarifies the usage of the `red` color keyword, it is not necessary. iioScript allows named and unnamed parameters:

```
set red end
```

### Drawing Shapes

The next thing to do in a GUI application is draw shapes on the screen. In iioScript, this is accomplished with the `add` command:

```
add blue square
  pos center
  size 100
end
```

This code will add a 100x100px blue square to the center of the screen.

Here is the same code written in a single line without named parameters:

```
add center blue square 100 end
```

Note that `center` will be the center vector of the current context. To set a different vector, use the vector syntax `x:y`

```
add 20:20 blue square 100 end
```

This code will add the square to the position 20, 20.

Note that you may put spaces in between vector values, ei: `x : y`.

### Animating Shapes

The next thing to do with shapes is to animate them. In iioScript, this is accomplished with a physics engine.

Simply give a shape a velocity and/or acceleration, and the engine will take care of the rest:

```
add blue square
  pos center
  size 100
  vel 1:0
  acc .01:0
end
```

Note that `vel` and `acc` must always be passed as named parameters, otherwise their vectors assign the shapes position.

```
add blue square 20:20 100 vel 1:0 end
```

# iioScript Specification

### Syntax

iioScript is a series of statements, which can be composed of one or more expressions.

An expression can be a:
```
definition
assignment
function call
core function call
conditional
loop
```

Expressions are composed of:
```
keywords
variables
operators
values
```

Whitespace is used to delineate statements, expressions, keywords, functions, and values. New lines are counted as spaces, and are not required for valid syntax.

### Defnitions

Named variables are created using the `var` keyword.
```
var i
```

### Assignments

Values are assigned using the `=` operator.
```
i = newValue
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

### Core Function Calls

Core functions are called by adding the function keyword, a set of named parameters, and an 'end' keyword
```
set
  property value 
  ...
end
```

There are only a few core functions:
```
new
add
set
```

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
for var = range [by step]
  ...
end
```

Or:

```
while boolean_value
  ...
end
```

### Ranges
  
Ranges are defined with two values seperated by a `to` keyword.
```
0 to 100
```

Ranges can be used in loop definitions and `random` function calls.

### Shapes

Shapes are created within the `new` and `add` core function calls. A set of unordered properties can be passed in the function block.
```
var myShape = new 
  type circle
  size 40
  ...
end
```

```
add
  type square
  size 40
end
```

#### shape properties
```
type
vs
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

Some shapes have additional properties:

### grid properties
```
R
C
res
```

### text properties
```
font
text
align
```
