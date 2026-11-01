/*
  iioScript
  https://github.com/iioinc/iioScript
  version: 1.2
------------------------------------------------------------------------------------------
iioScript is licensed under the MIT License

Copyright (c) 2014 Sebastian Bierman-Lytle & Shuo Zheng

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

%lex

%%
\s+                       /* skip whitespace */
"//".*                    /* skip comments */
\"[^"\n]*\"               return 'string';
"end"                     return 'end';
":"                       return 'delimiter_vector';
","                       return 'delimiter_list';
"<="                      return '<=';
">="                      return '>=';
"<"                       return '<';
">"                       return '>';
"="                       return 'assign';
"for"                     return 'for_keyword';
"while"                   return 'while_keyword';
"to"                      return 'to_keyword';
"by"                      return 'by_keyword';
"var"                     return 'var_keyword';
"fn"                      return 'fn_keyword';
"return"                  return 'return_keyword';
"if"                      return 'if_keyword';
"else if"                 return 'elseif_keyword';
"else"                    return 'else_keyword';
"then"                    return 'then_keyword';
"is not"                  return 'isnt';
"is"                      return 'is';
"and"                     return 'and';
"or"                      return 'or';
"not"                     return 'not';
"every"                   return 'every_keyword';
"seconds"                 return 'seconds_keyword';
"second"                  return 'seconds_keyword';
"list"                    return 'list_keyword';
"append"                  return 'append_keyword';
"length of"               return 'length_of';
"at"                      return 'at_keyword';

\-?(?:\d*\.)?\d+          return 'number';
"."                       return 'dot';
"!"                       return 'not';
"*"                       return '*';
"/"                       return '/';
"-"                       return '-';
"+"                       return '+';
"^"                       return '^';
"("                       return '(';
")"                       return ')';
"PI"                      return 'PI';
"E"                       return 'E';

(red|blue|green|yellow|orange|purple|pink|gray|black|white)\b    return 'color_constant';
"random color"            return 'color_random';
"random whole"            return 'random_whole';
"random"                  return 'random_keyword';
"color"                   return 'color_keyword';

"alert"                   return 'alert';

"add"                     return 'add';
"set"                     return 'set';
"draw"                    return 'draw';
"clear"                   return 'clear';
"onresize"                return 'onresize';
"onkey"                   return 'onkey';

"obj"                     return 'obj_keyword';

"pos"                     return 'pos_keyword';
"size"                    return 'size_keyword';
"lineWidth"               return 'lineWidth_keyword';
"outline"                 return 'outline_keyword';
"shadow"                  return 'shadow_keyword';
"alpha"                   return 'alpha_keyword';
"vel"                     return 'vel_keyword';
"acc"                     return 'acc_keyword';
"shrink"                  return 'shrink_keyword';
"click"                   return 'click_keyword';
"text"                    return 'text_keyword';

"center"                  return 'center';
"width"                   return 'width';
"height"                  return 'height';

"o"                       return 'type_circ';
"x"                       return 'type_x';
"square"                  return 'type_square';
"rectangle"               return 'type_rectangle';
"circle"                  return 'type_circle';
"ellipse"                 return 'type_ellipse';
"grid"                    return 'type_grid';

[a-zA-Z]+                 return 'variable';

<<EOF>>                   return 'eof';

/lex

/* operator associations and precedence, loosest first. A name followed by "("
   is a function call (NOCALL is below "("), not a name and then a value in
   parentheses. */

%nonassoc NOCALL
%left 'or'
%left 'and'
%nonassoc 'is' 'isnt' '<' '>' '<=' '>='
%left '+' '-'
%left '*' '/'
%left '^'
%right 'not'
%left at_keyword
%nonassoc '('

%start iioscript

%%

iioscript
  : statements eof
    { return "(function() { \n\treturn function(app, settings) {\n\n" + $1 + "\t}\n})()" }
  ;

statements
  : statement
    {$$ = "\t\t"+$1;}
  | statements statement
    {$$ = $1 + $2;}
  ;

