import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastosdecimouno/Pages/SubcategoryForm.dart';


class SubcategoryList extends StatelessWidget {
  final String categoryId;

  SubcategoryList({required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subcategorías"),
        backgroundColor: Colors.purple[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .collection('subcategories')
            .orderBy('createdAt')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final subcategories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: subcategories.length,
            itemBuilder: (context, index) {
              var subcategory = subcategories[index];

              return ListTile(
                title: Text(subcategory["name"]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.purple),
                      onPressed: () {
                        // Editar subcategoría
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubcategoryForm(
                              categoryId: categoryId,
                              subcategoryId: subcategory.id,
                              subcategoryName: subcategory["name"],
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Confirmar eliminación
                        _confirmDelete(context, categoryId, subcategory.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Aquí puedes agregar más funcionalidades al tocar una subcategoría
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Crear nueva subcategoría
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubcategoryForm(categoryId: categoryId),
            ),
          );
        },
        backgroundColor: Colors.purple[800],
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String categoryId, String subcategoryId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Aviso!', style: TextStyle(color: Colors.purple[900])),
          content: Text('¿Estás seguro de que deseas eliminar esta subcategoría?', style: TextStyle(color: Colors.purple[700])),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar', style: TextStyle(color: Colors.blue[900])),
            ),
            TextButton(
              onPressed: () async {
                // Eliminar subcategoría
                await FirebaseFirestore.instance
                    .collection('categories')
                    .doc(categoryId)
                    .collection('subcategories')
                    .doc(subcategoryId)
                    .delete();
                Navigator.of(context).pop();
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red[800])),
            ),
          ],
        );
      },
    );
  }
}
