import 'package:flutter/material.dart';
import 'package:mobile_app/features/assets/data/asset.dart';
import 'package:mobile_app/features/assets/data/asset_repository.dart';
import '../../../core/constants.dart';
import '../../../core/colors.dart';
import '../../../core/layout/app_layout.dart'; // ADD

class MaintenanceDetailScreen extends StatelessWidget {
  const MaintenanceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    Asset? a;
    if (args is Asset) {
      a = args;
    } else if (args is String) {
      // Async fetch for new model
      // This widget should be refactored to FutureBuilder for real async, but for now:
      // a = await assetRepository.getById(args); (if you want true async)
      // For now, just set to null to avoid sync error
      a = null;
    }

    return AppLayout( // WRAP with AppLayout to restore header + bottom nav
      currentIndex: 2, // Maintenance tab
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom header with title + X (kept)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    a != null ? 'Maintenance: ${a?.itemName ?? ''}' : 'Maintenance Detail',
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ebonyClay,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.ebonyClay, size: 28),
                  tooltip: 'Close',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          if (a == null)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Asset not found', style: TextStyle(color: Colors.black87)),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Spacing.xl),
                    Text(
                      a.brandName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.itemName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF36404B),
                          ),
                    ),
                    const SizedBox(height: Spacing.xl),

                    _Label('Category'),
                    const SizedBox(height: 2),
                    _Value(a.category),
                    const SizedBox(height: Spacing.lg),

                    _Label('Purchase Date'),
                    const SizedBox(height: 2),
                    _Value(_formatDate(a.purchaseDate)),
                    const SizedBox(height: Spacing.lg),

                    _Label('Purchase Cost'),
                    const SizedBox(height: 2),
                    _Value(a.purchaseCost.toStringAsFixed(2)),
                    const SizedBox(height: Spacing.lg),

                    _Label('Current Location'),
                    const SizedBox(height: 2),
                    _Value(a.currentLocation),
                    const SizedBox(height: Spacing.lg),

                    _Label('Condition'),
                    const SizedBox(height: 2),
                    _Value(a.conditionDescription),
                    const SizedBox(height: Spacing.lg),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    final months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December',
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
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87));
  }
}

class _Value extends StatelessWidget {
  final String text;
  const _Value(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Colors.black87));
  }
}

class _MaterialsTable extends StatelessWidget {
  final List<MaterialRow> rows;
  const _MaterialsTable({required this.rows});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(1.6), 1: FlexColumnWidth(1.4)},
        border: const TableBorder(
          horizontalInside: BorderSide(color: Colors.black26, width: 1),
          top: BorderSide(color: Colors.black26, width: 1),
          bottom: BorderSide(color: Colors.black26, width: 1),
        ),
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Colors.transparent),
            children: [_HeaderCell('Tools'), _HeaderCell('Current Location')],
          ),
          for (int i = 0; i < rows.length; i++)
            TableRow(
              decoration: BoxDecoration(color: i.isOdd ? Colors.black12 : Colors.transparent),
              children: [_Cell(rows[i].tool), _Cell(rows[i].location)],
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
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
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
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
      child: Text(text, style: const TextStyle(color: Colors.black87)),
    );
  }
}
