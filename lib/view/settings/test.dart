import 'dart:convert';

import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/dom.dart';

class Test extends StatelessWidget {
  Test({Key? key, required this.body}) : super(key: key);

  String body;
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: "https://eduserve.karunya.edu/Online/PasswordReset.aspx",
      javascriptMode: JavascriptMode.unrestricted,
      onProgress: (i) => print(i),
      onWebViewCreated: (webViewController) async {
        _controller = webViewController;

        body += """
            <script type='text/javascript'>
              document.querySelector('#mainContent_TXTSTUDUSERID').value = "urk19cs2017";
              document.querySelector('#mainContent_TXTSTUDDOB').value = "18 May 2002";
              document.querySelector('#mainContent_TXTSTUDEMAIL').value = "hiruthic@karunya.edu.inf";
              document.querySelector('#mainContent_btnStudReset').removeAttribute("onClick");
              document.querySelector('#mainContent_btnStudReset').setAttribute("causesValidation", false);
              document.querySelector('#mainContent_btnStudReset').click();
            </script>
        """;

        await _controller.loadHtmlString(body);
      },
      onPageFinished: (_) async {
        final html = await _controller.runJavascriptReturningResult(
            "new XMLSerializer().serializeToString(document)");

        String htmlDecoded = json.decode(html);

        print(htmlDecoded.contains("alert"));
      },
      debuggingEnabled: true,
    );
  }
}
