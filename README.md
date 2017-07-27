# iioScript

A scripting language for rapid animation development.

This language could be used for any platform, though it requires an interface to translate the script to a runnable application in the native environment.

A JavaScript interface is provided in this repo using Jison and iioEngine: http://iioengine.com

### Authors

Created by Sebastian Bierman-Lytle (@sbiermanlytle) and Shuo Zheng (@shzhng)

### Source Code

`grammar.jison` defines all iioScript language syntax with hooks into the iioEngine API.

`iioScript.js` is a .iio -> .js transpiler, precompiled with Jison: https://zaa.ch/jison/

## Specification

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
