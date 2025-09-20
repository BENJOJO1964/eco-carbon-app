import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/carbon_provider.dart';
import '../models/carbon_record.dart';
import '../services/carbon_calculator.dart';
import '../l10n/app_localizations.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedPeriod = 'week'; // week, month, year

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('統計'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'week',
                child: Text('最近一周'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('最近一月'),
              ),
              const PopupMenuItem(
                value: 'year',
                child: Text('最近一年'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<CarbonProvider>(
        builder: (context, carbonProvider, child) {
          if (carbonProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = carbonProvider.stats;
          final records = _filterRecordsByPeriod(carbonProvider.records);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 總覽卡片
                _buildOverviewCard(stats, l10n),
                const SizedBox(height: 16),

                // 按類型統計
                _buildTypeChart(records),
                const SizedBox(height: 16),

                // 按日期統計
                _buildDateChart(records),
                const SizedBox(height: 16),

                // 詳細統計
                _buildDetailedStats(records),
              ],
            ),
          );
        },
      ),
    );
  }

  List<CarbonRecord> _filterRecordsByPeriod(List<CarbonRecord> records) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    return records.where((record) => record.timestamp.isAfter(startDate)).toList();
  }

  Widget _buildOverviewCard(Map<String, dynamic> stats, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.overview,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: '總記錄',
                    value: '${stats['totalRecords'] ?? 0}',
                    icon: Icons.list,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '總碳排放',
                    value: '${(stats['totalCarbon'] ?? 0.0).toStringAsFixed(2)} kg',
                    icon: Icons.eco,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: '今日排放',
                    value: '${(stats['averageDaily'] ?? 0.0).toStringAsFixed(2)} kg',
                    icon: Icons.today,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: '本周排放',
                    value: '${(stats['averageWeekly'] ?? 0.0).toStringAsFixed(2)} kg',
                    icon: Icons.date_range,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChart(List<CarbonRecord> records) {
    final carbonByType = CarbonCalculator.calculateCarbonByType(records);
    
    if (carbonByType.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              '暫無數據',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    final pieChartData = carbonByType.entries.map((entry) {
      final color = _getTypeColor(entry.key);
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${CarbonCalculator.getRecordTypeName(entry.key)}\n${entry.value.toStringAsFixed(1)} kg',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '按類型統計',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: pieChartData,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChart(List<CarbonRecord> records) {
    final carbonByDate = CarbonCalculator.calculateCarbonByDate(records);
    
    if (carbonByDate.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              '暫無數據',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    final sortedDates = carbonByDate.keys.toList()..sort();
    final spots = sortedDates.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      final carbon = carbonByDate[date]!;
      return FlSpot(index.toDouble(), carbon);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '按日期統計',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < sortedDates.length) {
                            final date = sortedDates[value.toInt()];
                            return Text(
                              DateFormat('MM/dd').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats(List<CarbonRecord> records) {
    if (records.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              '暫無詳細數據',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    final totalCarbon = records.fold(0.0, (sum, record) => sum + record.carbonFootprint);
    final averageDaily = totalCarbon / 7; // 假设7天
    final maxRecord = records.reduce((a, b) => a.carbonFootprint > b.carbonFootprint ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '詳細統計',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _DetailStatItem(
              label: '平均每日排放',
              value: '${averageDaily.toStringAsFixed(2)} kg CO₂',
              icon: Icons.trending_up,
            ),
            _DetailStatItem(
              label: '最高單次排放',
              value: '${maxRecord.carbonFootprint.toStringAsFixed(2)} kg CO₂',
              icon: Icons.keyboard_arrow_up,
            ),
            _DetailStatItem(
              label: '記錄總數',
              value: '${records.length} 条',
              icon: Icons.list_alt,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(RecordType type) {
    switch (type) {
      case RecordType.transport:
        return Colors.blue;
      case RecordType.shopping:
        return Colors.orange;
      case RecordType.energy:
        return Colors.purple;
      case RecordType.food:
        return Colors.red;
      case RecordType.delivery:
        return Colors.green;
      case RecordType.express:
        return Colors.teal;
      case RecordType.accommodation:
        return Colors.indigo;
      case RecordType.other:
        return Colors.grey;
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _DetailStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }
}
