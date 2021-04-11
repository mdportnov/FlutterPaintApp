import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'data.dart';

// Рисование карандашом
// Стирание
// Рисование прямой и прямоугольника
// Выбор цвета
//* Undo-действие

void main() {
  runApp(MyApp());
}

final GlobalKey globalKey = new GlobalKey();

PainterController controller = new PainterController();
PainterController _controller;

setPaintController() {
  _controller = _newController();
}

PainterController _newController() {
  controller.thickness = penThickness;
  controller.drawColor = selectedColor;
  controller.backgroundColor = Colors.white;
  return controller;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paint App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget paintScreen() {
    return RepaintBoundary(
      key: globalKey,
      child: Container(
          height: MediaQuery.of(context).size.height - 200,
          child: Painter(_controller)),
    );
  }

  @override
  void initState() {
    super.initState();
    setPaintController();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Color.fromRGBO(138, 35, 135, 1.0),
                  Color.fromRGBO(73, 64, 182, 1.0),
                  Color.fromRGBO(51, 98, 193, 1.0),
                  Color.fromRGBO(51, 148, 193, 1.0),
                ])),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  width: w * 0.9,
                  height: h * 0.8,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 5.0,
                            spreadRadius: 1.0)
                      ]),
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      child: paintScreen()),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  width: w * 0.9,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                              color: selectedColor,
                              onPressed: () {
                                selectColor();
                              },
                              tooltip: "Palette",
                              icon: Image.asset('assets/images/palette.png')),
                          IconButton(
                            onPressed: () {
                              _showInstrumentPicker();
                            },
                            tooltip: "Figures",
                            icon: Image.asset('assets/images/shape.png'),
                          ),
                          IconButton(
                              icon: Image.asset('assets/images/eraser.png'),
                              onPressed: () {
                                selectedColor = Colors.white;
                                setPaintController();
                              },
                              tooltip: "Eraser"),
                          IconButton(
                              onPressed: () {
                                controller.clear();
                              },
                              tooltip: "Clear all",
                              icon: Icon(Icons.layers_clear)),
                          IconButton(
                              onPressed: () {
                                controller.undo();
                              },
                              tooltip: "Undo",
                              icon: Icon(Icons.undo)),
                        ],
                      ),
                      Row(children: <Widget>[
                        Expanded(
                            child: Slider(
                          min: 2.0,
                          max: 50.0,
                          activeColor: selectedColor,
                          value: penThickness,
                          onChanged: (value) {
                            this.setState(() {
                              penThickness = value;
                              setPaintController();
                            });
                          },
                        )),
                      ])
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void selectColor() {
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            title: const Text('Choose color'),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  this.setState(() {
                    selectedColor = color;
                    setPaintController();
                  });
                },
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close"))
            ],
          );
        });
  }

  void _dismissInstrumentsDialog() {
    _showToast(mode.toString());
    Navigator.pop(context, false);
  }

  void _showToast(String mode) {
    Fluttertoast.showToast(
        msg: mode,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> _showInstrumentPicker() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Figure'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                    child: Row(
                      children: [
                        SizedBox(
                          height: 80.0,
                          width: 80.0,
                          child: IconButton(
                              onPressed: () {
                                mode = DrawMode.pencil;
                                _dismissInstrumentsDialog();
                              },
                              tooltip: "Pencil",
                              icon: Image.asset('assets/images/pen.png')),
                        ),
                        SizedBox(
                          height: 80.0,
                          width: 80.0,
                          child: IconButton(
                              onPressed: () {
                                mode = DrawMode.rect;
                                _dismissInstrumentsDialog();
                              },
                              tooltip: "Rectangle",
                              icon: Image.asset('assets/images/rect.png')),
                        ),
                        SizedBox(
                          height: 80.0,
                          width: 80.0,
                          child: IconButton(
                              onPressed: () {
                                mode = DrawMode.line;
                                _dismissInstrumentsDialog();
                              },
                              tooltip: "Line",
                              icon: Image.asset('assets/images/diagonal-line.png')),
                        ),
                      ],
                    ))
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Exit'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class Painter extends StatefulWidget {
  final PainterController painterController;
  Offset startOffset;
  Offset endOffset;

  Painter(PainterController painterController)
      : this.painterController = painterController,
        super(key: new ValueKey<PainterController>(painterController));

  @override
  _PainterState createState() => new _PainterState();
}

