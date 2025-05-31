import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecipeFeedItem extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeFeedItem({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    final author = recipe['author'] as Map<String, dynamic>?;
    final parametersRaw = recipe['parameters'];
    Map<String, dynamic>? parameters;
    if (parametersRaw is String) {
      final decoded = jsonDecode(parametersRaw);
      if (decoded is Map<String, dynamic>) {
        parameters = decoded;
      } else if (decoded is List &&
          decoded.isNotEmpty &&
          decoded[0] is Map<String, dynamic>) {
        parameters = decoded[0];
      }
    } else if (parametersRaw is Map<String, dynamic>) {
      parameters = parametersRaw;
    } else if (parametersRaw is List &&
        parametersRaw.isNotEmpty &&
        parametersRaw[0] is Map<String, dynamic>) {
      parameters = parametersRaw[0];
    } else {
      parameters = null;
    }
    final createdAt = recipe['createdAt'] != null
        ? DateTime.parse(recipe['createdAt'])
        : DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.brown[100]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst kısım - Kullanıcı bilgileri
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.brown[100],
                  backgroundImage: author?['profileImage'] != null
                      ? NetworkImage(author!['profileImage'])
                      : null,
                  child: author?['profileImage'] == null
                      ? const Icon(Icons.person, color: Color(0xFF6F4E37))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author?['username'] ?? 'Anonim',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color(0xFF6F4E37),
                        ),
                      ),
                      Text(
                        DateFormat('d MMMM y, HH:mm').format(createdAt),
                        style: TextStyle(
                          color: Colors.brown[300],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Kahve resmi
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: recipe['imageUrl'] != null
                  ? Image.network(
                      recipe['imageUrl'],
                      width: double.infinity,
                      height: 260,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 260,
                          color: Colors.brown[50],
                          child: const Center(
                            child: Icon(
                              Icons.coffee,
                              size: 64,
                              color: Colors.brown,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 260,
                      color: Colors.brown[50],
                      child: const Center(
                        child: Icon(
                          Icons.coffee,
                          size: 64,
                          color: Colors.brown,
                        ),
                      ),
                    ),
            ),
          ),

          // Kahve bilgileri
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kahve adı ve türü
                Row(
                  children: [
                    Text(
                      recipe['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF6F4E37),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.brown[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recipe['type'] ?? '',
                        style: TextStyle(
                          color: Colors.brown[900],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Açıklama
                if (recipe['description'] != null)
                  Text(
                    recipe['description'],
                    style:
                        const TextStyle(fontSize: 15, color: Color(0xFF4E342E)),
                  ),
                const SizedBox(height: 14),

                // Parametreler
                if (parameters != null) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildParameterChip(
                        'Öğütme',
                        parameters['grindSize']?.toString() ?? '-',
                        Icons.grain,
                      ),
                      _buildParameterChip(
                        'Sıcaklık',
                        '${parameters['waterTemp']}°C',
                        Icons.thermostat,
                      ),
                      _buildParameterChip(
                        'Süre',
                        '${parameters['brewTime']} sn',
                        Icons.timer,
                      ),
                      _buildParameterChip(
                        'Kahve',
                        '${parameters['coffeeAmount']}g',
                        Icons.coffee,
                      ),
                      _buildParameterChip(
                        'Su',
                        '${parameters['waterAmount']}ml',
                        Icons.water_drop,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildParameterChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.brown[700]),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              color: Colors.brown[900],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
