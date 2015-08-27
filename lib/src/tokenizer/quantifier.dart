part of parserflow;

/**
 * Quantifier are use to specify the number of element that can be match at maximum or minimum
 */
enum Quantifier {
  OneOrMore,
  OneOrNot,
  ZeroOrMore,
  One,
  NTimes
}

class Container extends Rules {
  Container(): super("Container", quantifier:Quantifier.One);
}

bool continueCheck(int nbMatch, Quantifier quantifier, int quantity) {
  switch (quantifier) {
    case Quantifier.One:
      if (nbMatch == 1) return false;
      break;
    case Quantifier.OneOrMore:
      break;
    case Quantifier.OneOrNot:
      if (nbMatch == 1) return false;
      break;
    case Quantifier.NTimes:
      if (nbMatch == quantity) return false;
      break;
    case Quantifier.ZeroOrMore:
      break;
  }
  return true;
}

bool matchQuantifier(int nbMatch, Quantifier quantifier, int quantity) {
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
    case Quantifier.NTimes:
      if (nbMatch == quantity) return true;
      break;
    case Quantifier.ZeroOrMore:
      return true;
  }
  return false;
}

MatchInfo matchQuantifyRules(List data, RulesMatcher r, Quantifier quantifier, {int quantity: 1, Rules from: null}) {
  int nbMatch = 0;
  int tmp = 0;
  int count = 0;
  MatchInfo match = new MatchInfo();

  do {
    if (data.length > 0 && data[count] is Rules) {
      tmp = data[count] == from ? 1 : MatchInfo.MATCH_FAILED;
    } else {
      tmp = r(data.sublist(count));
    }
    if (tmp != MatchInfo.MATCH_FAILED) nbMatch++;
    count += (tmp == MatchInfo.MATCH_FAILED ? 0 : tmp);
  } while(count < data.length && tmp != MatchInfo.MATCH_FAILED && continueCheck(nbMatch, quantifier, quantity));
  if (matchQuantifier(nbMatch, quantifier, quantity)) {
    match << count;
    match.matchData = data.sublist(match.start, match.start+match.counter);
    return match;
  } else {
    match.matchData = data.sublist(match.start, match.start+match.counter);
    match.counter = MatchInfo.MATCH_FAILED;
    return match;
  }
}