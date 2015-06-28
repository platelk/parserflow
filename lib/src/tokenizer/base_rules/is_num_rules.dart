part of parserflow;

int isDigitMatcher(var data) {
  var v;
  if (data is List)
    v = data[0];
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
    if (isDigitMatcher(v) == false)
      return tmp == 0 ? MatchInfo.MATCH_FAILED : tmp;
    tmp++;
  }
  print("IsNumMatcher : ${tmp}");
  return tmp;
}

class IsDigit extends Rules {
  IsDigit() : super("IsDigit", matcher: isDigitMatcher, quantifier:Quantifier.One);
}

class IsNum extends Rules {
  IsNum() : super("IsNum", matcher: isDigitMatcher, quantifier: Quantifier.OneOrMore);
}

IsNum isNum = new IsNum();
IsDigit isDigit = new IsDigit();
