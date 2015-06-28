part of parserflow;

enum Quantifier {
  OneOrMore,
  OneOrNot,
  ZeroOrMore,
  One
}

bool _continueCheck(int nbMatch, Quantifier quantifier) {
  switch (quantifier) {
    case Quantifier.One:
      if (nbMatch == 1) return false;
      break;
    case Quantifier.OneOrMore:
      break;
    case Quantifier.OneOrNot:
      if (nbMatch == 1) return false;
      break;
    case Quantifier.ZeroOrMore:
      break;
  }
  return true;
}

bool _matchQuantifier(int nbMatch, Quantifier quantifier) {
  switch (quantifier) {
    case Quantifier.One:
      if (nbMatch == 1) return true;
      break;
    case Quantifier.OneOrMore:
      if (nbMatch >= 1) return true;
      break;
    case Quantifier.OneOrNot:
      if (nbMatch <= 1) return true;
      break;
    case Quantifier.ZeroOrMore:
      return true;
  }
  return false;
}

MatchInfo matchQuantifyRules(List data, RulesMatcher r, Quantifier quantifier) {
  int nbMatch = 0;
  int tmp = 0;
  int count = 0;
  MatchInfo match = new MatchInfo();

  do {

    tmp = r(data.sublist(count));
    if (tmp != MatchInfo.MATCH_FAILED) nbMatch++;
    count += tmp == MatchInfo.MATCH_FAILED ? 0 : tmp;
  } while(count < data.length && tmp != MatchInfo.MATCH_FAILED && _continueCheck(nbMatch, quantifier));
  if (_matchQuantifier(nbMatch, quantifier)) {
    match << count;
    return match;
  } else {
    match.counter = MatchInfo.MATCH_FAILED;
    return match;
  }
}