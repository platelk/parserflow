part of parserflow;

/**
 * MatchInfo will contains all the information about what have been match by a matcher as:
 * - Number of character match
 * - Which rules have been match
 * - ...
 */
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

  /**
   * Increase the number of character match
   */
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

  operator[]=(var key, var value) {
    this.data[key] = value;
  }

  operator[](var key) {
    return this.data[key];
  }

  /**
   * return the matched string
   */
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

  /**
   * Find the MatchInformation the belong to a specific Rules inside a tree of MatchInfo.
   * This method can be use to retrieve information store inside a child node
   */
  MatchInfo get(var name, {bool rec : false}) {
    for (var m in this.child) {
      if (m.matchRule != null && m.matchRule.name == name)
        return m;
      if (rec) {
        var tmp = m.get(name, rec: rec);
        if (tmp != null)
          return tmp;
      }
    }
    return null;
  }

  /**
   * Find all MatchInformation the belong to a specific Rules inside a tree of MatchInfo.
   * This method can be use to retrieve information store inside a child node
   */
  List<MatchInfo> getAll(var name, {bool rec : false}) {
    var l = [];
    for (var m in this.child) {
      if (m.matchRule != null && m.matchRule.name == name)
        l.add(m);
      if (rec) {
        var tmp = m.getAll(name, rec: rec);
        if (tmp.length != 0)
          l.addAll(tmp);
      }
    }
    return l;
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
    if (this.child.length == 0 && this.matchRule != null && this.matchRule.name != "Container")
      return this;
    var l = [];
    for (var m in child) {
      var t = m.matchTree();
      if (t != null)
        l.add(t);
    }
    if ((this.matchRule == null || this.matchRule.name == "Container") && l.length == 0)
      return null;
    else if (this.matchRule == null && l.length == 1)
      return l[0];
    else if ((this.matchRule == null || this.matchRule.name == "Container") && l.length > 0)
      return l;
    else if (l.length == 0)
      return this;
    else
      return [this, l];
    //return this.matchRule == null && l.length == 0 ? null : (l.length == 0 ? [this] : [this, l]);
  }
}