statement
  : definition
    {$$ = $1;}
  | declaration
    {$$ = $1;}
  | for_statement
    {$$ = $1;}
  | while_statement
    {$$ = $1;}
  | every_statement
    {$$ = $1;}
  | append_statement
    {$$ = $1;}
  | if_statement
    {$$ = $1;}
  | expression
    {$$ = $1 + ';\n';}
  | iio_cmd
    {$$ = $1;}
  ;

definition
  : var_keyword assignment
    {$$ = 'var ' + $2 + '\n' }
  | assignment
    {$$ = $1 + '\n'}
  ;

declaration
  : var_keyword variable
    {$$ = 'var ' + $2 + ';\n' }
  ;

assignment
  : variable assign expression
    {$$ = $1 + ' = ' + $3 + ';' }
  | variable dot variable assign expression
    {$$ = $1 + '.' + $3 + ' = ' + $5 + ';' }
  | variable at_keyword value assign expression
    {$$ = $1 + '[' + $3 + '] = ' + $5 + ';' }
  | variable assign color_constant
    {$$ = $1 + " = '" + $3 + "';" }
  | variable assign color_random
    {$$ = $1 + ' = iio.random.color();' }
  ;

anon_fn
  : fn_keyword '(' variables ')' statements end
    {$$ = 'function(' + $3 + '){ \n' + $5 + '\n\t}\n' }
  | fn_keyword '(' ')' statements end
    {$$ = 'function(){ \n' + $4 + '\n\t}\n' }
  ;

fn_call
  : variable '(' expressions ')'
    {$$ = $1 + '(' + $3 + ')' }
  | variable '(' ')'
    {$$ = $1 + '()' }
  ;

iio_call
  : iio_fn
    {$$ = 'app.' + $1}
  | variable dot iio_fn
    {$$ = $1 + '.' + $3}
  ;

variables
  : variable
    {$$ = $1}
  | variables variable
    {$$ = $1 + ", " + $2}
  ;

expression
  : value
    {$$ = $1}
  | iio_call
    {$$ = $1}
  | anon_fn
    {$$ = $1}
  | return
    {$$ = $1}
  | random_property
    {$$ = $1}
  ;

iio_cmd
  : clear
    {$$ = "app.objs = [];\n" }
  | draw
    {$$ = "app.draw();\n" }
  | onresize expression
    {$$ = "this.resize = " + $2 + ";\n" }
  | onkey expression
    {$$ = "this.onKeyDown = function(event, key){ (" + $2 + ")(key); };\n" }
  | obj_keyword dot obj_property expression
    {$$ = 'o.' + $3 + ' = ' + $4 + ';' }
  | obj_keyword dot color_keyword color_property
    {$$ = 'o.' + $3 + ' = ' + $4 + ';' }
  ;

obj_property
  : width
    {$$ = $1;}
  | height
    {$$ = $1;}
  | color_keyword
    {$$ = $1;}
  | size_keyword
    {$$ = $1;}
  ;

return
  : return_keyword value
    {$$ = "return " + $2}
  ;

expressions
  : expression
    {$$ = $1}
  | expressions expression
    {$$ = $1 + ", " + $2}
  ;

iio_fn
  : add_fn
    {$$ = $1;}
  | alert_fn
    {$$ = $1;}
  | set_fn
    {$$ = $1;}
  ;

for_statement
  : for_keyword var_keyword variable assign expression to_keyword expression statements end
    {$$ = '\t\tfor(var ' + $3 + ' = ' + $5 + '; '+$3+'<'+$7+';'+$3+'++) {\n' + $8 + '\t\t}\n'}
  | for_keyword var_keyword variable assign expression to_keyword expression by_keyword expression statements end
    {$$ = '\t\tfor(var ' + $3 + ' = ' + $5 + '; '+$3+'<'+$7+';'+$3+'+=' + $9 + ') {\n' + $10 + '\t\t}\n'}
  ;

while_statement
  : while_keyword expression statements end
    {$$ = '\t\twhile(' + $2 + ') {\n' + $3 + '\t\t}\n'}
  ;

