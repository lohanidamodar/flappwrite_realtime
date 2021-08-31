import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlAppwrite Realtime Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> items = [];
  TextEditingController _nameController = TextEditingController();
  RealtimeSubscription? subscription;
  late final Client client;
  final itemsCollection = '61236158b75b6';
  late final Database database;

  @override
  void initState() {
    super.initState();
    client = Client()
            .setEndpoint('https://dlrealtime.appwrite.org/v1') // your endpoint
            .setProject('61236151f0744') //your project id
        ;
    database = Database(client);
    login();
    loadItems();
    subscribe();
  }

  login() async {
    try {
      await Account(client).createAnonymousSession();
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }

  loadItems() async {
    try {
      final res = await database.listDocuments(collectionId: itemsCollection);
      setState(() {
        items = List<Map<String, dynamic>>.from(res.data['documents']);
      });
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }

  void subscribe() {
    final realtime = Realtime(client);

    subscription = realtime.subscribe([
      'collections.$itemsCollection.documents'
    ]); //replace <collectionId> with the ID of your items collection, which can be found in your collection's settings page.

    // listen to changes
    subscription!.stream.listen((data) {
      // data will consist of `event` and a `payload`
      if (data["payload"] != null) {
        switch (data["event"]) {
          case "database.documents.create":
            var item = data['payload'];
            items.add(item);
            setState(() {});
            break;
          case "database.documents.delete":
            var item = data['payload'];
            items.removeWhere((it) => it['\$id'] == item['\$id']);
            setState(() {});
            break;
          default:
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    subscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlAppwrite Realtime Demo'),
      ),
      body: ListView(children: [
        ...items.map((item) => ListTile(
              title: Text(item['name']),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await database.deleteDocument(
                    collectionId: itemsCollection,
                    documentId: item['\$id'],
                  );
                },
              ),
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

  void _addItem(String name) async {
    try {
      await database.createDocument(
          collectionId: itemsCollection,
          data: {'name': name},
          read: ['*'],
          write: ['*']);
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }
}
