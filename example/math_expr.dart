library parserflow.example;

import 'package:parserflow/parserflow.dart';

main() {
  var number = ((has('0') | has('1') | has('2'))["+"])..name = "num";
  var operator = (has('+') | has('-'))..name = "operator";
  var operation = (number & (((operator & number)..name="op")["*"]))..name = "operation";

  var expr = operation;
  var grammar = new CNFGrammarGenerator().generateGrammars(expr);
  print("grammar: \n${grammar}");

  var toolGrammar = '''
    Goal -> S
    S -> { S G
    S -> { S G
    G -> }
    G -> : L }
    S -> x
    S -> y
    L -> S
    L -> L , S
  ''';
  var nfa = new NFA();
  var table = nfa.generatorNFA(grammar);
  var lrTable = new LrTableGenerator(nfa);
  lrTable.printTable(lrTable.generateTable(), startPad: 65, linePad: 50, basePad: 15);
//  nfa = new NFA();
//  table = nfa.generatorNFA('''
//      Goal -> A
//      A -> ( A )
//      A -> Two
//      Two -> a
//      Two -> b
//  ''');
  var lr = new LrParser(tableGenerator: lrTable);
  lr.parse("111+222-000");
  var input = "12+2-1";
  var res = expr.check(input);
  print(res.matchTree());
//  print("res : ${res.data["res"]}");
}