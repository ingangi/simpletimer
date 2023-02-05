import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime _dateTime = DateTime.now();
  int _type = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Add Reminder"),
        content: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Title"),
              validator: (value) {
                if (value!.isEmpty) {
                  // return "Please enter a title";
                }
                return null;
              },
            ),
            ListTile(
              title: Text("Type"),
              trailing: DropdownButton<int>(
                value: _type,
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Text("One-time"),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text("Daily"),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text("Yearly"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Text("Date/Time"),
              onTap: () async {
                final dateTime = await showDatePicker(
                  context: context,
                  initialDate: _dateTime ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (dateTime != null) {
                  setState(() {
                    _dateTime = dateTime;
                  });
                }
              },
              trailing: Text(_dateTime?.toString() ?? ""),
            ),
            const SizedBox(
              height: 16.0,
            ),
            // RaisedButton(
            //   child: Text("Add"),
            //   onPressed: () {
            //     // if (_formKey.currentState.validate()) {
            //     //   final title = _titleController.text;
            //     //   final reminder = Reminder(
            //   },
            // ),
          ]),
        ));
  }
}
