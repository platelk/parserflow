part of parserflow;

class Scanner<T> {
  static final log = new Logger("Scanner");
  int _currentPos = 0;
  int _currentPosInline = 0;
  int _currentLine = 0;

  StreamSubscription<ParseUnit<T>> _subscription;
  StreamController<ParseUnit<T>> _controller;

  Stream<T> source;
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

  Future<ParseUnit<T>> scanOne() {
    log.finest("Calling scan()");

    return this.source.first.then((T e) {
      _currentPos++;
      if (e == this.conf.endLine) {
        _currentLine++;
        _currentPosInline = 0;
      }
      log.finer("Receive: [${e}]");
      return new ParseUnit(e, line: _currentLine, pos: _currentPos, inlinePos: _currentPosInline);
    });
  }

  Stream<ParseUnit<T>> scan() async* {
    yield (await scanOne());
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