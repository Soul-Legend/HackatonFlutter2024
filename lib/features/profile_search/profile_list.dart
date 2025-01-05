import 'package:confirma_id/components/shared/styles.dart';
import 'package:flutter/material.dart';

class Profile extends ListTile {
  final String name;
  final String uniqueID;
  final String registerNumber;
  final String? imageUrl;
  final VoidCallback onTapOveride;

  const Profile({
    required this.name,
    required this.uniqueID,
    required this.registerNumber,
    required this.imageUrl,
    required this.onTapOveride,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula o raio do avatar com base na largura do widget pai
        final double avatarRadius =
            constraints.maxWidth * 0.1; // 10% da largura do widget pai

        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color: buttonColor, // Cor de fundo do container
            borderRadius:
                BorderRadius.circular(12.0), // Raio das bordas arredondadas
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), // Sombra deslocada para baixo
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              name,
              style: commomTextStyle,
            ),
            subtitle: Text(
              registerNumber,
              style: subTextStyle,
            ),
            leading: CircleAvatar(
              backgroundImage:
                  imageUrl != null ? NetworkImage(imageUrl!) : null,
              radius: avatarRadius,
              child: imageUrl == null || imageUrl == ''
                  ? Icon(Icons.person, size: avatarRadius)
                  : null,
            ),
            onTap: onTapOveride,
          ),
        );
      },
    );
  }
}

class ProfileList extends StatelessWidget {
  final List<Profile> profiles;

  const ProfileList({required this.profiles});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        return profiles[index];
      },
    );
  }
}
