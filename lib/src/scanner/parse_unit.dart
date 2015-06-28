part of parserflow;

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