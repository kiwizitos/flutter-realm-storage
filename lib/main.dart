import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';

import 'item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('pt_BR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  var config = Configuration.local([Item.schema]);

  int idGenerator() {
    final now = DateTime.now();
    return now.microsecondsSinceEpoch.toInt();
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String formattedDate(DateTime date) {
    return DateFormat('dd/MMMM/yyyy').add_Hm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    var realm = Realm(config);
    var items = realm.all<Item>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hello"),
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Card(
              child: SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 150,
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: "Nome",
                            ),
                          ),
                        ),
                        Container(
                          width: 100,
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              hintText: "Qtde.",
                            ),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: const ButtonStyle(
                        shape: MaterialStatePropertyAll(
                          CircleBorder(),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          realm.write(() {
                            realm.add(
                              Item(
                                idGenerator(),
                                _nameController.text,
                                int.parse(_quantityController.text),
                                DateTime.now().add(
                                  Duration(
                                    hours: -3,
                                  ),
                                ),
                                false,
                              ),
                            );
                          });
                        });
                      },
                      child: const Icon(Icons.arrow_right),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height - 170,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Dismissible(
                    key: UniqueKey(),
                    background: Card(
                      child: Container(
                        alignment: AlignmentDirectional.centerEnd,
                        color: Colors.redAccent,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        realm.write(() {
                          realm.delete(item);
                        });
                        realm.close();
                      });
                    },
                    child: Card(
                      child: CheckboxListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.name,
                            ),
                            Text(
                              "R\$${((item.quantity) * 5).toString()}.00",
                            ),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formattedDate(
                                item.createdAt,
                              ),
                            ),
                            CircleAvatar(
                              radius: 10,
                              child: Text(
                                item.quantity.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        value: item.isPaid,
                        onChanged: (bool? value) {
                          setState(() {
                            realm.write(() {
                              item.isPaid = value!;
                            });
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
