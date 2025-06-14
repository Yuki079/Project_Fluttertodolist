import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// =====================
// MODEL
// =====================
class Task {
  final int? id;
  final String title;
  final String priority;
  final String dueDate;
  final bool isDone;

  Task({
    this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    this.isDone = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      priority: json['priority'],
      dueDate: json['due_date'],
      isDone: json['is_done'].toString() == '1' || json['is_done'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "priority": priority,
      "due_date": dueDate,
      "is_done": isDone ? 1 : 0,
    };
  }
}

// =====================
// API SERVICE
// =====================
class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/tasks";

  Future<List<Task>> getTasks() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mengambil tugas");
    }
  }

  Future<bool> addTask(Task task) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> updateTask(Task task) async {
    if (task.id == null) return false;
    final response = await http.put(
      Uri.parse('$baseUrl/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }
}

// =====================
// UI
// =====================
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: TaskPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final ApiService api = ApiService();
  List<Task> tasks = [];
  List<Task> filteredTasks = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() => isLoading = true);
    try {
      tasks = await api.getTasks();
    } catch (e) {
      tasks = [];
    }
    applySearch(searchQuery);
    setState(() => isLoading = false);
  }

  void applySearch(String query) {
    searchQuery = query;
    List<Task> result = query.isEmpty
        ? tasks
        : tasks
            .where((task) =>
                task.title.toLowerCase().contains(query.toLowerCase()))
            .toList();

    result.sort((a, b) {
      DateTime dateA = DateTime.tryParse(a.dueDate) ?? DateTime(2100);
      DateTime dateB = DateTime.tryParse(b.dueDate) ?? DateTime(2100);
      int compareDate = dateA.compareTo(dateB);
      if (compareDate != 0) return compareDate;
      if (a.isDone && !b.isDone) return 1;
      if (!a.isDone && b.isDone) return -1;
      return 0;
    });

    filteredTasks = result;
    setState(() {});
  }

  Future<void> showTaskForm({Task? task}) async {
    final titleController = TextEditingController(text: task?.title ?? "");
    final dueDateController =
        TextEditingController(text: task?.dueDate ?? "");
    String priority = task?.priority ?? 'low';

    Future<void> pickDueDate(BuildContext context) async {
      DateTime initialDate = task != null
          ? DateTime.tryParse(task.dueDate) ?? DateTime.now()
          : DateTime.now();

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (picked != null) {
        dueDateController.text = picked.toIso8601String().split('T').first;
      }
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task == null ? "Tambah Tugas" : "Edit Tugas"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Judul"),
              ),
              GestureDetector(
                onTap: () => pickDueDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: dueDateController,
                    decoration: InputDecoration(
                      labelText: "Tanggal (YYYY-MM-DD)",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                value: priority,
                items: ["low", "medium", "high"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) priority = value;
                },
                decoration: InputDecoration(labelText: "Prioritas"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty ||
                  dueDateController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Judul & tanggal wajib diisi")));
                return;
              }
              final newTask = Task(
                id: task?.id,
                title: titleController.text,
                priority: priority,
                dueDate: dueDateController.text,
                isDone: task?.isDone ?? false,
              );
              if (task == null) {
                await api.addTask(newTask);
              } else {
                await api.updateTask(newTask);
              }
              Navigator.pop(context);
              await fetchTasks();
              applySearch(searchQuery);
            },
            child: Text(task == null ? "Tambah" : "Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> confirmDelete(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus Tugas"),
        content: Text("Yakin ingin menghapus '${task.title}'?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Batal")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Hapus")),
        ],
      ),
    );
    if (confirm == true) {
      await api.deleteTask(task.id!);
      await fetchTasks();
      applySearch(searchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To-Do List"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: applySearch,
              decoration: InputDecoration(
                hintText: "Cari tugas...",
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchTasks,
                    child: filteredTasks.isEmpty
                        ? Center(child: Text("Tidak ada tugas"))
                        : ListView.builder(
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: ListTile(
                                  leading: IconButton(
                                    icon: Icon(task.isDone
                                        ? Icons.check_circle
                                        : Icons.circle_outlined),
                                    color:
                                        task.isDone ? Colors.green : Colors.grey,
                                    onPressed: () async {
                                      await api.updateTask(Task(
                                        id: task.id,
                                        title: task.title,
                                        priority: task.priority,
                                        dueDate: task.dueDate,
                                        isDone: !task.isDone,
                                      ));
                                      await fetchTasks();
                                      applySearch(searchQuery);
                                    },
                                  ),
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      decoration: task.isDone
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Prioritas: ${task.priority}"),
                                      Text("Deadline: ${task.dueDate}"),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == "edit") {
                                        showTaskForm(task: task);
                                      } else if (value == "hapus") {
                                        confirmDelete(task);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                          value: "edit", child: Text("Edit")),
                                      PopupMenuItem(
                                          value: "hapus", child: Text("Hapus")),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTaskForm(),
        icon: Icon(Icons.add),
        label: Text("Tambah"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }
}