/* Runs its block every so many seconds, re-reading the interval after each run, so a program
   can speed up or slow down. */
every_statement
  : every_keyword value seconds_keyword statements end
    {$$ = '\t\tapp.loop(1/(' + $2 + '), function(){\n' + $4 + '\t\treturn 1/(' + $2 + ');\n\t\t});\n'}
  ;

append_statement
  : append_keyword expression to_keyword variable
    {$$ = '\t\t' + $4 + '.push(' + $2 + ');\n'}
  ;

if_statement
  : if_keyword expression statements end
    {$$ = "\t\tif(" + $2 + "){\n" + $3 + "\t\t}\n"}
  | if_keyword expression statements else_keyword statements end
    {$$ = "\t\tif(" + $2 + "){\n" + $3 + "\t\t} else {\n" + $5 + "\n}\n" }
  | if_keyword expression statements elseif_keyword expression statements end
    {$$ = "\t\tif(" + $2 + "){\n" + $3 + "\t\t} else if( "+ $5 +" ){\n" + $6 + "\n}\n" }
  | if_keyword expression statements elseif_keyword expression statements else_keyword statements end
    {$$ = "\t\tif(" + $2 + "){\n" + $3 + "\t\t} else if( "+ $5 +" ){\n" + $6 + "\n} else {\n" + $8 + "\n}\n" }
  ;

alert_fn
  : alert alertparam end
    {$$ = "alert(" + $2 + " )" }
  ;

alertparam
  : expression
    {$$ = $1 }
  | color_property
    {$$ = $1}
  ;

add_fn
  : add genparams end
    {$$ = "add({\n\t\t\t" + $2 + "\n\t\t})" }
  ;

set_fn
  : set genparams end
    {$$ = "set({\n\t\t\t" + $2 + "\n\t\t})" }
  ;

genparams
  : genparam
    {$$ = $1}
  | genparams genparam
    {$$ = $1 + ",\n\t\t\t" + $2 }
  ;

genparam
  : position_property
    {$$ = "pos: " + $1 }
  | size_property
    {$$ = $1 }
  | color_property
    {$$ = "color: " + $1 }
  | color_keyword color_property
    {$$ = "color: " + $2 }
  | type
    {$$ = "type: " + $1 }
  | outline_property
    {$$ = $1 }
  | shadow_property
    {$$ = $1 }
  | lineWidth_property
    {$$ = $1 }
  | alpha_property
    {$$ = "alpha: " + $1 }
  | vel_property
    {$$ = "vel: " + $1 }
  | acc_property
    {$$ = $1 }
  | shrink_property
    {$$ = $1 }
  | grid_property
    {$$ = $1 }
  | click_property
    {$$ = $1 }
  | text_property
    {$$ = $1 }
  ;

type
  : type_circ
    {$$ = "iio.CIRC" }
  | type_x
    {$$ = "iio.X" }
  | type_circle
    {$$ = "iio.CIRC" }
  | type_ellipse
    {$$ = "iio.CIRC" }
  | type_square
    {$$ = "iio.RECT" }
  | type_rectangle
    {$$ = "iio.RECT" }
  ;

lineWidth_property
  : lineWidth_keyword expression
    {$$ = "lineWidth: " + $2 }
  ;

grid_property
  : type_grid color_property expression
    {$$ = "type:iio.GRID,\n\t\t\tgridColor:" + $2 + ",\n\t\t\tC: " + $3 + ",\n\t\t\tR: " + $3 }
  ;

/* The names given to click are bound, in order, to where the click landed and,
   on a grid, the cell clicked and the cell's center. */
click_property
  : click_keyword '(' variables ')' statements end
    {$$ = "click:function(event," + $3 + "){" + $5 + "}" }
  | click_keyword '(' ')' statements end
    {$$ = "click:function(){" + $4 + "}" }
  ;

text_property
  : text_keyword value
    {$$ = "text: " + $2 }
  ;

