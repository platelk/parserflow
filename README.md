# Parserflow

Parserflow is a prototype of parser written in Dart inspire by [pyrser](http://pythonhosted.org/pyrser) and [PetitParser](https://github.com/petitparser/dart-petitparser).
This parser aims to provide a simple tool to implement different type of parser like LL(k) or LR(k), by offering simple mechanism like hook or grammar definition.

## Installation

To install and run example located in example/ folder you need :

* install dart by following the instruction [here](https://www.dartlang.org/downloads/)
* run  `pub get` in the root directory of the project to get all the dependencies
* Then to run a example : `pub run example/math_expr.dart`

## Aims

The main objective of parserflow is to provide enough abstraction and functionality to easily implement the parser do you need.

## Features

Parserflow allow you to :
- **[DONE]** Create your grammar by code like : 
```dart
var myRule = (isDigit | isMathOperator) & isNum;
```
- **[DONE]** Use a comprehensive syntax to define quantity like
```dart
var myRule = (isDigit["*"] | isMathOperator["*"]) & isDigit[3]
```
- **[DONE]** Simply define hook
```dart
  var number = (has("-")["*"] & isNum)..name = "number";
  number.onParse.add((i) {
    print("number: ${i.matchData}");
    i["value"] = int.parse(i.matchData.join());
  });
```
- **[DONE]** Use directly some parser implementation like LL(k) or LR(k)
```dart
  var number = ((has('0') | has('1') | has('2'))["+"])..name = "num";
  var operator = (has('+') | has('-'))..name = "operator";
  var operation = (number & (((operator & number)..name="op")["*"]))..name = "operation";

  var expr = operation;
  var grammar = new CNFGrammarGenerator().generateGrammars(expr);
  var nfa = new NFA();
  var table = nfa.generatorNFA(grammar);
  var lrTable = new LrTableGenerator(nfa);
  var lr = new LrParser(tableGenerator: lrTable);
  lr.parse("{x: {x}}");
```
- **[TO DO]** Directly parse from a BNF
   
## Example

### Create rules and parse a simple string
Here a example of a simple rules creation and parse a simple string
```dart
import 'package:parserflow/parserflow.dart';

void main() {
    var s = "96-96*2";
    
    var r = isNum["?"] & isMathOperator & isNum & (isMathOperator["?"] & isNum)["*"];
    var a = r.consume(s);
    print(a);
}
```

### Parse a simple math expression
Here a part of the example that you can find in 'example/math_expr.dart'
```dart
void main() {
  var number = (isNum)..name = "number"; // Define rule name 'number'
  number.onParse.add((i) {  // apply a function to be call every time a 'number' is match
    i["value"] = int.parse(i.matchData.join()); // matchData is of type List, so i join to recreate the string
  });

  var factor_op = (hasRegExp(r"[ \* | \/ | % ]")..name = "high_op")((i) => i["op"] = i.matchData.join()); // you can also use the "()" operator to directly pass a function (or 'hook')
  var op = (hasRegExp(r"[-|+]")..name = "op")((i) => i["op"] = i.matchData.join());

  var factor = (((number & factor_op & number)..name = "factor") | number)..name = "factor";
  factor.onParse.add(factorHook);

  var expr = (factor & ((op & factor)..name = "low_exp")["*"])(resolveExpr);
  var input = "2*3-4*2";
  var res = expr.check(input);
  print("res : ${res.data["res"]}");
}
```

## Future

Actually my main focus is to make parserflow as easy as possible, but the second step will be to make it a quick as posible.

## The Author

Actualy this library is developped by myself, if you have any idea, amelioration, bug, ... do not hesitate contacting me.
G+ : [+Kevin PLATEL](https://plus.google.com/+KévinPlatel)
Mail : [Kevin PLATEL](platel.kevin@gmail.com)