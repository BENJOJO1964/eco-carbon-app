# Eco - 碳足迹追踪APP

一个基于Flutter开发的碳足迹追踪应用，帮助用户记录和分析日常生活中的碳排放量。

## 功能特性

### 核心功能
- **用户认证**: 支持邮箱注册和登录
- **碳足迹记录**: 支持多种类型的碳排放记录
  - 交通出行（步行、骑行、公交、地铁、开车等）
  - 购物消费
  - 用电消耗
  - 饮食消费
- **数据统计**: 提供详细的统计图表和分析
- **环保建议**: 基于用户数据提供个性化环保建议

### 技术特性
- **实时数据同步**: 使用Firebase Cloud Firestore
- **离线支持**: 本地数据缓存
- **传感器集成**: 自动检测用户活动模式
- **权限管理**: 智能权限请求策略

## 技术栈

- **前端**: Flutter (Dart)
- **后端**: Firebase
  - Authentication (用户认证)
  - Cloud Firestore (数据存储)
- **状态管理**: Provider
- **图表**: fl_chart
- **位置服务**: geolocator
- **传感器**: sensors_plus
- **权限管理**: permission_handler

## 项目结构

```
lib/
├── models/          # 数据模型
│   ├── user_model.dart
│   └── carbon_record.dart
├── services/        # 服务层
│   ├── firebase_service.dart
│   ├── carbon_calculator.dart
│   ├── location_service.dart
│   └── sensor_service.dart
├── providers/       # 状态管理
│   ├── auth_provider.dart
│   └── carbon_provider.dart
├── screens/         # 界面
│   ├── auth_screen.dart
│   ├── home_screen.dart
│   ├── add_record_screen.dart
│   ├── records_screen.dart
│   └── stats_screen.dart
└── main.dart       # 应用入口
```

## 安装和运行

### 前置要求
- Flutter SDK (3.8.1+)
- Dart SDK
- Android Studio / VS Code
- Firebase项目配置

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd eco
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **配置Firebase**
   - 在Firebase控制台创建新项目
   - 下载`google-services.json`到`android/app/`目录
   - 下载`GoogleService-Info.plist`到`ios/Runner/`目录

4. **运行应用**
   ```bash
   flutter run
   ```

### 开发模式运行
```bash
flutter run --debug
```

### 发布版本构建
```bash
flutter build apk --release
flutter build ios --release
```

## 使用说明

### 首次使用
1. 打开应用，点击"注册"创建新账号
2. 输入邮箱和密码完成注册
3. 登录后开始记录碳足迹

### 记录碳足迹
1. 点击首页的快速添加按钮或右下角的"+"按钮
2. 选择记录类型（交通、购物、用电、饮食）
3. 填写相关信息（距离、金额、重量等）
4. 保存记录

### 查看统计
1. 在底部导航栏点击"统计"
2. 查看按类型和日期的统计图表
3. 获取个性化环保建议

## 碳排放计算标准

### 交通出行 (kg CO₂/km)
- 步行: 0.0
- 骑行: 0.0
- 公交车: 0.05
- 地铁: 0.03
- 开车: 0.2
- 摩托车: 0.1
- 飞机: 0.285
- 火车: 0.014

### 其他活动
- 购物消费: 每100元约产生1kg CO₂
- 用电消耗: 每kWh产生0.581kg CO₂（中国电网平均）
- 饮食消费: 根据食物类型和重量计算

## 开发计划

### 已完成功能
- [x] 用户认证系统
- [x] 基础碳足迹记录
- [x] 数据统计和图表
- [x] 基础UI界面

### 开发中功能
- [ ] 传感器自动检测
- [ ] 位置服务集成
- [ ] 数据导出功能

### 计划功能
- [ ] 社交分享功能
- [ ] 环保挑战活动
- [ ] 企业版功能
- [ ] 多语言支持

## 贡献指南

1. Fork项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

## 许可证

本项目采用MIT许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 联系方式

如有问题或建议，请通过以下方式联系：
- 邮箱: your-email@example.com
- 项目Issues: [GitHub Issues](https://github.com/your-username/eco/issues)

## 致谢

感谢所有为环保事业做出贡献的开发者和用户！# 觸發 Vercel 重新部署 - Wed Sep 24 18:05:30 CST 2025
# 強制觸發 Vercel 重新部署 - Wed Sep 24 18:16:52 CST 2025
# 最終修復部署 - Wed Sep 24 18:18:52 CST 2025
