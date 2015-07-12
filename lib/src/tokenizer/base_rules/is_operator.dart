part of parserflow;

int isMathOperatorMatcher(var data) {
  var v;
  if (data is List) {
    if (data.length == 0)
      return MatchInfo.MATCH_FAILED;
    v = data[0];
  } else if (data is ParseUnit)
    v = data.value;
  else
    v = data;
  print(v);
  if (["+", "-", "/", "*", "%"].contains(v)) {
    return 1;
  } else {
    return MatchInfo.MATCH_FAILED;
  }
}

class IsMathOperator extends Rules {
  IsMathOperator() : super("IsMathOperator", matcher: isMathOperatorMatcher,
  quantifier: Quantifier.One);
}

IsMathOperator isMathOperator = new IsMathOperator();