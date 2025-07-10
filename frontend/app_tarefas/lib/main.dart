import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(AppTarefas());

class AppTarefas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarefas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: TarefaForm(),
    );
  }
}

class TarefaForm extends StatefulWidget {
  @override
  State<TarefaForm> createState() => _TarefaFormState();
}

class _TarefaFormState extends State<TarefaForm> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  Future<void> enviarTarefa(String descricao) async {
    if (descricao.trim().isEmpty) return;

    final url = Uri.parse('https://task-rn43.onrender.com/tarefas');
    setState(() => _loading = true);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'descricao': descricao}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _controller.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarefa enviada com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar tarefa')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void abrirListaTarefas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ListaTarefas()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nova Tarefa'), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth;

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Container(
              width: maxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Descrição da tarefa',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.task_alt),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: _loading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(Icons.send),
                          label: Text('Enviar'),
                          onPressed:
                              _loading ? null : () => enviarTarefa(_controller.text),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          padding:
                              EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(Icons.list_alt),
                        label: Text('Ver Tarefas'),
                        onPressed: abrirListaTarefas,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ListaTarefas extends StatefulWidget {
  @override
  State<ListaTarefas> createState() => _ListaTarefasState();
}

class _ListaTarefasState extends State<ListaTarefas> {
  List<dynamic> tarefas = [];
  bool _loading = true;

  Future<void> carregarTarefas() async {
    final url = Uri.parse('https://task-rn43.onrender.com/tarefas');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          tarefas = jsonDecode(utf8.decode(response.bodyBytes)).reversed.toList();
          _loading = false;
        });
      } else {
        throw Exception('Erro ao carregar tarefas');
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Tarefas'), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 700 ? 700 : constraints.maxWidth;
          double horizontalPadding = constraints.maxWidth > 700 ? 24 : 12;

          if (_loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (tarefas.isEmpty) {
            return Center(child: Text('Nenhuma tarefa encontrada.'));
          }

          return Center(
            child: Container(
              width: maxWidth,
              padding:
                  EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
              child: ListView.separated(
                itemCount: tarefas.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tarefa = tarefas[index];
                  final descricao = tarefa['descricao'] ?? '';
                  final data = tarefa['data'] ?? '';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(Icons.check_circle_outline,
                          color: Colors.blueAccent, size: 30),
                      title: Text(
                        descricao,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(data),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
