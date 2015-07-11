part of parserflow;

class Or extends Rules {
  Or(List<Rules> r) : super("Or") {
    this._child.addAll(r);
  }

  MatchInfo _checkChild(List data) {
    MatchInfo counter = new MatchInfo()..matchRule = this;
    MatchInfo tmp;

    for (Rules r in _child) {
      tmp = r.check(data);
      counter.child.add(tmp);
      if (tmp.match == true) {
        counter << tmp;
        return counter;
      }
    }
    counter.counter = MatchInfo.MATCH_FAILED;
    return counter;
  }

  Rules operator|(Rules r) {
    if (r is Or) {
      this._child.addAll(r._child);
    } else {
      this._child.add(r);
    }
    return this;
  }

  Rules _clone() {
    return new Or();
  }
}

class And extends Rules {
  And(List<Rules> r) : super("And") {
    this._child.addAll(r);
  }


  Rules operator&(Rules r) {
    if (r is And) {
      this._child.addAll(r._child);
    } else {
      this._child.add(r);
    }
    return this;
  }

  Rules _clone() {
    return new And();
  }
}