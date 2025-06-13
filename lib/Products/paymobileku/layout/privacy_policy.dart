import 'package:flutter/material.dart';
import 'package:mobile/Products/paymobileku/layout/register.dart';
import 'package:mobile/Products/paymobileku/layout/terms/policy.dart';

class PrivacyPolicyPage extends StatefulWidget {
  @override
  _TermsOfServicePageState createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<PrivacyPolicyPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
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
                mdFileName: 'privacy_policy.md',
              ),
            SizedBox(height: 50,)
            ],
          ),
        ),
      ),
      bottomNavigationBar: _showAcceptButton
          ? SafeArea(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Tidak Setuju', style: TextStyle(color: Theme.of(context).primaryColor),),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.white),
                          side: MaterialStatePropertyAll(BorderSide(color: Theme.of(context).primaryColor))),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => RegisterUser()
                            )
                          );
                        },
                        child: Text('Setuju & Lanjutkan'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ],
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
