import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Para manejar las fechas
import 'dart:math'; // Para generar colores aleatorios

class ChartsPage extends StatefulWidget {
  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  List<BarChartGroupData> _categoryBarData = [];
  List<BarChartGroupData> _subCategoryBarData = [];
  List<PieChartSectionData> _categoryPieData = [];
  List<PieChartSectionData> _subCategoryPieData = [];

  DateTimeRange? _selectedDateRange;
  bool _hasData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({DateTimeRange? dateRange}) async {
    QuerySnapshot expensesSnapshot = await FirebaseFirestore.instance.collection('expenses').get();

    Map<String, double> categoryTotals = {};
    Map<String, double> subCategoryTotals = {};

    for (var doc in expensesSnapshot.docs) {
      String category = doc['category'];
      String subCategory = doc['subcategory'];
      double amount = doc['amount'];
      DateTime date = (doc['date'] as Timestamp).toDate();

      // Filtrar por rango de fechas
      if (dateRange != null) {
        if (date.isBefore(dateRange.start) || date.isAfter(dateRange.end)) {
          continue;
        }
      }

      categoryTotals.update(category, (value) => value + amount, ifAbsent: () => amount);
      subCategoryTotals.update(subCategory, (value) => value + amount, ifAbsent: () => amount);
    }

    setState(() {
      _categoryBarData = categoryTotals.entries
          .map((e) => BarChartGroupData(
        x: e.key.hashCode,
        barRods: [
          BarChartRodData(
            toY: e.value,
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.zero,
            rodStackItems: [],
            // Agregando los valores de las barras sin mostrar los números encima
            backDrawRodData: BackgroundBarChartRodData(show: false),
          )
        ],
      ))
          .toList();
      _subCategoryBarData = subCategoryTotals.entries
          .map((e) => BarChartGroupData(
        x: e.key.hashCode,
        barRods: [
          BarChartRodData(
            toY: e.value,
            color: Colors.green,
            width: 20,
            borderRadius: BorderRadius.zero,
            rodStackItems: [],
            // Agregando los valores de las barras sin mostrar los números encima
            backDrawRodData: BackgroundBarChartRodData(show: false),
          )
        ],
      ))
          .toList();
      _categoryPieData = categoryTotals.entries
          .map((e) => PieChartSectionData(value: e.value, title: e.key, color: _getRandomColor()))
          .toList();
      _subCategoryPieData = subCategoryTotals.entries
          .map((e) => PieChartSectionData(value: e.value, title: e.key, color: _getRandomColor()))
          .toList();

      _hasData = categoryTotals.isNotEmpty || subCategoryTotals.isNotEmpty;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _loadData(dateRange: picked);
    }
  }

  Color _getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gráficas de Gastos",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.date_range, color: Colors.white),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_selectedDateRange != null)
                Text(
                  'Rango de fechas seleccionado: ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              if (!_hasData)
                Text(
                  'No hay registros en esas fechas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              if (_hasData) ...[
                Text("Gastos por Categoría", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 400, child: _buildBarChart(_categoryBarData)),
                SizedBox(height: 20),
                Text("Gastos por Subcategoría", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 400, child: _buildBarChart(_subCategoryBarData)),
                SizedBox(height: 20),
                Text("Gastos por Categoría (Pastel)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 600, child: _buildPieChart(_categoryPieData)),
                SizedBox(height: 20),
                Text("Gastos por Subcategoría (Pastel)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 600, child: _buildPieChart(_subCategoryPieData)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<BarChartGroupData> barData) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: barData,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10, // Tamaño de letra más pequeño
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Quitar números del eje X
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Quitar números del eje superior
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Quitar números del eje derecho
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(List<PieChartSectionData> pieData) {
    return PieChart(
      PieChartData(
        sections: pieData,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
