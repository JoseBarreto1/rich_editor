import 'package:flutter/material.dart';
import 'package:rich_editor_gg/rich_editor.dart';

void main() {
  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BasicDemo(),
    );
  }
}

class BasicDemo extends StatelessWidget {
  const BasicDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey<RichEditorState> keyEditor = GlobalKey();
    return Scaffold(
      appBar: AppBar(
        title: Text('Basic Demo'),
        actions: [
          PopupMenuButton(
            child: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: null,
              disabledColor: Colors.white,
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('Get HTML'),
                  value: 0,
                ),
                PopupMenuItem(
                  child: Text('Clear content'),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Text('Hide keyboard'),
                  value: 2,
                ),
                PopupMenuItem(
                  child: Text('Show Keyboard'),
                  value: 3,
                ),
              ];
            },
            onSelected: (val) async {
              switch (val) {
                case 0:
                  //String? html = await keyEditor.currentState?.getHtml();
                  //print(html);
                  break;
                case 1:
                  await keyEditor.currentState?.clear();
                  break;
                case 2:
                  await keyEditor.currentState?.unFocus();
                  break;
                case 3:
                  await keyEditor.currentState?.focus();
                  break;
              }
            },
          ),
        ],
      ),
      body: RichEditor(
        key: keyEditor,
        value: "Hello, This is a rich text Editor for Flutter.",
        // initial HTML data
        editorOptions: RichEditorOptions(
          enableVideo: false,
          backgroundColor: Colors.grey, // Editor's bg color
          baseTextColor: Colors.black,
          // editor padding
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          // font name
          baseFontFamily: 'sans-serif',
          // Position of the editing bar (BarPosition.TOP or BarPosition.BOTTOM)
          barPosition: BarPosition.TOP,
        ),
        // You can return a Link (maybe you need to upload the image to your
        // storage before displaying in the editor or you can also use base64
        // getImageUrl: (image) {
        //   //String link = 'https://avatars.githubusercontent.com/u/24323581?v=4';
        //   String base64 = base64Encode(image.readAsBytesSync());
        //   String base64String = 'data:image/png;base64, $base64';
        //   return base64String;
        // },
        // getVideoUrl: (video) {
        //   String link = 'https://file-examples-com.github.io/uploads/2017/'
        //       '04/file_example_MP4_480_1_5MG.mp4';
        //   return link;
        // },
      ),
    );
  }
}
