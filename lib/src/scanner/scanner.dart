part of parserflow;

class Scanner<T> {
  static final log = new Logger("Scanner");
  int _currentPos = 0;
  int _currentPosInline = 0;
  int _currentLine = 0;

  StreamSubscription<ParseUnit<T>> _subscription;
  StreamController<ParseUnit<T>> _controller;

  var source;
  ScannerConf conf;

  Scanner(Stream<T> source, {this.conf}) {
    if (this.conf == null) conf = new ScannerConf();
    this.source = source.asBroadcastStream();
    _controller = new StreamController<ParseUnit<T>>(
        onListen: _onListen,
        onPause: _onPause,
        onResume: _onResume,
        onCancel: _onCancel);
  }

  Scanner.fromString(String input, {this.conf}) {
    var s = new Stream.fromIterable(input.split(''));
    var source = s.asBroadcastStream();
    if (this.conf == null) conf = new ScannerConf();
    this.source = source.asBroadcastStream();
    _controller = new StreamController<ParseUnit<T>>(
        onListen: _onListen,
        onPause: _onPause,
        onResume: _onResume,
        onCancel: _onCancel);
  }

  Scanner.fromStringSync(String input, {this.conf}) {
    var s = input.split('');
    var source = s;
    if (this.conf == null) conf = new ScannerConf();
    this.source = source;
  }

  Future<ParseUnit<T>> scanOne() async {
    return this.source.first.then((T e) {
      _currentPos++;
      _currentPosInline++;
      if (e == this.conf.endLine) {
        _currentLine++;
        _currentPosInline = 0;
      }
      log.finer("Receive: [${e}]");
      if (this.conf.skip.contains(e))
        return this.scanOne();
      return new ParseUnit(e, line: _currentLine, pos: _currentPos, inlinePos: _currentPosInline);
    });
  }


  ParseUnit<T> scanOneSync() {
    if (this.source is! List) throw new Exception("Scanner error : can't use scanOneSync when source is a Stream");
    var e = this.source[_currentPos];
    _currentPos++;
    _currentPosInline++;
    if (e == this.conf.endLine) {
      _currentLine++;
      _currentPosInline = 0;
    }
    log.finer("Receive: [${e}]");
    if (this.conf.skip.contains(e))
      return this.scanOneSync();
    return new ParseUnit(e, line: _currentLine, pos: _currentPos, inlinePos: _currentPosInline);
  }


  List<ParseUnit<T>> scanSync() {
    var l = [];
    if (this.source is! List) throw new Exception("Scanner error : can't use scanSync when source is a Stream");
    while (_currentPos < this.source.length) {
      l.add(this.scanOneSync());
    }
    return l;
  }

  Stream<ParseUnit<T>> scan() async* {
    yield (await scanOne());
  }

  Future<bool> get finnish async {
    if (this.source is List)
      return this.source.length >= _currentPos;
    else if (this.source is Stream)
      return (this.source as Stream).isEmpty;
  }

  bool get finnishSync {
    if (this.source is List)
      return !(this.source.length > _currentPos);
    throw new Exception("Scanner error: can't use finnishSync when source is a Stream");
  }

  @override
  StreamSubscription<ParseUnit> listen(void onData(ParseUnit event), {Function onError, void onDone(), bool cancelOnError}) {
    return _controller.stream.listen(onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError);
  }

  void _onListen() {

  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  void _onPause() {
    _subscription.pause();
  }

  void _onResume() {
    _subscription.resume();
  }

  void _onData(String input) {

  }

  void _onDone() {
    _controller.close();
  }
}