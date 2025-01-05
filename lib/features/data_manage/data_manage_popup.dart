import 'package:flutter/material.dart';

class DataManagePopup extends StatelessWidget {
  final String dataType;
  final String data;

  const DataManagePopup({super.key, required this.dataType, required this.data});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmação de Dados'),
      content: Text('O dado informado está correto?\n\n$dataType: $data'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('Aceitar'),
        ),
      ],
    );
  }
}

Future<bool?> showDataManagePopup(BuildContext context, String dataType, String data) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return DataManagePopup(dataType: dataType, data: data);
    },
  );
}