class _PainterState extends State<Painter> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = new CustomPaint(
      willChange: true,
      painter: new _PainterPainter(widget.painterController._pathHistory,
          repaint: widget.painterController),
    );
    child = new ClipRect(child: child);
    child = new GestureDetector(
      child: child,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
    );

    return new Container(
      child: child,
      width: double.infinity,
      height: double.infinity,
    );
  }

  void _onPanStart(DragStartDetails start) {
    if (mode == DrawMode.pencil) {
      Offset pos = (context.findRenderObject() as RenderBox)
          .globalToLocal(start.globalPosition);
      widget.painterController._pathHistory.add(pos);
    }
    if (mode == DrawMode.rect) {
      widget.startOffset = (context.findRenderObject() as RenderBox)
          .globalToLocal(start.globalPosition);
    }
    if (mode == DrawMode.line) {
      widget.startOffset = (context.findRenderObject() as RenderBox)
          .globalToLocal(start.globalPosition);
      widget.painterController._pathHistory.add(widget.startOffset);
    }

    widget.painterController._notifyListeners();
  }

  void _onPanUpdate(DragUpdateDetails update) {
    if (mode == DrawMode.pencil) {
      Offset pos = (context.findRenderObject() as RenderBox)
          .globalToLocal(update.globalPosition);
      widget.painterController._pathHistory.updateCurrent(pos);
    } else {
      widget.endOffset = (context.findRenderObject() as RenderBox)
          .globalToLocal(update.globalPosition);
    }

    widget.painterController._notifyListeners();
  }

  void _onPanEnd(DragEndDetails end) {
    // widget.painterController._pathHistory.endCurrent();

    if (mode == DrawMode.rect) {
      widget.painterController._pathHistory
          .addRect(widget.startOffset, widget.endOffset);
    }

    if (mode == DrawMode.line) {
      widget.painterController._pathHistory.add(widget.endOffset);
      widget.painterController._pathHistory.updateCurrent(widget.endOffset);
    }
    widget.painterController._pathHistory.endCurrent();
    widget.painterController._notifyListeners();
  }
}

class _PainterPainter extends CustomPainter {
  final _PathHistory _path;

  _PainterPainter(this._path, {Listenable repaint}) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    _path.draw(canvas, size);
  }

  @override
  bool shouldRepaint(_PainterPainter oldDelegate) {
    return true;
  }
}

class _PathHistory {
  List<MapEntry<Path, Paint>> _paths;
  Paint currentPaint;
  Paint _backgroundPaint;
  bool _inDrag;

  _PathHistory() {
    _paths = new List<MapEntry<Path, Paint>>();
    _inDrag = false;
    _backgroundPaint = new Paint();
  }

  void setBackgroundColor(Color backgroundColor) {
    _backgroundPaint.color = backgroundColor;
  }

  void undo() {
    if (!_inDrag && _paths.isNotEmpty) _paths.removeLast();
  }

  void clear() {
    if (!_inDrag) _paths.clear();
  }

  void add(Offset startPoint) {
    if (!_inDrag) {
      _inDrag = true;
      Path path = new Path();
      if (mode == DrawMode.pencil || mode == DrawMode.line) {
        path.moveTo(startPoint.dx, startPoint.dy);
        _paths.add(new MapEntry<Path, Paint>(path, currentPaint));
      }
    }
  }

  void addRect(Offset startPoint, Offset endPoint) {
    if (!_inDrag && mode == DrawMode.rect) {
      _inDrag = true;
      Path path = new Path();
      path.addRect(Rect.fromLTRB(
          startPoint.dx, startPoint.dy, endPoint.dx, endPoint.dy));
      _paths.add(new MapEntry<Path, Paint>(path, currentPaint));
    }
  }

  void updateCurrent(Offset nextPoint) {
    if (_inDrag) {
      Path path = _paths.last.key;
      path.lineTo(nextPoint.dx, nextPoint.dy);
    }
  }

  void endCurrent() {
    _inDrag = false;
  }

  void draw(Canvas canvas, Size size) {
    canvas.drawRect(
        new Rect.fromLTWH(0.0, 0.0, size.width, size.height), _backgroundPaint);
    for (MapEntry<Path, Paint> path in _paths)
      canvas.drawPath(path.key, path.value);
  }
}

class PainterController extends ChangeNotifier {
  Color _drawColor = selectedColor;
  Color _backgroundColor = new Color.fromARGB(255, 255, 255, 255);

  double _thickness = 1.0;

  _PathHistory _pathHistory;

  PainterController() {
    _pathHistory = new _PathHistory();
  }

  Color get drawColor => _drawColor;

  set drawColor(Color color) {
    _drawColor = color;
    _updatePaint();
  }

  Color get backgroundColor => _backgroundColor;

  set backgroundColor(Color color) {
    _backgroundColor = color;
    _updatePaint();
  }

  double get thickness => _thickness;

  set thickness(double t) {
    _thickness = t;
    _updatePaint();
  }

  void _updatePaint() {
    Paint paint = new Paint();
    paint.color = drawColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = thickness;
    _pathHistory.currentPaint = paint;
    _pathHistory.setBackgroundColor(backgroundColor);
    notifyListeners();
  }

  void undo() {
    _pathHistory.undo();
    notifyListeners();
  }

  void _notifyListeners() {
    notifyListeners();
  }

  void clear() {
    _pathHistory.clear();
    notifyListeners();
  }
}
