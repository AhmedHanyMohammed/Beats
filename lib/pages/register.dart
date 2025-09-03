import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Register Page'),
      ),
    );
  }
}

// going to use a very similar code here
/*void _handleSave() async{
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedKey == null) {
      _showMissingDialog(
        name.isEmpty && _selectedKey == null
            ? 'Please enter an item name and select a category.'
            : name.isEmpty
                ? 'Please enter an item name.'
                : 'Please select a category.',
      );
      return;
    }
    if(_urlController.text.isNotEmpty){
      final parsed = Uri.tryParse(_urlController.text.trim());
      if(parsed == null || !(parsed.isAbsolute && (parsed.hasScheme && (parsed.scheme == 'http' || parsed.scheme == 'https')))){
        _showMissingDialog('Please enter a valid URL.');
        return;
      }
    }

    final remoteUri = Uri.https(
      'shopping-list-app-eac59-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.post(
        remoteUri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
            'category': _selectedKey!,
            'url': _urlController.text.trim(),
            'quantity': _quantity,
            'isComplete': false,
        }),
      );
      String id = '';
      try {
        final data = json.decode(response.body);
        id = data['name'] ?? '';
      } catch (_) {}
      widget.onAdd(
        GroceryItem(
          id: id,
          name: name,
          category: _selectedKey!,
          quantity: _quantity,
          url: _urlController.text.trim(),
        ),
      );
    } catch (_) {
      widget.onAdd(
        GroceryItem(
          name: name,
          category: _selectedKey!,
          quantity: _quantity,
          url: _urlController.text.trim(),
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }*/