import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastosdecimouno/Pages/SubcategoryForm.dart';
import 'package:gastosdecimouno/Pages/SubcategoryList.dart'; // Asegúrate de importar SubcategoryList

class CategoryList extends StatefulWidget {
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Categorías",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('categories').orderBy('createdAt').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ));
            }

            final categories = snapshot.data!.docs;

            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                var category = categories[index];
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.deepPurple[50],
                  child: ListTile(
                    title: Text(
                      category["name"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.deepPurple[900],
                      ),
                    ),
                    tileColor: Colors.deepPurple[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () async {
                      // Redirigir a la lista de subcategorías al tocar la categoría
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubcategoryList(categoryId: category.id), // Cambiar aquí
                        ),
                      );
                      setState(() {});
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.add, color: Colors.green),
                      onPressed: () {
                        // Navegar a SubcategoryForm para crear una nueva subcategoría
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubcategoryForm(categoryId: category.id),
                          ),
                        ).then((_) {
                          // Redirigir a la lista de subcategorías después de crear
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubcategoryList(categoryId: category.id),
                            ),
                          );
                        });
                      },
                    ),
                  ),
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
            MaterialPageRoute(builder: (context) => SubcategoryForm(categoryId: "")), // Si necesitas agregar subcategoría sin categoría, ajusta aquí
          ).then((_) {
            setState(() {});
          });
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30, // Cambia el tamaño del icono
        ), // Icono de "crear"
      ),
    );
  }
}
