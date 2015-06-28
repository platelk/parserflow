part of parserflow;

int isMathOperatorMatcher(var data) {
  var v;
  if (data is List)
    v = data[0];
  else if (data is ParseUnit)
    v = data.value;
  else
    v = data;
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