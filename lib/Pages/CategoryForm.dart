import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryForm extends StatefulWidget {
  final String? uid;
  final String? name;

  CategoryForm({this.uid, this.name});

  @override
  _CategoryFormState createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.name != null) {
      _categoryController.text = widget.name!; // Rellenar el nombre
    }
  }

  Future<void> createOrUpdateCategory() async {
    if (widget.uid == null) {
      // Crear nueva categoría
      await FirebaseFirestore.instance.collection('categories').add({
        'name': _categoryController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Actualizar categoría existente
      await FirebaseFirestore.instance.collection('categories').doc(widget.uid).update({
        'name': _categoryController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteCategory() async {
    if (widget.uid != null) {
      await FirebaseFirestore.instance.collection('categories').doc(widget.uid).delete();
    }
  }

  // Función para mostrar el diálogo de confirmación
  Future<void> _confirmDelete(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Alerta!'),
          content: Text('¿Estás seguro de que deseas eliminar esta categoría?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo sin eliminar
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await deleteCategory(); // Eliminar la categoría
                Navigator.of(context).pop(); // Cerrar el diálogo
                Navigator.of(context).pop(); // Regresar a la pantalla anterior
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.deepPurple[50],
      title: Text(
        widget.uid == null ? 'Registrar Categoría' : 'Actualizar Categoría',
        style: TextStyle(
          color: Colors.deepPurple[800],
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: TextField(
        controller: _categoryController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: 'Nombre',
          labelStyle: TextStyle(color: Colors.deepPurple[700]),
          filled: true,
          fillColor: Colors.deepPurple[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(color: Colors.deepPurple[900]),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await createOrUpdateCategory();
            Navigator.pop(context);
          },
          child: Text('Aceptar', style: TextStyle(color: Colors.green)),
          style: TextButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white, // Usar foregroundColor en lugar de primary
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ),
        if (widget.uid != null) // Mostrar botón de eliminar solo si es una edición
          TextButton(
            onPressed: () {
              _confirmDelete(context); // Llamar a la alerta de confirmación
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // Usar foregroundColor en lugar de primary
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
      ],
    );
  }
}
