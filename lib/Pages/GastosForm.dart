import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Para manejar las fechas

class ExpenseForm extends StatefulWidget {
  final String? expenseId;

  ExpenseForm({this.expenseId});

  @override
  _ExpenseFormState createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _notesController = TextEditingController();

  String? _selectedCategory;
  String? _selectedSubcategory;
  List<String> _categories = [];
  Map<String, List<String>> _subcategories = {};

  double _availableBudget = 0.0; // Monto disponible
  bool _exceedsBudget = false; // Indica si el gasto excede el presupuesto

  double _originalAmount = 0.0; // Para almacenar el monto original del gasto al editar

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndSubcategories();
    if (widget.expenseId != null) {
      _loadExpenseData();
    }
  }

  void _fetchCategoriesAndSubcategories() async {
    var categoriesSnapshot = await FirebaseFirestore.instance.collection('categories').get();

    setState(() {
      _categories = categoriesSnapshot.docs.map((doc) => doc['name'] as String).toList();
    });

    for (var categoryDoc in categoriesSnapshot.docs) {
      var subcategoriesSnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryDoc.id)
          .collection('subcategories')
          .get();

      setState(() {
        _subcategories[categoryDoc['name']] = subcategoriesSnapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    }
  }

  void _loadExpenseData() async {
    var expense = await FirebaseFirestore.instance.collection('expenses').doc(widget.expenseId).get();
    var data = expense.data();
    setState(() {
      _selectedCategory = data!['category'];
      _selectedSubcategory = data['subcategory'];
      _amountController.text = data['amount'].toString();
      _dateController.text = DateFormat('yyyy-MM-dd').format(data['date'].toDate());
      _notesController.text = data['notes'];
      _originalAmount = data['amount'];
      _updateAvailableBudget(); // Actualiza el presupuesto disponible al cargar datos
    });
  }

  void _updateAvailableBudget() async {
    if (_selectedCategory != null) {
      // Obtener el presupuesto de la categoría
      var budgetSnapshot = await FirebaseFirestore.instance
          .collection('budgets')
          .where('category', isEqualTo: _selectedCategory)
          .limit(1)
          .get();

      if (budgetSnapshot.docs.isNotEmpty) {
        double budgetAmount = budgetSnapshot.docs.first['amount'];
        // Calcular el total gastado en la categoría
        var expensesSnapshot = await FirebaseFirestore.instance
            .collection('expenses')
            .where('category', isEqualTo: _selectedCategory)
            .get();

        double totalSpent = expensesSnapshot.docs.fold(0.0, (sum, doc) => sum + (doc['amount'] as double));
        // Ajustar el total gastado si se está editando un gasto existente
        if (widget.expenseId != null) {
          totalSpent -= _originalAmount;
        }
        _availableBudget = budgetAmount - totalSpent; // Monto disponible
      } else {
        _availableBudget = 0; // Sin presupuesto
      }
    } else {
      _availableBudget = 0;
    }

    // Verificar si el gasto actual excede el presupuesto
    double amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _exceedsBudget = amount > _availableBudget;

      // Calcular el monto final después de ingresar el gasto
      double finalAmount = _availableBudget - amount; // Monto restante después del gasto
      _availableBudget = finalAmount < 0 ? 0 : finalAmount; // Asegurar que no sea negativo
    });
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      var expenseData = {
        'category': _selectedCategory,
        'subcategory': _selectedSubcategory,
        'amount': double.parse(_amountController.text),
        'date': Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(_dateController.text)),
        'notes': _notesController.text,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (widget.expenseId == null) {
        await FirebaseFirestore.instance.collection('expenses').add(expenseData);
      } else {
        await FirebaseFirestore.instance.collection('expenses').doc(widget.expenseId).update(expenseData);
      }

      Navigator.pop(context);
    }
  }

  _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
      _updateAvailableBudget(); // Actualizar el presupuesto al cambiar la fecha
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseId == null ? 'Crear Gasto' : 'Editar Gasto'),
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
                    _selectedSubcategory = null;
                    _updateAvailableBudget(); // Actualizar presupuesto al seleccionar categoría
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
              if (_selectedCategory != null)
                DropdownButtonFormField<String>(
                  value: _selectedSubcategory,
                  hint: Text('Subcategoría'),
                  items: (_subcategories[_selectedCategory] ?? []).map((subcategory) {
                    return DropdownMenuItem<String>(
                      value: subcategory,
                      child: Text(subcategory),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubcategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor selecciona una subcategoría';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Subcategoría',
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
                onChanged: (value) {
                  _updateAvailableBudget(); // Actualizar al cambiar el monto
                },
              ),
              SizedBox(height: 16.0),
              // Mostrar el monto disponible
              Text(
                'Monto disponible: \$${_availableBudget.toStringAsFixed(2)}',
                style: TextStyle(
                  color: _exceedsBudget ? Colors.red : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Fecha (YYYY-MM-DD)',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una fecha';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Observaciones',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text('Guardar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
