import "package:flutter/material.dart";

import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadWidget extends StatelessWidget {

	@override
	build(BuildContext context) {
		return Container(
			child : Center(
				child : SpinKitThreeBounce(
					color : Theme.of(context).primaryColor, size: 35
				)
			)
		);
	}
}