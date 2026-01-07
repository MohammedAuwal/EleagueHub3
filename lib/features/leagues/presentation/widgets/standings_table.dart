import 'package:flutter/material.dart';

import '../../../../core/widgets/glass.dart';
import '../../domain/models.dart';

class StandingsTable extends StatefulWidget {
  const StandingsTable({super.key, required this.rows});

  final List<StandingRow> rows;

  @override
  State<StandingsTable> createState() => _StandingsTableState();
}

class _StandingsTableState extends State<StandingsTable> {
  int _sortCol = 7; // points
  bool _asc = false;

  List<StandingRow> get _sorted {
    final rows = [...widget.rows];
    int cmp(StandingRow a, StandingRow b) {
      int v;
      switch (_sortCol) {
        case 0: v = a.team.compareTo(b.team); break;
        case 1: v = a.played.compareTo(b.played); break;
        case 2: v = a.wins.compareTo(b.wins); break;
        case 3: v = a.draws.compareTo(b.draws); break;
        case 4: v = a.losses.compareTo(b.losses); break;
        case 5: v = a.gd.compareTo(b.gd); break;
        case 6: v = a.gf.compareTo(b.gf); break;
        case 7:
        default:
          v = a.points.compareTo(b.points);
      }
      return _asc ? v : -v;
    }
    rows.sort(cmp);
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _sorted;

    return Glass(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortAscending: _asc,
          sortColumnIndex: _sortCol,
          columns: [
            _col('Team', 0),
            _col('P', 1, numeric: true),
            _col('W', 2, numeric: true),
            _col('D', 3, numeric: true),
            _col('L', 4, numeric: true),
            _col('GD', 5, numeric: true),
            _col('GF', 6, numeric: true),
            _col('Pts', 7, numeric: true),
          ],
          rows: [
            for (int i = 0; i < rows.length; i++)
              _row(context, i, rows[i]),
          ],
        ),
      ),
    );
  }

  DataColumn _col(String label, int index, {bool numeric = false}) {
    return DataColumn(
      numeric: numeric,
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      onSort: (col, asc) {
        setState(() {
          _sortCol = col;
          _asc = asc;
        });
      },
    );
  }

  DataRow _row(BuildContext context, int i, StandingRow r) {
    final primary = Theme.of(context).colorScheme.primary;
    // Changed withValues to withOpacity
    final zoneColor = i < 2
        ? Colors.green.withOpacity(0.12)
        : i < 4
            ? primary.withOpacity(0.10)
            : Colors.transparent;

    return DataRow(
      // Changed WidgetStatePropertyAll to MaterialStatePropertyAll
      color: MaterialStatePropertyAll(zoneColor),
      cells: [
        DataCell(Text(r.team, style: const TextStyle(fontWeight: FontWeight.w700))),
        DataCell(Text('${r.played}')),
        DataCell(Text('${r.wins}')),
        DataCell(Text('${r.draws}')),
        DataCell(Text('${r.losses}')),
        DataCell(Text('${r.gd}')),
        DataCell(Text('${r.gf}')),
        DataCell(Text('${r.points}', style: const TextStyle(fontWeight: FontWeight.w900))),
      ],
    );
  }
}
