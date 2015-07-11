part of parserflow;

class MatchInfo {
  static final int MATCH_FAILED = -1;
  int counter = 0;
  int start = 0;
  var _matchData;
  Rules matchRule;
  List<MatchInfo> child;
  MatchInfo({this.counter: 0, this.start: 0, this.matchRule, this.child}) {
    if (this.child == null) this.child = [];
  }

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

  get matchData {
    return _matchData;
  }

  set matchData(var data) {
    _matchData = data;
  }

  operator+(var data) {
    if (_matchData == null)
      _matchData = data;
    else
      _matchData += data;
    return _matchData;
  }

  bool get match => counter != MATCH_FAILED;

  String toString() {
    var s =  "[MatchInfo] count: ${counter}, start: ${start}, rules: ${matchRule}, nbChild: ${child.length}\n";
    for (var m in child) {
      s += "  - " + m.toString();
    }
    return s;
  }
}