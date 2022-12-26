import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_book_/constants/global_variables.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class PdfViewScreen extends StatefulWidget {
  const PdfViewScreen({super.key, required this.bookUrl});
  final String bookUrl;

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  // ignore: unused_field
  String _version = 'Unknown';

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: DocumentView(
          onCreated: _onDocumentViewCreated,
        ),
      ),
    );
  }

  Future<void> initPlatformState() async {
    String version;
    try {
      PdftronFlutter.initialize(GlobalVariables.apiKey);
      version = await PdftronFlutter.version;
    } on PlatformException catch (e) {
      Sentry.captureException(e.message, stackTrace: e.stacktrace, hint: 'PDFTron version');
      version = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _version = version;
    });
  }

  void _onDocumentViewCreated(DocumentViewController controller) async {
    Config config = Config();
    config.followSystemDarkMode = false;
    config.disabledElements = [
      Buttons.shareButton,
      Buttons.saveCopyButton,
      Buttons.editPagesButton,
      Buttons.editToolButton,
      Buttons.editAnnotationToolbarButton,
      Buttons.editMenuButton,
      Buttons.viewLayersButton,
    ];

    config.showLeadingNavButton = false;
    config.showQuickNavigationButton = false;
    config.followSystemDarkMode = true;
    config.disabledTools = [Tools.annotationCreateLine, Tools.annotationCreateRectangle];
    config.multiTabEnabled = false;

    controller.openDocument(widget.bookUrl, config: config);
  }
}
