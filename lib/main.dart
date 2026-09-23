import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(const PhonebookApp());
}

class PhonebookApp extends StatelessWidget {
  const PhonebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Apex Phonebook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PHONEBOOK'),
    );
  }
}

class ContactModel {
  String name;
  String number;
  String category;

  ContactModel({required this.name, required this.number, required this.category});

  Map<String, dynamic> toJson() => {
        'name': name,
        'number': number,
        'status': category,
      };

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        name: json['name'] ?? '',
        number: json['number'] ?? '',
        category: json['status'] ?? 'General',
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _catController = TextEditingController();

  List<ContactModel> dataList = [];
  String selectedCategoryFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/file.json');
      List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        dataList = jsonList.map((item) => ContactModel.fromJson(item)).toList();
      });
    } catch (e) {
      // Fallback data if asset isn't found locally yet
      setState(() {
        dataList = [
          ContactModel(name: 'John Doe', number: '123-456-7890', category: 'Friends'),
          ContactModel(name: 'Jane Smith', number: '987-654-3210', category: 'Family'),
        ];
      });
    }
  }

  void _addContact() {
    if (_nameController.text.isEmpty || _numberController.text.isEmpty) return;

    setState(() {
      dataList.add(ContactModel(
        name: _nameController.text,
        number: _numberController.text,
        category: _catController.text.isEmpty ? 'Friends' : _catController.text,
      ));
    });

    _nameController.clear();
    _numberController.clear();
    _catController.clear();

    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact added successfully!')),
    );
  }

  void _showAddPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Contact'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _numberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Enter Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _catController,
                  decoration: const InputDecoration(
                    labelText: 'Category (Friend, Family, etc.)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addContact,
              child: const Text('Save Contact'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = selectedCategoryFilter == 'All'
        ? dataList
        : dataList.where((item) => item.category.toLowerCase() == selectedCategoryFilter.toLowerCase()).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.contacts),
            const SizedBox(width: 8),
            Text(widget.title),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Contact',
            onPressed: () => _showAddPopup(context),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar Menu
          Container(
            width: 240,
            color: Colors.black26,
            child: Column(
              children: [
                const SizedBox(height: 12),
                SidebarButton(
                  title: 'All Contacts',
                  icon: Icons.all_inclusive,
                  isSelected: selectedCategoryFilter == 'All',
                  onTap: () => setState(() => selectedCategoryFilter = 'All'),
                ),
                SidebarButton(
                  title: 'Friends',
                  icon: Icons.group,
                  isSelected: selectedCategoryFilter == 'Friends',
                  onTap: () => setState(() => selectedCategoryFilter = 'Friends'),
                ),
                SidebarButton(
                  title: 'Family',
                  icon: Icons.family_restroom,
                  isSelected: selectedCategoryFilter == 'Family',
                  onTap: () => setState(() => selectedCategoryFilter = 'Family'),
                ),
                SidebarButton(
                  title: 'Colleagues',
                  icon: Icons.work,
                  isSelected: selectedCategoryFilter == 'Colleagues',
                  onTap: () => setState(() => selectedCategoryFilter = 'Colleagues'),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Main Data View
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: filteredList.isEmpty
                  ? const Center(child: Text('No contacts found.'))
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final contact = filteredList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?'),
                            ),
                            title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${contact.number} • Status: ${contact.category}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  dataList.remove(contact);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarButton({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.deepPurpleAccent : Colors.white70),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.0,
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}