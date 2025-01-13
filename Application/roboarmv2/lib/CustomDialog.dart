import 'package:flutter/material.dart';
import 'colors.dart';
class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final Function(BuildContext context)? onOkPressed;

  CustomDialog({required this.title, required this.content, this.onOkPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 66.0,
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          margin: EdgeInsets.only(top: 40.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0.0, 10.0),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                  color: secondryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16.0,
                  color: secondryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onOkPressed != null) {
                      onOkPressed!(context);
                    }
                  },
                  child: Text('OK', style: TextStyle(color: secondryColor),),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16.0,
          right: 16.0,
          child: CircleAvatar(
            backgroundColor: primaryColor,
            radius: 40.0,
            child: Icon(
              Icons.info,
              color: Colors.white,
              size: 50.0,
            ),
          ),
        ),
      ],
    );
  }
}
