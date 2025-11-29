

import 'package:flutter/material.dart';

class PrecriptionView extends StatefulWidget {
  const PrecriptionView({super.key});

  @override
  State<PrecriptionView> createState() => _PrecriptionViewState();
}
class _PrecriptionViewState extends State<PrecriptionView> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text('Index 0: Home', style: optionStyle),
    Text('Index 1: Business', style: optionStyle),
    Text('Index 2: School', style: optionStyle),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your prescriptions",style: TextStyle(color: Colors.white,),),backgroundColor: Colors.green.withOpacity(0.8),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Center(child: Text("No item added")),

           BottomNavigationBar(items: [
             BottomNavigationBarItem(
                 icon: Center(child:
                 Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1), // Orange tint for "Recent" feel
            shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_a_photo_outlined, color: Colors.green, size: 22),
            ),),
                 label: "Add"
             ),

             BottomNavigationBarItem(
                 icon: Center(child:
           Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1), // Orange tint for "Recent" feel
            shape: BoxShape.circle,
            ),
            child: const Icon(Icons.upload_file_outlined, color: Colors.green, size: 22),),),
            label: "uplaod"),

           ],
             currentIndex: _selectedIndex,
             selectedItemColor: Colors.amber[800],
             onTap: _onItemTapped,
           )
          ],
        ),
      ),

    );
  }
}
