import 'package:flutter/material.dart';
import 'package:mobile/bloc/ConfigApp.dart';
import 'package:mobile/screen/terms/policy.dart';

class ServicePolicyPage extends StatefulWidget {
  @override
  _TermsOfServicePageState createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<ServicePolicyPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showAcceptButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _showAcceptButton = true;
      });
    } else {
      setState(() {
        _showAcceptButton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String appName =
        configAppBloc.namaApp.valueWrapper?.value ?? 'Default App';
    return Scaffold(
      appBar: AppBar(
        title: Text('Syarat & Ketentuan'),
        centerTitle: true,
        leading: Container(),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MarkdownDisplayScreen(
                mdFileName: 'term_condition.md',
                appName: appName,
              ),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: _showAcceptButton
          ? SafeArea(
              child: Container(
                padding: EdgeInsets.all(10),
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        Theme.of(context).primaryColor),
                  ),
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }
}