shrink_property
  : shrink_keyword expression
    {$$ = "shrink:[" + $2 + "\t\t\t]" }
  | shrink_keyword expression then_keyword statements end
    {$$ = "shrink:[" + $2 + ",function(o){" + $4 + "\t\t\t}]" }
  ;

position_property
  : center
    {$$ = "app.center"}
  | vector
    {$$ = $1}
  | pos_keyword center
    {$$ = "app.center"}
  | pos_keyword variable %prec NOCALL
    {$$ = $2;}
  | pos_keyword vector
    {$$ = $2;}
  ;

outline_property
  : outline_keyword expression color_property
    {$$ = "lineWidth: "+$2+", outline: "+$3 }
  | outline_keyword color_property expression
    {$$ = "outline: "+$2+", lineWidth: "+$3 }
  ;

/* A soft shadow behind the shape, its color and blur in either order. iio Engine reads it
   from one string. */
shadow_property
  : shadow_keyword color_property expression
    {$$ = "shadow: " + $2 + " + ' ' + (" + $3 + ")" }
  | shadow_keyword expression color_property
    {$$ = "shadow: " + $3 + " + ' ' + (" + $2 + ")" }
  ;

alpha_property
  : alpha_keyword expression
    {$$ = $2 }
  ;

vel_property
  : vel_keyword vector
    {$$ = $2}
  ;

acc_property
  : acc_keyword vector
    {$$ = "acc: " + $2}
  ;

vector
  : expression delimiter_vector expression
    {$$ = '{ x: ' + $1 + ', y: ' + $3 + '}' }
  | expression delimiter_vector expression delimiter_vector expression
    {$$ = '{ x: ' + $1 + ', y: ' + $3 + ', r:' + $5 + '}'}
  ;

size_property
  : expression
    {$$ = "width: " + $1 }
  | size_keyword expression
    {$$ = "width: " + $2 }
  | size_keyword expression delimiter_vector expression
    {$$ = "width: " + $2+ ", height: " + $4 }
  ;

color_property
  : color_constant
    {$$ = "'" + $1 + "'" }
  | color_random
    {$$ = "iio.random.color()" }
  | color_keyword variable
    {$$ = $2 }
  ;

random_property
  : random_keyword expression to_keyword expression
    {$$ = "iio.random.num("+$2+","+$4+")" }
  | random_whole expression to_keyword expression
    {$$ = "iio.random.integer("+$2+","+$4+")" }
  ;

value
  : number
    {$$ = $1}
  | string
    {$$ = $1}
  | width
    {$$ = "app.width"}
  | height
    {$$ = "app.height"}
  | variable %prec NOCALL
    {$$ = $1}
  | variable dot variable
    {$$ = $1 + '.' + $3}
  | variable at_keyword value
    {$$ = $1 + '[' + $3 + ']'}
  | length_of variable
    {$$ = $2 + '.length'}
  | list_keyword
    {$$ = '[]'}
  | fn_call
    {$$ = $1}
  | '(' value ')'
    {$$ = '(' + $2 + ')'}
  | value '+' value
      {$$ = $1 + '+' + $3;}
  | value '-' value
      {$$ = $1 + '-' + $3;}
  | value '*' value
      {$$ = $1 + '*' + $3;}
  | value '/' value
      {$$ = $1 + '/' + $3;}
  | value '^' value
      {$$ = 'Math.pow('+ $1 + ',' + $3 + ')' }
  | value is value
      {$$ = $1 + '===' + $3;}
  | value isnt value
      {$$ = $1 + '!==' + $3;}
  | value '<' value
      {$$ = $1 + '<' + $3;}
  | value '>' value
      {$$ = $1 + '>' + $3;}
  | value '<=' value
      {$$ = $1 + '<=' + $3;}
  | value '>=' value
      {$$ = $1 + '>=' + $3;}
  | value and value
      {$$ = $1 + '&&' + $3;}
  | value or value
      {$$ = $1 + '||' + $3;}
  | not value
      {$$ = '!(' + $2 + ')';}
  | E
      {$$ = 'Math.E' }
  | PI
      {$$ = 'Math.PI' }
  ;
