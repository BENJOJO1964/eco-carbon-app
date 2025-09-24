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
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E7D32),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                      ),
                    )
                  : const Text(
                      '儲存',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
            ],
            stops: [0.0, 0.1],
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 記錄類型選擇標題
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '記錄類型',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 類型選擇容器
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Wrap(
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
                  ),
                  const SizedBox(height: 24),

                  // 根據類型顯示不同的輸入字段
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildTypeSpecificFields(),
                  ),
                  
                  const SizedBox(height: 24),

                  // 描述字段
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              '描述（可選）',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: '請輸入詳細描述...',
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(value),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected 
                ? const Color(0xFF2E7D32) 
                : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected 
                  ? const Color(0xFF2E7D32) 
                  : Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: selected ? [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey[700],
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
