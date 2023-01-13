import 'package:chats_app/utils/const_value.dart';
import 'package:chats_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ShowAllContact extends StatefulWidget {
  const ShowAllContact({Key? key}) : super(key: key);

  @override
  State<ShowAllContact> createState() => _ShowAllContactState();
}

class _ShowAllContactState extends State<ShowAllContact> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstValue.backgroundColor,
      appBar: AppBar(
        backgroundColor: ConstValue.frontColor,
        title: const Text('Contacts'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: fetchContact(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
            if (snapshot.hasData) {
              contacts = snapshot.data!;
              return ListView.builder(
                  itemCount: contacts.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    return contacts[i].phones.isEmpty
                        ? Container()
                        : Card(
                          elevation: ConstValue.btnElevation,
                          child: ListTile(
                            onTap: () {
                              Navigator.pop(context, [
                                contacts[i].displayName,
                                contacts[i].phones[0].number.toString()
                              ]);
                            },
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              contacts[i].displayName,
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,color: Colors.indigo,fontWeight: FontWeight.bold),
                            ),
                            subtitle:
                                Text(contacts[i].phones[0].number.toString(),style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,color: Colors.indigo,fontWeight: FontWeight.bold),),
                          ),
                        );
                  });
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
