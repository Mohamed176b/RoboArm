import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roboarmv2/colors.dart';

class HomeFragment extends StatefulWidget {
  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  final List<String> cardTitles = [
    'Project Overview',
    'Automatic Mode',
    'Manual Control Mode',
    'Programmable Mode',
    'LCD Screen & Applications',
  ];

  final List<String> cardSubtitles = [
    'The project involves a robotic arm situated on a stand, facing a conveyor belt carrying goods in small cardboard boxes. The robotic arm has three operating modes:',
    'The arm operates autonomously when boxes pass in front of it on the belt. Upon detecting a box, the arm stops the belt and transfers the box to another location.',
    'A control unit with variable resistors allows independent manual control of the arm\'s movements.',
    'The arm features buttons on a control unit enabling users to record specific movements using variable resistances. These recorded movements can be executed continuously. Additionally, the buttons facilitate mode selection.',
    'An LCD screen displays the selected mode and arm status. Furthermore, the project includes the development of a phone application and desktop program. Both interfaces replicate the control panel\'s functionality, enabling mode selection, movement recording, and manual arm control.',
  ];

  final List<IconData> trailingIcons = [
    CupertinoIcons.info_circle,
    Icons.autorenew,
    Icons.settings,
    Icons.record_voice_over,
    Icons.phone_android,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.all(20),
            child: Image.asset(
              "images/homeVideo.gif",
            ),
          ),
          Container(
            height: 2,
            color: secondryColor,
            margin: EdgeInsets.all(20),
          ),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                cardTitles.length,
                    (index) => _buildCard(
                  title: cardTitles[index],
                  subtitle: cardSubtitles[index],
                  trailingIcon: trailingIcons[index],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData trailingIcon,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: secondryColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 18,
            color: secondryColor,
          ),
        ),
        trailing: Icon(
          trailingIcon,
          color: secondryColor,
        ),
      ),
    );
  }
}
