# Parserflow

Parserflow is a prototype of parser written in Dart inspire by [pyrser](http://pythonhosted.org/pyrser) and [PetitParser](https://github.com/petitparser/dart-petitparser).
This parser aims to provide a simple tool to implement different type of parser like LL(k) or LR(k), by offering simple mechanism like hook or grammar definition.

## Aims

The main objective of parserflow is to provide enough abstraction and functionality to easily implement the parser do you need.

## Features

Parserflow allow you to :
   - [DONE] Create your grammar by code like : 
   ```dart
   var myRule = (isDigit | isMathOperator) & isNum;
   ```
   - [DONE] Use a comprehensive syntax to define quantity like
   ```dart
   var myRule = (isDigit["*"] | isMathOperator["*"]) & isDigit[3]
   ```
   - [IN PROGRESS] Simply define hook
   - [TO DO] Use directly some parser implementation like LL(k) or LR(k)
   - [TO DO] Directly parse from a BNF
   
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

## Future

Actually my main focus is to make parserflow as easy as possible, but the second step will be to make it a quick as posible.

## The Author

Actualy this library is developped by myself, if you have any idea, amelioration, bug, ... do not hesitate contacting me.
G+ : [+Kevin PLATEL](https://plus.google.com/+KévinPlatel)
Mail : [Kevin PLATEL](platel.kevin@gmail.com)