import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:rich_editor/src/models/enum/bar_position.dart';
import 'package:rich_editor/src/models/rich_editor_options.dart';
import 'package:rich_editor/src/services/local_server.dart';
import 'package:rich_editor/src/utils/javascript_executor_base.dart';
import 'package:rich_editor/src/widgets/editor_tool_bar.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class RichEditor extends StatefulWidget {
  final String? value;
  final RichEditorOptions? editorOptions;
  final Function(File image)? getImageUrl;
  final Function(File video)? getVideoUrl;

  RichEditor({
    Key? key,
    this.value,
    this.editorOptions,
    this.getImageUrl,
    this.getVideoUrl,
  }) : super(key: key);

  @override
  RichEditorState createState() => RichEditorState();
}

class RichEditorState extends State<RichEditor> {
  InAppWebViewController? _controller;
  final Key _mapKey = UniqueKey();
  String assetPath = 'packages/rich_editor/assets/editor/editor.html';

  // InAppWebViewController? webViewController;

  int port = 5321;
  String html = '';
  LocalServer? localServer;
  JavascriptExecutorBase javascriptExecutor = JavascriptExecutorBase();

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _initServer();
    }
  }

  _initServer() async {
    localServer = LocalServer(port);
    await localServer!.start(_handleRequest);
  }

  void _handleRequest(HttpRequest request) {
    try {
      if (request.method == 'GET' &&
          request.uri.queryParameters['query'] == "getRawTeXHTML") {
      } else {}
    } catch (e) {
      print('Exception in handleRequest: $e');
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller = null;
    }
    if (!Platform.isAndroid) {
      localServer!.close();
    }
    super.dispose();
  }

  _loadHtmlFromAssets() async {
    final filePath = assetPath;
    _controller!.loadUrl(
      urlRequest: URLRequest(
        url: Uri.tryParse('http://localhost:$port/$filePath'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: widget.editorOptions!.barPosition == BarPosition.TOP,
          child: EditorToolBar(
            getImageUrl: widget.getImageUrl,
            javascriptExecutor: javascriptExecutor,
          ),
        ),
        Expanded(
          child: InAppWebView(
            key: _mapKey,
            onWebViewCreated: (controller) async {
              _controller = controller;
              setState(() {});
              if (!Platform.isAndroid) {
                await _loadHtmlFromAssets();
              } else {
                await _controller!.loadUrl(
                  urlRequest: URLRequest(
                    url: Uri.tryParse(
                        'file:///android_asset/flutter_assets/$assetPath'),
                  ),
                );
              }
            },
            onLoadStop: (controller, link) async {
              javascriptExecutor.init(_controller!);
              await _setInitialValues();
              _addJSListener();
            },
            // javascriptMode: JavascriptMode.unrestricted,
            // gestureNavigationEnabled: false,
            gestureRecognizers: [
              Factory(() => VerticalDragGestureRecognizer()..onUpdate = (_) {}),
            ].toSet(),
            onLoadError: (controller, url, code, e) {
              print("error $e $code");
            },
            onConsoleMessage: (controller, consoleMessage) async {
              print(
                'WebView Message: $consoleMessage',
              );
            },
          ),
        ),
        Visibility(
          visible: widget.editorOptions!.barPosition == BarPosition.BOTTOM,
          child: EditorToolBar(
            getImageUrl: widget.getImageUrl,
            javascriptExecutor: javascriptExecutor,
          ),
        ),
      ],
    );
  }

  _setInitialValues() async {
    if (widget.value != null) await javascriptExecutor.setHtml(widget.value!);
    if (widget.editorOptions!.padding != null)
      await javascriptExecutor.setPadding(widget.editorOptions!.padding!);
    if (widget.editorOptions!.backgroundColor != null)
      await javascriptExecutor
          .setBackgroundColor(widget.editorOptions!.backgroundColor!);
    if (widget.editorOptions!.baseTextColor != null)
      await javascriptExecutor
          .setBaseTextColor(widget.editorOptions!.baseTextColor!);
    if (widget.editorOptions!.placeholder != null)
      await javascriptExecutor
          .setPlaceholder(widget.editorOptions!.placeholder!);
    if (widget.editorOptions!.baseFontFamily != null)
      await javascriptExecutor
          .setBaseFontFamily(widget.editorOptions!.baseFontFamily!);
  }

  _addJSListener() async {
    _controller!.addJavaScriptHandler(
        handlerName: 'editor-state-changed-callback://',
        callback: (c) {
          print('Callback $c');
        });
  }

  /// Get current HTML from editor
  Future<String?> getHtml() async {
    try {
      html = await javascriptExecutor.getCurrentHtml();
    } catch (e) {}
    return html;
  }

  /// Set your HTML to the editor
  setHtml(String html) async {
    return await javascriptExecutor.setHtml(html);
  }

  /// Hide the keyboard using JavaScript since it's being opened in a WebView
  /// https://stackoverflow.com/a/8263376/10835183
  unFocus() {
    javascriptExecutor.unFocus();
  }

  /// Clear editor content using Javascript
  clear() {
    _controller!.evaluateJavascript(
        source: 'document.getElementById(\'editor\').innerHTML = "";');
  }

  /// Focus and Show the keyboard using JavaScript
  /// https://stackoverflow.com/a/6809236/10835183
  focus() {
    javascriptExecutor.focus();
  }

  /// Add custom CSS code to Editor
  loadCSS(String cssFile) {
    var jsCSSImport = "(function() {" +
        "    var head  = document.getElementsByTagName(\"head\")[0];" +
        "    var link  = document.createElement(\"link\");" +
        "    link.rel  = \"stylesheet\";" +
        "    link.type = \"text/css\";" +
        "    link.href = \"" +
        cssFile +
        "\";" +
        "    link.media = \"all\";" +
        "    head.appendChild(link);" +
        "}) ();";
    _controller!.evaluateJavascript(source: jsCSSImport);
  }

  /// if html is equal to html RichTextEditor sets by default at start
  /// (<p>​</p>) so that RichTextEditor can be considered as 'empty'.
  Future<bool> isEmpty() async {
    html = await javascriptExecutor.getCurrentHtml();
    return html == '<p>​</p>';
  }

  /// Enable Editing (If editing is disabled)
  enableEditing() async {
    await javascriptExecutor.setInputEnabled(true);
  }

  /// Disable Editing (Could be used for a 'view mode')
  disableEditing() async {
    await javascriptExecutor.setInputEnabled(false);
  }
}
