import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carbon_provider.dart';
import '../providers/auth_provider.dart';
import '../models/carbon_record.dart';
import '../services/carbon_calculator.dart';
import '../l10n/app_localizations.dart';

class AddRecordScreen extends StatefulWidget {
  final String? initialType;
  
  const AddRecordScreen({super.key, this.initialType});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _distanceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startLocationController = TextEditingController();
  final _endLocationController = TextEditingController();
  final _amountController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedType = 'transport';
  TransportType _selectedTransport = TransportType.walking;
  String _selectedFoodType = 'vegetables';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _descriptionController.dispose();
    _startLocationController.dispose();
    _endLocationController.dispose();
    _amountController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增記錄'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveRecord,
            child: const Text(
              '儲存',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 記錄類型選擇
              Text(
                '記錄類型',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TypeChip(
                    label: l10n.transportation,
                    value: 'transport',
                    selected: _selectedType == 'transport',
                    onSelected: (value) => setState(() => _selectedType = value),
                  ),
                  _TypeChip(
                    label: l10n.shopping,
                    value: 'shopping',
                    selected: _selectedType == 'shopping',
                    onSelected: (value) => setState(() => _selectedType = value),
                  ),
                  _TypeChip(
                    label: l10n.electricity,
                    value: 'energy',
                    selected: _selectedType == 'energy',
                    onSelected: (value) => setState(() => _selectedType = value),
                  ),
                  _TypeChip(
                    label: l10n.diet,
                    value: 'food',
                    selected: _selectedType == 'food',
                    onSelected: (value) => setState(() => _selectedType = value),
                  ),
                  _TypeChip(
                    label: l10n.delivery,
                    value: 'delivery',
                    selected: _selectedType == 'delivery',
                    onSelected: (value) => setState(() => _selectedType = value),
                  ),
                  _TypeChip(
                    label: l10n.express,
                    value: 'express',
                    selected: _selectedType == 'express',
                    onSelected: (value) => setState(() => _selectedType = value),
                  ),
                  _TypeChip(
                    label: l10n.accommodation,
                    value: 'accommodation',
                    selected: _selectedType == 'accommodation',
                    onSelected: (value) => setState(() => _selectedType = value),
                  ),
                  _TypeChip(
                    label: l10n.other,
                    value: 'other',
                    selected: _selectedType == 'other',
                    onSelected: (value) => setState(() => _selectedType = value),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 根據類型顯示不同的輸入字段
              _buildTypeSpecificFields(),
              
              const SizedBox(height: 24),

              // 描述
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述（可選）',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSpecificFields() {
    switch (_selectedType) {
      case 'transport':
        return _buildTransportFields();
      case 'shopping':
        return _buildShoppingFields();
      case 'energy':
        return _buildEnergyFields();
      case 'food':
        return _buildFoodFields();
      case 'delivery':
        return _buildDeliveryFields();
      case 'express':
        return _buildExpressFields();
      case 'accommodation':
        return _buildAccommodationFields();
      case 'other':
        return _buildOtherFields();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTransportFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 交通方式選擇
        Text(
          '交通方式',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: TransportType.values.map((type) {
            return _TypeChip(
              label: CarbonCalculator.getTransportTypeName(type),
              value: type.toString().split('.').last,
              selected: _selectedTransport == type,
              onSelected: (value) {
                setState(() {
                  _selectedTransport = type;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // 距离输入
        TextFormField(
          controller: _distanceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '距離 (km)',
            border: OutlineInputBorder(),
            suffixText: 'km',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '請輸入距離';
            }
            final distance = double.tryParse(value);
            if (distance == null || distance <= 0) {
              return '請輸入有效的距離';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // 起点和终点
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _startLocationController,
                decoration: const InputDecoration(
                  labelText: '起点（可选）',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _endLocationController,
                decoration: const InputDecoration(
                  labelText: '终点（可选）',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShoppingFields() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: '消費金額',
        border: OutlineInputBorder(),
        suffixText: '元',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '請輸入消費金額';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return '請輸入有效的金額';
        }
        return null;
      },
    );
  }

  Widget _buildEnergyFields() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: '用電量',
        border: OutlineInputBorder(),
        suffixText: 'kWh',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '請輸入用電量';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return '請輸入有效的用電量';
        }
        return null;
      },
    );
  }

  Widget _buildFoodFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 食物類型選擇
        Text(
          '食物類型',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            'beef', 'pork', 'chicken', 'fish', 'dairy', 
            'vegetables', 'fruits', 'grains', 'rice'
          ].map((type) {
            return _TypeChip(
              label: _getFoodTypeName(type),
              value: type,
              selected: _selectedFoodType == type,
              onSelected: (value) {
                setState(() {
                  _selectedFoodType = value;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // 重量输入
        TextFormField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '重量',
            border: OutlineInputBorder(),
            suffixText: 'kg',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '請輸入重量';
            }
            final weight = double.tryParse(value);
            if (weight == null || weight <= 0) {
              return '請輸入有效的重量';
            }
            return null;
          },
        ),
      ],
    );
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

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final carbonProvider = Provider.of<CarbonProvider>(context, listen: false);
      
      if (authProvider.user == null) {
        _showError('用戶未登入');
        return;
      }

      final userId = authProvider.user!.id;

      switch (_selectedType) {
        case 'transport':
          await carbonProvider.addTransportRecord(
            userId: userId,
            transportType: _selectedTransport,
            distance: double.parse(_distanceController.text),
            description: _descriptionController.text.isEmpty 
                ? null 
                : _descriptionController.text,
            startLocation: _startLocationController.text.isEmpty 
                ? null 
                : _startLocationController.text,
            endLocation: _endLocationController.text.isEmpty 
                ? null 
                : _endLocationController.text,
          );
          break;

        case 'shopping':
          await carbonProvider.addShoppingRecord(
            userId: userId,
            amount: double.parse(_amountController.text),
            description: _descriptionController.text.isEmpty 
                ? null 
                : _descriptionController.text,
          );
          break;

        case 'energy':
          await carbonProvider.addEnergyRecord(
            userId: userId,
            consumption: double.parse(_amountController.text),
            description: _descriptionController.text.isEmpty 
                ? null 
                : _descriptionController.text,
          );
          break;

        case 'food':
          await carbonProvider.addFoodRecord(
            userId: userId,
            weight: double.parse(_weightController.text),
            foodType: _selectedFoodType,
            description: _descriptionController.text.isEmpty 
                ? null 
                : _descriptionController.text,
          );
          break;

        case 'delivery':
          await carbonProvider.addDeliveryRecord(
            userId: userId,
            amount: double.parse(_amountController.text),
            description: _descriptionController.text.isEmpty 
                ? null 
                : _descriptionController.text,
          );
          break;

        case 'express':
          await carbonProvider.addExpressRecord(
            userId: userId,
            amount: double.parse(_amountController.text),
            description: _descriptionController.text.isEmpty 
                ? null 
                : _descriptionController.text,
          );
          break;

        case 'accommodation':
          await carbonProvider.addAccommodationRecord(
            userId: userId,
            amount: double.parse(_amountController.text),
            description: _descriptionController.text.isEmpty 
                ? null 
                : _descriptionController.text,
          );
          break;

        case 'other':
          await carbonProvider.addOtherRecord(
            userId: userId,
            value: double.tryParse(_amountController.text) ?? 0.0,
            description: _descriptionController.text.isEmpty 
                ? null 
                : _descriptionController.text,
          );
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('記錄新增成功！')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('儲存失敗: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 新增的字段构建方法
  Widget _buildDeliveryFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(
            labelText: '外送金額',
            border: OutlineInputBorder(),
            suffixText: '元',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '請輸入外送金額';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: '外送平台/餐廳',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildExpressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(
            labelText: '快遞費用',
            border: OutlineInputBorder(),
            suffixText: '元',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '請輸入快遞費用';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: '快遞公司',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildAccommodationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(
            labelText: '住宿費用',
            border: OutlineInputBorder(),
            suffixText: '元',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '請輸入住宿費用';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: '住宿類型',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(
            labelText: '数值',
            border: OutlineInputBorder(),
            suffixText: '單位',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: '活動描述',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Function(String) onSelected;

  const _TypeChip({
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
