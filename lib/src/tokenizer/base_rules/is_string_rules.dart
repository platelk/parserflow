part of parserflow;

class IsStr extends Rules {
  IsStr(String s): super("IsStr", matcher: (var data) {
    if (data is String)
      return s == data;
    else if (data is List<String>)
      return s == (data.join());
    else if (data is List<int>)
      return s == (new String.fromCharCodes(data));
  }, quantifier:Quantifier.One);
}


hasMatcherGenerator(var s) {
  return (var data) {
    var tmp;
    if (data is String)
      tmp = data;
    else if (data is List<String>)
      tmp = (data.join());
    else if (data is List<int>)
      tmp = (new String.fromCharCodes(data));
    if (s is String) {
     if (s == tmp)
       return tmp.length;
      return MatchInfo.MATCH_FAILED;
    }
    else if (s is RegExp) {
      var m = (s as RegExp).firstMatch(tmp);
      if (m != null && m.start == 0) {
        var m = (s as RegExp).firstMatch(tmp);
        return m.end - m.start;
      } else {
        return MatchInfo.MATCH_FAILED;
      }
    }
  };
}

class Has extends Rules {
  Has(var s): super("Has", matcher: hasMatcherGenerator(s), quantifier:Quantifier.One);
}

Rules isStr(String s) {
  return new IsStr(s);
}

Rules has(var s) {
  return new Has(s);
}

Rules hasRegExp(String s) {
  return new Has(new RegExp(s));
}

Rules isSpace = hasRegExp(r'[ |\t|\n]');