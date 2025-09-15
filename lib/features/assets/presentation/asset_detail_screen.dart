import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
import '../../../core/layout/app_layout.dart';
import '../../assets/data/asset_repository.dart';
import '../../assets/data/asset.dart';

class AssetDetailScreen extends StatelessWidget {
  /// If navigating with data already loaded, pass it here.
  /// Otherwise, provide an `assetId` and this screen will load from repo.
  final String? assetId;
  final Asset? asset;

  const AssetDetailScreen({super.key, this.assetId, this.asset})
      : assert(assetId != null || asset != null,
            'Provide either assetId or asset');

  @override
  Widget build(BuildContext context) {
    final a = asset ?? assetRepository.getById(assetId!);
    final daysLeft =
        a.completionDate.difference(DateTime.now()).inDays; // simplistic

    return AppLayout(
      currentIndex: 1, // My Assets tab
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Spacing.xl, Spacing.lg, Spacing.xl, Spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand + Title (matches hierarchy in mock)
            Text(a.brand,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                )),
            const SizedBox(height: 4),
            Text(
              a.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF36404B), // dark gray like the mock
                  ),
            ),
            const SizedBox(height: Spacing.xl),

            _Label('Asset Name'),
            _Value(a.name),
            const SizedBox(height: Spacing.lg),

            _Label('Completion Date'),
            _Value(_formatDate(a.completionDate) +
                '  •  ${daysLeft.abs()} days ${daysLeft >= 0 ? "left" : "ago"}'),
            const SizedBox(height: Spacing.lg),

            _Label('Short Description'),
            _Value(a.shortDescription),
            const SizedBox(height: Spacing.lg),

            _Label('Notes'),
            const SizedBox(height: 2),
            Text(
              a.notes,
              style: const TextStyle(
                height: 1.35,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: Spacing.xl),

            _Label('Required Materials'),
            const SizedBox(height: Spacing.sm),
            _MaterialsTable(rows: a.requiredMaterials),

            const SizedBox(height: Spacing.xl),

            Center(
              child: SizedBox(
                width: 280,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ebonyClay,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      vertical: Spacing.sm, horizontal: Spacing.xl),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  onPressed: () {
                    // TODO: call backend to mark maintenance as completed
                    // await repo.completeMaintenance(a.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Maintenance recorded')),
                    );
                  },
                  child: const Text('Maintenance Completed'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    // Simple formatter; swap for intl if you add it later.
    final months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    final m = months[d.month - 1];
    final day = d.day.toString().padLeft(2, '0');
    return '$m $day, ${d.year}';
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }
}

class _Value extends StatelessWidget {
  final String text;
  const _Value(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.black87),
    );
  }
}

/// Simple table to match the mock (striped, two columns).
class _MaterialsTable extends StatelessWidget {
  final List<MaterialRow> rows;
  const _MaterialsTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.6),
          1: FlexColumnWidth(1.4),
        },
        border: const TableBorder(
          horizontalInside: BorderSide(color: Colors.black26, width: 1),
          top: BorderSide(color: Colors.black26, width: 1),
          bottom: BorderSide(color: Colors.black26, width: 1),
        ),
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Colors.transparent),
            children: [
              _HeaderCell('Tools'),
              _HeaderCell('Current Location'),
            ],
          ),
          for (int i = 0; i < rows.length; i++)
            TableRow(
              decoration: BoxDecoration(
                color: i.isOdd ? Colors.black12 : Colors.transparent,
              ),
              children: [
                _Cell(rows[i].tool),
                _Cell(rows[i].location),
              ],
            ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md, vertical: Spacing.sm),
      child: Text(
        text,
        style: const TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  const _Cell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md, vertical: Spacing.sm),
      child: Text(text, style: const TextStyle(color: Colors.black87)),
    );
  }
}
