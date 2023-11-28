import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Disciplina {
  int id;
  String nome;
  int cargaHoraria;
  String dificuldade;
  String recursos;
  DateTime prazo;
  List<String> metas;
  String prioridade;

  Disciplina({
    required this.id,
    required this.nome,
    required this.cargaHoraria,
    required this.dificuldade,
    required this.recursos,
    required this.prazo,
    required this.metas,
    required this.prioridade,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cargaHoraria': cargaHoraria,
      'dificuldade': dificuldade,
      'recursos': recursos,
      'prazo': '${prazo.year}-${prazo.month}-${prazo.day}',
      'metas': metas,
      'prioridade': prioridade,
    };
  }

  factory Disciplina.fromJson(Map<String, dynamic> json) {
    return Disciplina(
      id: json['id'],
      nome: json['nome'],
      cargaHoraria: json['cargaHoraria'],
      dificuldade: json['dificuldade'],
      recursos: json['recursos'],
      prazo: DateTime.parse(json['prazo']),
      metas: (json['metas'] as String).split(','),
      prioridade: json['prioridade'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plano de Estudo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'Plano de Estudo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Disciplina> disciplinas = [];

  @override
  void initState() {
    super.initState();
    _fetchDisciplinas();
  }

  Future<void> _fetchDisciplinas() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/disciplinas/list'));
      if (response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Disciplina> fetchedDisciplinas =
            data.map((disciplina) => Disciplina.fromJson(disciplina)).toList();
        setState(() {
          disciplinas = fetchedDisciplinas;
        });
      } else {}
    } catch (e) {
      //
    }
  }

  Future<void> _deleteDisciplina(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/disciplinas/$id'),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disciplina excluída com sucesso.'),
          ),
        );
        _fetchDisciplinas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Erro ao excluir a disciplina: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir a disciplina: $e'),
        ),
      );
    }
  }

  Future<void> _editDisciplina(Disciplina disciplina) async {
    final TextEditingController _nomeController = TextEditingController();
    final TextEditingController _cargaHorariaController =
        TextEditingController();
    final TextEditingController _recursosController = TextEditingController();
    final TextEditingController _prazoController = TextEditingController();
    final TextEditingController _metasController = TextEditingController();
    String _dificuldadeSelecionada = disciplina.dificuldade;
    String _prioridadeSelecionada = disciplina.prioridade;
    DateTime _prazo = disciplina.prazo;

    _nomeController.text = disciplina.nome;
    _cargaHorariaController.text = disciplina.cargaHoraria.toString();
    _recursosController.text = disciplina.recursos;
    _prazoController.text = '${_prazo.year}-${_prazo.month}-${_prazo.day}';
    _metasController.text = disciplina.metas.join(',');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Disciplina'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nome:'),
                TextField(
                  controller: _nomeController,
                ),
                const SizedBox(height: 16),
                Text('Carga Horária:'),
                TextField(
                  controller: _cargaHorariaController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Text('Dificuldade:'),
                DropdownButton<String>(
                  value: _dificuldadeSelecionada,
                  onChanged: (String? newValue) {
                    _dificuldadeSelecionada = newValue!;
                  },
                  items: <String>['baixa', 'média', 'alta']
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text('Recursos:'),
                TextField(
                  controller: _recursosController,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Prazo:'),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _prazo,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );

                        if (pickedDate != null && pickedDate != _prazo) {
                          setState(() {
                            _prazo = pickedDate;
                            _prazoController.text =
                                '${_prazo.year}-${_prazo.month}-${_prazo.day}';
                          });
                        }
                      },
                      child: const Text('Selecionar Data'),
                    ),
                    const SizedBox(width: 8),
                    Text(_prazoController.text),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Metas (separadas por vírgula):'),
                TextField(
                  controller: _metasController,
                ),
                const SizedBox(height: 16),
                Text('Prioridade:'),
                DropdownButton<String>(
                  value: _prioridadeSelecionada,
                  onChanged: (String? newValue) {
                    _prioridadeSelecionada = newValue!;
                  },
                  items: <String>['baixa', 'média', 'alta']
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final updatedDisciplina = Disciplina(
                    id: disciplina.id,
                    nome: _nomeController.text,
                    cargaHoraria:
                        int.tryParse(_cargaHorariaController.text) ?? 0,
                    dificuldade: _dificuldadeSelecionada,
                    recursos: _recursosController.text,
                    prazo: _prazo,
                    metas: _metasController.text.split(','),
                    prioridade: _prioridadeSelecionada,
                  );

                  final response = await http.patch(
                    Uri.parse(
                        'http://localhost:3000/disciplinas/${disciplina.id}'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(updatedDisciplina.toJson()),
                  );

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Disciplina atualizada com sucesso.'),
                      ),
                    );
                    _fetchDisciplinas();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Erro ao atualizar a disciplina: ${response.statusCode}'),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao atualizar a disciplina: $e'),
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateDisciplinaPage()),
          );
        },
        tooltip: 'Adicionar Disciplina',
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: disciplinas.length,
        itemBuilder: (context, index) {
          final disciplina = disciplinas[index];
          return ListTile(
            title: Text(disciplina.nome),
            subtitle: Text('Carga Horária: ${disciplina.cargaHoraria}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editDisciplina(disciplina),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteDisciplina(disciplina.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CreateDisciplinaPage extends StatefulWidget {
  const CreateDisciplinaPage({Key? key}) : super(key: key);

  @override
  _CreateDisciplinaPageState createState() => _CreateDisciplinaPageState();
}

class _CreateDisciplinaPageState extends State<CreateDisciplinaPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cargaHorariaController = TextEditingController();
  final TextEditingController _recursosController = TextEditingController();
  final TextEditingController _prazoController = TextEditingController();
  final TextEditingController _metasController = TextEditingController();
  String _dificuldadeSelecionada = 'baixa';
  String _prioridadeSelecionada = 'baixa';
  late DateTime _prazo;

  @override
  void initState() {
    super.initState();
    _prazo = DateTime.now();
    _prazoController.text = '${_prazo.year}-${_prazo.month}-${_prazo.day}';
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _prazo) {
      setState(() {
        _prazo = pickedDate;
        _prazoController.text = '${_prazo.year}-${_prazo.month}-${_prazo.day}';
      });
    }
  }

  void _adicionarDisciplina() async {
    if (_nomeController.text.isEmpty ||
        _cargaHorariaController.text.isEmpty ||
        _recursosController.text.isEmpty ||
        _prazoController.text.isEmpty ||
        _metasController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os campos são obrigatórios.'),
        ),
      );
    } else {
      final disciplina = Disciplina(
        id: 0,
        nome: _nomeController.text,
        cargaHoraria: int.tryParse(_cargaHorariaController.text) ?? 0,
        dificuldade: _dificuldadeSelecionada,
        recursos: _recursosController.text,
        prazo: _prazo,
        metas: _metasController.text.split(','),
        prioridade: _prioridadeSelecionada,
      );

      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/disciplinas/add'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(disciplina.toJson()),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Disciplina criada com sucesso.'),
            ),
          );
          _limparCampos();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Erro ao criar a disciplina: ${response.statusCode}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar a disciplina: $e'),
          ),
        );
      }
    }
  }

  void _limparCampos() {
    _nomeController.clear();
    _cargaHorariaController.clear();
    _recursosController.clear();
    _prazoController.clear();
    _metasController.clear();
    setState(() {
      _dificuldadeSelecionada = 'baixa';
      _prioridadeSelecionada = 'baixa';
      _prazo = DateTime.now();
      _prazoController.text = '${_prazo.year}-${_prazo.month}-${_prazo.day}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Disciplina'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nome:'),
              TextField(
                controller: _nomeController,
              ),
              const SizedBox(height: 16),
              const Text('Carga Horária:'),
              TextField(
                controller: _cargaHorariaController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text('Dificuldade:'),
              DropdownButton<String>(
                value: _dificuldadeSelecionada,
                onChanged: (String? newValue) {
                  setState(() {
                    _dificuldadeSelecionada = newValue!;
                  });
                },
                items: <String>['baixa', 'média', 'alta']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Text('Recursos:'),
              TextField(
                controller: _recursosController,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Prazo:'),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectDate,
                    child: const Text('Selecionar Data'),
                  ),
                  const SizedBox(width: 8),
                  Text(_prazoController.text),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Metas (separadas por vírgula):'),
              TextField(
                controller: _metasController,
              ),
              const SizedBox(height: 16),
              const Text('Prioridade:'),
              DropdownButton<String>(
                value: _prioridadeSelecionada,
                onChanged: (String? newValue) {
                  setState(() {
                    _prioridadeSelecionada = newValue!;
                  });
                },
                items: <String>['baixa', 'média', 'alta']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _adicionarDisciplina,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
