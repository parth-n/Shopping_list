import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});
  @override
  State<NewItemScreen> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItemScreen> {
  final _formkey = GlobalKey<FormState>();

  void _saveItem() {
    _formkey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: _formkey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(label: Text("Name")),
                  validator: (value) {
                    if (value == null || //if invalid
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Must be between 1 and 50 charachters';
                    }
                    return null; // if valid.
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                          decoration:
                              const InputDecoration(label: Text('Quantity')),
                          keyboardType: TextInputType.number,
                          initialValue: '1',
                          validator: (value) {
                            if (value == null || //if invalid
                                value.isEmpty ||
                                int.tryParse(value) == null ||
                                int.tryParse(value)! <= 0) {
                              return 'Invalid quantity';
                            }
                            return null; // if valid.
                          }),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: category.value.color,
                              ),
                              const SizedBox(width: 6),
                              Text(category.value.title)
                            ]),
                          ),
                      ], onChanged: (value) {}),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          _formkey.currentState!.reset();
                        },
                        child: const Text('Reset')),
                    ElevatedButton(
                        onPressed: _saveItem, child: const Text('Add Item'))
                  ],
                )
              ],
            )),
      ),
    );
  }
}
