part of parserflow;

class MatchInfo {
  static final int MATCH_FAILED = -1;
  int counter = 0;
  int start = 0;
  var _matchData;
  Rules matchRule;
  List<MatchInfo> child;
  Map data = {};
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

  MatchInfo operator[]=(var key, var value) {
    this.data[key] = value;
    return this;
  }

  MatchInfo operator[](var key) {
    return this.data[key];
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
    var s =  "(MatchInfo, ${matchRule != null ? matchRule.name: ''})";
    return s;
  }

  String toStringFullInfo() {
    var s =  "[MatchInfo] count: ${counter}, start: ${start}, rules: ${matchRule}, nbChild: ${child.length}, match |${this.matchData}|\n";
    for (var m in child) {
      if (m != this)
        s += "  - " + m.toString();
    }
    return s;
  }

  List<String> matchDataTree() {
    var l = this.matchRule is Or || this.matchRule is And || this.matchData == null || this.child.length > 0 ? [] : [this.matchData];
    for (var m in child) {
      if (m != this)
        l.add(m.matchDataTree());
    }
    if (l.length == 1)
      return l[0];
    return l;
  }


  matchTree() {
    if (this.child.length == 0 && this.matchRule != null)
      return this;
    var l = [];
    for (var m in child) {
      var t = m.matchTree();
      if (t != null)
        l.add(t);
    }
    if (this.matchRule == null && l.length == 0)
      return null;
    else if (this.matchRule == null && l.length == 1)
      return l[0];
    else if (this.matchRule == null && l.length > 0)
      return l;
    else if (l.length == 0)
      return this;
    else
      return [this, l];
    //return this.matchRule == null && l.length == 0 ? null : (l.length == 0 ? [this] : [this, l]);
  }
}