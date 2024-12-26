import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BudgetForm extends StatefulWidget {
  final String? budgetId;

  BudgetForm({this.budgetId});

  @override
  _BudgetFormState createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    if (widget.budgetId != null) {
      _loadBudgetData();
    }
  }

  void _fetchCategories() async {
    var categoriesSnapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categories = categoriesSnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  void _loadBudgetData() async {
    var budget = await FirebaseFirestore.instance.collection('budgets').doc(widget.budgetId).get();
    var data = budget.data();
    setState(() {
      _selectedCategory = data!['category'];
      _amountController.text = data['amount'].toString();
      _startDateController.text = DateFormat('yyyy-MM-dd').format(data['startDate'].toDate());
      _endDateController.text = DateFormat('yyyy-MM-dd').format(data['endDate'].toDate());
    });
  }

  void _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      var budgetData = {
        'category': _selectedCategory,
        'amount': double.parse(_amountController.text),
        'startDate': Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(_startDateController.text)),
        'endDate': Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(_endDateController.text)),
      };

      if (widget.budgetId == null) {
        await FirebaseFirestore.instance.collection('budgets').add(budgetData);
      } else {
        await FirebaseFirestore.instance.collection('budgets').doc(widget.budgetId).update(budgetData);
      }

      Navigator.pop(context);
    }
  }

  _selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budgetId == null ? 'Crear Presupuesto' : 'Editar Presupuesto' , style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: Text('Categoría'),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona una categoría';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Categoría',
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un monto';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: 'Fecha Inicial (YYYY-MM-DD)',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(_startDateController),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una fecha inicial';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _endDateController,
                decoration: InputDecoration(
                  labelText: 'Fecha Final (YYYY-MM-DD)',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(_endDateController),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una fecha final';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBudget,
                child: Text('Guardar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
