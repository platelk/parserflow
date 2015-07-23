part of parserflow;

int isDigitMatcher(var data) {
  var v;
  if (data is List) {
   if (data.length == 0)
     return MatchInfo.MATCH_FAILED;
   v = data[0];
  }
  else if (data is ParseUnit)
    v = data.value;
  else
    v = data;
  if  (["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(v)) {
    return 1;
  } else {
    return MatchInfo.MATCH_FAILED;
  }
}

int isNumMatcher(var data) {
  int tmp = 0;
  for (var v in data) {
    if (isDigitMatcher(v) == MatchInfo.MATCH_FAILED)
      return tmp == 0 ? MatchInfo.MATCH_FAILED : tmp;
    tmp++;
  }
  return tmp;
}

class IsDigit extends Rules {
  IsDigit() : super("IsDigit", matcher: isDigitMatcher, quantifier:Quantifier.One) {
    this.isTerminal = true;
  }
}

class IsNum extends Rules {
  IsNum() : super("IsNum", matcher: isNumMatcher, quantifier: Quantifier.One) {
    this.isTerminal = true;
  }
}

IsNum isNum = new IsNum();
IsDigit isDigit = new IsDigit();
