import 'package:confirma_id/components/shared/styles.dart';
import 'package:flutter/material.dart';

Widget genericScreenLayout(BuildContext context, String title, Widget header, Widget body) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      backgroundColor: lightBackgroundColor,
    ),
    backgroundColor: lightBackgroundColor,
    body: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          header,
          const SizedBox(
            height: 10,
          ), // Espaço entre a logo/avatar e o container
          Stack(
            children: [
              Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height / 1.5,
                ),
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: darkBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    body,
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
