import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'dart:convert';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    //print('Loading items...');

    final url = Uri.https('shoppinglist-flutter-3efb2-default-rtdb.firebaseio',
        'shopping-list.json');

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _errorCode = 'Failed to fetch data ! Try again after some time.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> getData = json.decode(response.body);
      final List<GroceryItem> loadedItemsList = [];
      for (final entry in getData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == entry.value['category'])
            .value;
        loadedItemsList.add(GroceryItem(
            category: category,
            // category: entry.value['category'],
            id: entry.key,
            name: entry.value['name'],
            quantity: entry.value['quantity']));
      }

      setState(() {
        _groceryItems = loadedItemsList;
        _isLoading = false;
      });
    } catch (error) {
      //print('error caught');
      setState(() {
        _isLoading = false;
        _errorCode = 'Something went wrong ! Try again after some time.';
        // print('after error caught');
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItemScreen()));

    //_loadItems();

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeitem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https(
        'shoppinglist-flutter-3efb2-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Deletion failed, item is restored'),
              duration: Durations.medium4),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('Nothing added yet !'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) => Dismissible(
                onDismissed: (direction) {
                  _removeitem(_groceryItems[index]);
                },
                key: ValueKey(_groceryItems[index].id),
                child: ListTile(
                  title: Text(_groceryItems[index].name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: _groceryItems[index].category.color,
                  ),
                  trailing: Text(_groceryItems[index].quantity.toString()),
                ),
              ));

      if (_errorCode != null) {
        content = Center(
          child: Text(_errorCode!),
        );
      }
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your List'),
          actions: [
            IconButton(
                onPressed: _addItem, icon: const Icon(Icons.add_box_rounded))
          ],
        ),
        body: content);
  }
}
