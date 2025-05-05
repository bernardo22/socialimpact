// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CustomListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final String? trailingText;

  const CustomListItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.onDelete,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        onTap: onTap,
        trailing: (onTap != null || onDelete != null)
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onTap != null)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: onTap,
                    ),
                  if (onDelete != null)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (trailingText != null)
                          Text(
                            trailingText!,
                            style: const TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          constraints: const BoxConstraints(maxHeight: 24), 
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _showDeleteConfirmationDialog(context);
                          },
                        ),
                      ],
                    ),
                ],
              )
            : null,
      ),
    );
  }

  // Delete Confirmation Dialog**
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirmar Exclusão"),
          content: const Text("Tem certeza de que deseja excluir este item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onDelete!();
              },
              child: const Text("Excluir", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}