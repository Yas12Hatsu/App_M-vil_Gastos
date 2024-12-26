import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubcategoryForm extends StatefulWidget {
  final String categoryId;
  final String? subcategoryId; // Para edición
  final String? subcategoryName; // Para precargar el nombre en caso de edición

  SubcategoryForm({required this.categoryId, this.subcategoryId, this.subcategoryName});

  @override
  _SubcategoryFormState createState() => _SubcategoryFormState();
}

class _SubcategoryFormState extends State<SubcategoryForm> {
  final TextEditingController _subcategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.subcategoryName != null) {
      _subcategoryController.text = widget.subcategoryName!;
    }
  }

  Future<void> createOrUpdateSubcategory() async {
    if (widget.subcategoryId == null) {
      // Crear una nueva subcategoría
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .collection('subcategories')
          .add({
        'name': _subcategoryController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Editar una subcategoría existente
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .collection('subcategories')
          .doc(widget.subcategoryId)
          .update({
        'name': _subcategoryController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteSubcategory() async {
    if (widget.subcategoryId != null) {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .collection('subcategories')
          .doc(widget.subcategoryId)
          .delete();
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Aviso!', style: TextStyle(color: Colors.blue[900])),
          content: Text('¿Estás seguro de que deseas eliminar esta subcategoría?', style: TextStyle(color: Colors.blue[700])),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar', style: TextStyle(color: Colors.blue[900])),
            ),
            TextButton(
              onPressed: () async {
                await deleteSubcategory();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red[800])),
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
      backgroundColor: Colors.blue[50],
      title: Text(
        widget.subcategoryId == null ? 'Crear Subcategoría' : 'Editar Subcategoría',
        style: TextStyle(
          color: Colors.blue[900],
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: TextField(
        controller: _subcategoryController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: 'Nombre',
          labelStyle: TextStyle(color: Colors.blue[700]),
          filled: true,
          fillColor: Colors.blue[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(color: Colors.blue[900]),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await createOrUpdateSubcategory();
            Navigator.pop(context);
          },
          child: Text('Aceptar'),
          style: TextButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        ),
        if (widget.subcategoryId != null)
          TextButton(
            onPressed: () {
              _confirmDelete(context);
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.blue)),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _subcategoryController.dispose(); // Liberar el controlador cuando el widget se destruye
    super.dispose();
  }
}