import 'package:flutter/material.dart';
import 'package:gastosdecimouno/Pages/CategoryList.dart';
import 'package:gastosdecimouno/Pages/GastosList.dart';
import 'package:gastosdecimouno/Pages/PresupuestoList.dart';
import 'package:gastosdecimouno/Pages/ChartsPage.dart'; // Importa ChartsPage

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Inicio",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Container(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: Text(
                  'Menú',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.category, color: Colors.deepPurple),
                title: Text(
                  'Categorías',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CategoryList()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.attach_money, color: Colors.deepPurple),
                title: Text(
                  'Gastos',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExpenseList()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.money_off, color: Colors.deepPurple),
                title: Text(
                  'Presupuestos',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BudgetList()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.pie_chart, color: Colors.deepPurple),
                title: Text(
                  'Gráficas',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChartsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Bienvenido c:",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Explora las categorías desde el menú :D.",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
