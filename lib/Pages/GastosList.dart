import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Para manejar las fechas
import 'package:gastosdecimouno/Pages/GastosForm.dart';

class ExpenseList extends StatelessWidget {
  void _showDeleteConfirmationDialog(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar este gasto?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.black)),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('expenses').doc(expenseId).delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditConfirmationDialog(BuildContext context, String expenseId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar edición'),
          content: Text('¿Quieres editar este gasto?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Editar', style: TextStyle(color: Colors.black)),
              onPressed: () async {
                Navigator.of(context).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExpenseForm(expenseId: expenseId),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<double> _getTotalSpentForExpense(String category, String expenseId) async {
    var expensesSnapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .where('category', isEqualTo: category)
        .get();

    double totalSpent = expensesSnapshot.docs.fold(0.0, (sum, doc) {
      if (doc.id != expenseId) {
        return sum + (doc['amount'] as double);
      }
      return sum;
    });

    return totalSpent;
  }

  Future<double> _getBudgetAmount(String category) async {
    var budgetSnapshot = await FirebaseFirestore.instance
        .collection('budgets')
        .where('category', isEqualTo: category)
        .limit(1)
        .get();

    if (budgetSnapshot.docs.isNotEmpty) {
      return budgetSnapshot.docs.first['amount'];
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gastos",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('expenses').orderBy('date').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No hay gastos registrados.'));
            }

            final expenses = snapshot.data!.docs;

            return ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                var expense = expenses[index];
                String category = expense["category"];
                double amount = expense["amount"];

                return FutureBuilder<double>(
                  future: _getBudgetAmount(category),
                  builder: (context, budgetSnapshot) {
                    if (budgetSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    double budgetAmount = budgetSnapshot.data ?? 0;

                    return FutureBuilder<double>(
                      future: _getTotalSpentForExpense(category, expense.id),
                      builder: (context, spentSnapshot) {
                        if (spentSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        double totalSpent = spentSnapshot.data ?? 0;
                        bool budgetExceeded = (totalSpent + amount) > budgetAmount;

                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.deepPurple[50],
                          child: ListTile(
                            title: Text(
                              expense["category"] + " - " + expense["subcategory"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.deepPurple[900],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Monto: \$${amount.toString()} - Fecha: ${DateFormat('yyyy-MM-dd').format(expense["date"].toDate())}\nObservaciones: ${expense["notes"]}",
                                  style: TextStyle(color: Colors.deepPurple[700]),
                                ),
                                if (budgetExceeded)
                                  Text(
                                    'Se ha rebasado el presupuesto',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            tileColor: Colors.deepPurple[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onTap: () {
                              _showEditConfirmationDialog(context, expense.id);
                            },
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmationDialog(context, expense.id);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExpenseForm(expenseId: null)),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
