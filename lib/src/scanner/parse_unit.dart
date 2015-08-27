part of parserflow;

/**
 * ParseUnit is a class that store all the information about one parsing unit (usually a character) as hits position in a file and in a line
 */
class ParseUnit<T> {
  int line;
  int pos;
  int inlinePos;
  T value;

  ParseUnit(this.value, {this.line, this.pos, this.inlinePos});

  String toString() {
    return "ParseUnit[value: |${value}|, line: ${line}, idx: ${inlinePos}]";
  }
}