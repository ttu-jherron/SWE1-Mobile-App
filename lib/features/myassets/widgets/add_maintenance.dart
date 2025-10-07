import 'package:flutter/material.dart';
// import '../../../../core/constants.dart';
import '../../../../core/colors.dart';
// import '../../../maintenance/data/maintenance_item.dart';

class MaintenanceCard extends StatefulWidget {
  const MaintenanceCard({Key? key}) : super(key: key);

  @override
  State<MaintenanceCard> createState() => _MaintenanceCardState();
}

class _MaintenanceCardState extends State<MaintenanceCard> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 100,
        maxWidth: 150,
        // minHeight: 40,
      ),
      child: Card(
        elevation: 0,
        color: const Color(0xFFF5F5F5),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Color(0xFF2A323F),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(0,0,10,2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Oct. 01, 2025",
                style: TextStyle(
                  color: Color(0xFF2A323F),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Take to vet",
                style: TextStyle(
                  color: Color(0xFF2A323F),
                  fontSize: 14,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

