part of parserflow;

class MatchInfo {
  static final int MATCH_FAILED = -1;
  int counter;
  int start;
  MatchInfo({this.counter: 0, this.start});

  int add(var v) {
    if (v is int)
      counter += v;
    else if (v is MatchInfo)
      counter += v.counter;
    return counter;
  }

  MatchInfo operator<<(var a) {
    add(a);
    return this;
  }

  bool get match => counter != MATCH_FAILED;
}