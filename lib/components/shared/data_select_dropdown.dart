import 'package:flutter/material.dart';

class DataSelectDropdown extends StatefulWidget {
  final ValueChanged<String?>? onChanged;

  const DataSelectDropdown({this.onChanged});

  @override
  _DataSelectDropdownState createState() => _DataSelectDropdownState();
}

class _DataSelectDropdownState extends State<DataSelectDropdown> {
  String? _selectedValue;

  final Map<String,String> _dropdownItems = {
    'discord_hash' : 'Discord',
    'instagram_hash' : 'Instagram',
    'personal_phone_hash' : 'Telefone Pessoal',
    'prof_phone_hash' : 'Telefone Profissional',
    'personal_email' : 'Email Pessoal',
    'prof_email' : 'Email Profissional',
  };

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedValue,
      hint: const Text('Selecione o tipo de informação'),
      items: _dropdownItems.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedValue = newValue;
        });
        if (widget.onChanged != null) {
          widget.onChanged?.call(newValue);
        }
      },
    );
  }
}
