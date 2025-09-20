import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/carbon_provider.dart';
import '../models/carbon_record.dart';
import '../services/carbon_calculator.dart';
import '../l10n/app_localizations.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  String _selectedFilter = 'all';
  String _selectedSort = 'date_desc';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('記錄'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedSort = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date_desc',
                child: Text('按日期降序'),
              ),
              const PopupMenuItem(
                value: 'date_asc',
                child: Text('按日期升序'),
              ),
              const PopupMenuItem(
                value: 'carbon_desc',
                child: Text('按碳排放降序'),
              ),
              const PopupMenuItem(
                value: 'carbon_asc',
                child: Text('按碳排放升序'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 篩選器
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: '全部',
                          value: 'all',
                          selected: _selectedFilter == 'all',
                          onSelected: (value) => setState(() => _selectedFilter = value),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.transportation,
                          value: 'transport',
                          selected: _selectedFilter == 'transport',
                          onSelected: (value) => setState(() => _selectedFilter = value),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.shopping,
                          value: 'shopping',
                          selected: _selectedFilter == 'shopping',
                          onSelected: (value) => setState(() => _selectedFilter = value),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.electricity,
                          value: 'energy',
                          selected: _selectedFilter == 'energy',
                          onSelected: (value) => setState(() => _selectedFilter = value),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.diet,
                          value: 'food',
                          selected: _selectedFilter == 'food',
                          onSelected: (value) => setState(() => _selectedFilter = value),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 記錄列表
          Expanded(
            child: Consumer<CarbonProvider>(
              builder: (context, carbonProvider, child) {
                if (carbonProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredRecords = _filterAndSortRecords(carbonProvider.records);

                if (filteredRecords.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    return _RecordCard(
                      record: record,
                      onDelete: () => _deleteRecord(carbonProvider, record),
                      onEdit: () => _editRecord(record),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<CarbonRecord> _filterAndSortRecords(List<CarbonRecord> records) {
    // 篩選
    List<CarbonRecord> filtered = records;
    if (_selectedFilter != 'all') {
      final filterType = RecordType.values.firstWhere(
        (e) => e.toString().split('.').last == _selectedFilter,
        orElse: () => RecordType.other,
      );
      filtered = records.where((r) => r.type == filterType).toList();
    }

    // 排序
    switch (_selectedSort) {
      case 'date_desc':
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'date_asc':
        filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'carbon_desc':
        filtered.sort((a, b) => b.carbonFootprint.compareTo(a.carbonFootprint));
        break;
      case 'carbon_asc':
        filtered.sort((a, b) => a.carbonFootprint.compareTo(b.carbonFootprint));
        break;
    }

    return filtered;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暫無記錄',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '點擊右下角的 + 按鈕新增第一條記錄',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(CarbonProvider carbonProvider, CarbonRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: const Text('您確定要刪除這條記錄嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              carbonProvider.deleteRecord(record.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('記錄已刪除')),
              );
            },
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  void _editRecord(CarbonRecord record) {
    // TODO: 实现编辑功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('編輯功能開發中...')),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Function(String) onSelected;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (isSelected) => onSelected(value),
      selectedColor: Colors.green[100],
      checkmarkColor: Colors.green[700],
      labelStyle: TextStyle(
        color: selected ? Colors.green[700] : Colors.grey[600],
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final CarbonRecord record;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _RecordCard({
    required this.record,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _buildTypeIcon(),
        title: Text(
          CarbonCalculator.getRecordTypeName(record.type),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (record.description != null) ...[
              Text(record.description!),
              const SizedBox(height: 4),
            ],
            _buildRecordDetails(),
            const SizedBox(height: 4),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(record.timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${record.carbonFootprint.toStringAsFixed(2)} kg CO₂',
              style: TextStyle(
                color: Colors.red[600],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('編輯'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('刪除'),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor;

    switch (record.type) {
      case RecordType.transport:
        iconData = Icons.directions_walk;
        iconColor = Colors.blue;
        break;
      case RecordType.shopping:
        iconData = Icons.shopping_cart;
        iconColor = Colors.orange;
        break;
      case RecordType.energy:
        iconData = Icons.electrical_services;
        iconColor = Colors.purple;
        break;
      case RecordType.food:
        iconData = Icons.restaurant;
        iconColor = Colors.red;
        break;
      case RecordType.delivery:
        iconData = Icons.delivery_dining;
        iconColor = Colors.green;
        break;
      case RecordType.express:
        iconData = Icons.local_shipping;
        iconColor = Colors.teal;
        break;
      case RecordType.accommodation:
        iconData = Icons.hotel;
        iconColor = Colors.indigo;
        break;
      case RecordType.other:
        iconData = Icons.category;
        iconColor = Colors.grey;
        break;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(iconData, color: iconColor),
    );
  }

  Widget _buildRecordDetails() {
    switch (record.type) {
      case RecordType.transport:
        if (record.transportType != null) {
          return Text(
            '${CarbonCalculator.getTransportTypeName(record.transportType!)} - ${record.distance.toStringAsFixed(2)} km',
            style: TextStyle(color: Colors.grey[700]),
          );
        }
        break;
      case RecordType.shopping:
        return Text(
          '消費金額: ¥${record.distance.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.grey[700]),
        );
      case RecordType.energy:
        return Text(
          '用電量: ${record.distance.toStringAsFixed(2)} kWh',
          style: TextStyle(color: Colors.grey[700]),
        );
      case RecordType.food:
        final foodType = record.metadata?['foodType'] ?? '未知';
        return Text(
          '${_getFoodTypeName(foodType)} - ${record.distance.toStringAsFixed(2)} kg',
          style: TextStyle(color: Colors.grey[700]),
        );
      case RecordType.delivery:
        return Text(
          '外送金額: ¥${record.distance.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.grey[700]),
        );
      case RecordType.express:
        return Text(
          '快遞費用: ¥${record.distance.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.grey[700]),
        );
      case RecordType.accommodation:
        return Text(
          '住宿費用: ¥${record.distance.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.grey[700]),
        );
      case RecordType.other:
        return Text(
          '其他活動: ${record.distance.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.grey[700]),
        );
    }
    return const SizedBox.shrink();
  }

  String _getFoodTypeName(String type) {
    const Map<String, String> names = {
      'beef': '牛肉',
      'pork': '猪肉',
      'chicken': '鸡肉',
      'fish': '鱼肉',
      'dairy': '乳制品',
      'vegetables': '蔬菜',
      'fruits': '水果',
      'grains': '谷物',
      'rice': '大米',
    };
    return names[type] ?? type;
  }
}
