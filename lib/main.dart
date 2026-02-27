import 'package:flutter/material.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      debugShowCheckedModeBanner: false,
      home: const NotesHomePage(),
    );
  }
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _notes = [];

  int? _selectedIndex;

  int? _editingIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNote() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      if (_editingIndex != null) {
        _notes[_editingIndex!] = text;
        _editingIndex = null;
        _selectedIndex = null;
      } else {
        _notes.add(text);
      }

      _controller.clear();
    });
  }

  void _deleteSelected() {
    if (_selectedIndex == null) return;

    setState(() {
      if (_editingIndex == _selectedIndex) {
        _editingIndex = null;
        _controller.clear();
      }

      _notes.removeAt(_selectedIndex!);
      _selectedIndex = null;
    });
  }

  void _startEditSelected() {
    if (_selectedIndex == null) return;

    setState(() {
      _editingIndex = _selectedIndex;
      _controller.text = _notes[_selectedIndex!];
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingIndex = null;
      _selectedIndex = null;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = _selectedIndex != null;
    final bool isEditing = _editingIndex != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактирование заметки' : 'Заметки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Введите заметку',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveNote,
                    child: const Text('Сохранить'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: hasSelection ? _startEditSelected : null,
                    child: const Text('Редактировать'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: hasSelection ? _deleteSelected : null,
                    child: const Text('Удалить'),
                  ),
                ),
              ],
            ),

            if (isEditing) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _cancelEdit,
                  child: const Text('Отменить редактирование'),
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            Expanded(
              child: _notes.isEmpty
                  ? const Center(child: Text('Заметок пока нет'))
                  : ListView.builder(
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final bool selected = _selectedIndex == index;

                        return Card(
                          elevation: selected ? 4 : 1,
                          child: ListTile(
                            title: Text(_notes[index]),
                            subtitle: Text('Заметка #${index + 1}'),
                            selected: selected,
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            trailing: selected
                                ? const Icon(Icons.check_circle)
                                : const Icon(Icons.circle_outlined),
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