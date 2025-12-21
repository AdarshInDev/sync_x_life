import 'package:flutter/material.dart';

class TodoItem {
  String id;
  String title;
  bool done;

  TodoItem({required this.id, required this.title, this.done = false});
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<TodoItem> _items = [];
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addItem(String title) {
    if (title.trim().isEmpty) return;
    setState(() {
      _items.insert(
        0,
        TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title.trim(),
        ),
      );
    });
  }

  void _editItem(TodoItem item, String newTitle) {
    setState(() {
      item.title = newTitle;
    });
  }

  void _toggleDone(TodoItem item) {
    setState(() {
      item.done = !item.done;
    });
  }

  void _removeItem(TodoItem item) {
    setState(() {
      _items.removeWhere((e) => e.id == item.id);
    });
  }

  Future<void> _showAddDialog() async {
    _textController.clear();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Todo'),
        content: TextField(
          controller: _textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter todo title'),
          onSubmitted: (v) {
            Navigator.of(context).pop();
            _addItem(v);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = _textController.text;
              Navigator.of(context).pop();
              _addItem(text);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(TodoItem item) async {
    _textController.text = item.title;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Todo'),
        content: TextField(
          controller: _textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Edit title'),
          onSubmitted: (v) {
            Navigator.of(context).pop();
            _editItem(item, v);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = _textController.text;
              Navigator.of(context).pop();
              _editItem(item, text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No todos yet'),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first todo'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _removeItem(item),
                  child: ListTile(
                    leading: Checkbox(
                      value: item.done,
                      onChanged: (_) => _toggleDone(item),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        decoration: item.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    onTap: () => _showEditDialog(item),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditDialog(item),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
