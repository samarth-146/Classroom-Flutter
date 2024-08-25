import 'package:flutter/material.dart';
import './createClass.dart';

class ClassroomApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Classroom App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: ClassesPage(),
    );
  }
}

class ClassesPage extends StatelessWidget {
  final List<Class> classes = [
    Class(name: 'Math 101', teacher: 'Mr. Smith', time: '9:00 AM - 10:00 AM', icon: Icons.calculate),
    Class(name: 'Physics 201', teacher: 'Ms. Johnson', time: '10:30 AM - 11:30 AM', icon: Icons.science),
    Class(name: 'Chemistry 301', teacher: 'Dr. Brown', time: '12:00 PM - 1:00 PM', icon: Icons.egg_outlined),
    Class(name: 'Biology 401', teacher: 'Dr. Kharec', time: '12:00 PM - 1:00 PM', icon: Icons.biotech),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Classes'),
        centerTitle: true,
        backgroundColor: Colors.indigo[600],
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();  // Open the drawer when the icon is pressed
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo[600],
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Handle the tap
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Handle the tap
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                // Handle the tap
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: classes.length,
        itemBuilder: (context, index) {
          return ClassCard(classInfo: classes[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClassCreationPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

class ClassCard extends StatelessWidget {
  final Class classInfo;

  const ClassCard({required this.classInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: Colors.blueAccent.shade100,
      margin: EdgeInsets.all(10.0),
      elevation: 5.0,
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Row(
          children: <Widget>[
            Icon(
              classInfo.icon,
              size: 50.0,
              color: Colors.white,
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    classInfo.name,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Teacher: ${classInfo.teacher}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'Time: ${classInfo.time}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Class {
  final String name;
  final String teacher;
  final String time;
  final IconData icon;

  Class({required this.name, required this.teacher, required this.time, required this.icon});
}