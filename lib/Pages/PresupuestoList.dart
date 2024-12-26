import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastosdecimouno/Pages/PresupuestoForm.dart';

class BudgetList extends StatefulWidget {
  @override
  _BudgetListState createState() => _BudgetListState();
}

class _BudgetListState extends State<BudgetList> {
  final CollectionReference _budgetsCollection = FirebaseFirestore.instance.collection('budgets');

  void _showDeleteConfirmationDialog(BuildContext context, String budgetId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar este presupuesto?'),
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
                await _budgetsCollection.doc(budgetId).delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditConfirmationDialog(BuildContext context, String budgetId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar edición'),
          content: Text('¿Quieres editar este presupuesto?'),
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
                    builder: (context) => BudgetForm(budgetId: budgetId),
                  ),
                );
              },
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
        title: Text(
          "Lista de Presupuestos",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _budgetsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final budgets = snapshot.data!.docs;
          if (budgets.isEmpty) {
            return Center(child: Text("No hay presupuestos registrados."));
          }

          return ListView.builder(
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.deepPurple[50],
                child: ListTile(
                  title: Text(
                    "Monto: \$${budget['amount']}",
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
                        "Desde: ${budget['startDate'].toDate().toString().split(' ')[0]}",
                        style: TextStyle(color: Colors.deepPurple[700]),
                      ),
                      Text(
                        "Hasta: ${budget['endDate'].toDate().toString().split(' ')[0]}",
                        style: TextStyle(color: Colors.deepPurple[700]),
                      ),
                      Text(
                        "Categoría: ${budget['category']}",
                        style: TextStyle(color: Colors.deepPurple[700]),
                      ),
                    ],
                  ),
                  tileColor: Colors.deepPurple[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () {
                    _showEditConfirmationDialog(context, budget.id);
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, budget.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BudgetForm(budgetId: null)),
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
