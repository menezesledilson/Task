import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(AppTarefas());

class AppTarefas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Tarefas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TarefaForm(),
    );
  }
}

class TarefaForm extends StatefulWidget {
  @override
  _TarefaFormState createState() => _TarefaFormState();
}

class _TarefaFormState extends State<TarefaForm> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  Future<void> enviarTarefa(String descricao) async {
    final url = Uri.parse('https://task-rn43.onrender.com/tarefas');
    setState(() => _loading = true);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'descricao': descricao}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarefa enviada com sucesso!')),
        );
        _controller.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar tarefa')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na requisição: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nova Tarefa')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Descrição da tarefa'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () => enviarTarefa(_controller.text.trim()),
              child: _loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Enviar'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ListaTarefas()),
                );
              },
              child: Text('Listar tarefas'),
            ),
          ],
        ),
      ),
    );
  }
}

class ListaTarefas extends StatefulWidget {
  @override
  _ListaTarefasState createState() => _ListaTarefasState();
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
          tarefas = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        throw Exception('Erro ao carregar tarefas');
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: $e')));
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
      appBar: AppBar(title: Text('Lista de Tarefas')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : tarefas.isEmpty
              ? Center(child: Text('Nenhuma tarefa encontrada.'))
              : ListView.builder(
                  itemCount: tarefas.length,
                  itemBuilder: (context, index) {
                    final tarefa = tarefas[index];
                    return ListTile(
                      title: Text(tarefa['descricao'] ?? ''),
                      subtitle: Text('${tarefa['data'] ?? ''} ${tarefa['hora'] ?? ''}'),
                    );
                  },
                ),
    );
  }
}
