import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> items = [];
  TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        ...items.map((item) => ListTile(
              title: Text(item['name']),
            )),
      ]),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // dialog to add new item
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Add new item'),
              content: TextField(
                controller: _nameController,
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    // add new item
                    final name = _nameController.text;
                    if (name.isNotEmpty) {
                      _nameController.clear();
                      _addItem(name);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _addItem(String name) {
    setState(() {
      items.add({'name': name, 'id': DateTime.now().millisecondsSinceEpoch});
    });
  }
}
