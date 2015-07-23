part of parserflow;

class ParsingTable {
  var data;

  ParsingTable() {
    data = {};
  }

  operator[]=(key, value) {
    data[key] = value;
  }

  operator[](key) {
    return data[key];
  }
}

abstract class TableGenerator {
  TableGenerator();

  ParsingTable generateTable(Rules r);
}