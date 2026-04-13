# sentence_maker_x

## 项目简介

sentence_maker_x 是一个基于古诗文数据库和词性匹配的造句助手，帮助用户生成符合语法规则的句子。

## 技术栈

- **前端框架**：Flutter
- **后端逻辑**：Rust
- **数据处理**：Python

**不支持web！**

## 项目结构

```
sentence_maker_x/
├── lib/             # Flutter 代码
│   ├── src/         # 源代码
│   └── main.dart    # 主入口文件
├── rust/            # Rust 代码
│   ├── src/         # 源代码
│   ├── Cargo.toml   # Rust 依赖管理
│   └── Cargo.lock   # 依赖版本锁定
├── rust_builder/    # Rust 构建工具
├── python/          # Python 脚本
│   ├── dbcontroller.py  # 数据库控制器
│   ├── distil32.py      # 数据库生成脚本
│   └── requirements.txt # Python 依赖
├── android/         # Android 平台代码
├── ios/             # iOS 平台代码
├── web/             # Web 平台代码
├── windows/         # Windows 平台代码
├── linux/           # Linux 平台代码
├── macos/           # macOS 平台代码
├── flutter_rust_bridge.yaml # Flutter 与 Rust 桥接配置
└── pubspec.yaml     # Flutter 依赖管理
```

## 功能模块

### 1. 造句功能

核心逻辑位于 `rust/src/api/simple.rs`，基于词性匹配算法生成符合语法规则的句子。

### 2. 界面部分

Flutter 界面实现位于 `lib/main.dart`，提供用户友好的交互界面。

### 3. 数据库生成

使用 Python 脚本生成古诗文数据库：

1. 安装 Python 环境
2. 安装依赖：
   ```shell
   pip install -r requirements.txt
   ```
3. 运行数据库生成脚本：
   ```shell
   python distil32.py
   ```

## 安装和运行

### 环境要求

- Flutter 3.0+
- Rust 1.60+
- Python 3.14

### 安装步骤

1. 克隆项目：
   ```shell
   git clone <repository-url>
   cd sentence_maker_x
   ```

2. 安装 Flutter 依赖：
   ```shell
   flutter pub get
   ```

3. 安装 Python 依赖：
   ```shell
   pip install -r requirements.txt
   ```

4. 生成数据库：
   ```shell
   python distil32.py
   ```

### 运行项目

- **Android**：
  ```shell
  flutter run -d android
  ```

- **iOS**：
  ```shell
  flutter run -d ios
  ```

- **Windows**：
  ```shell
  flutter run -d windows
  ```

- **Linux**：
  ```shell
  flutter run -d linux
  ```

- **macOS**：
  ```shell
  flutter run -d macos
  ```

## 技术实现

### Flutter 与 Rust 集成

项目使用 `flutter_rust_bridge` 实现 Flutter 与 Rust 的无缝集成，利用 Rust 的性能优势处理复杂的句子生成逻辑。

### 数据库管理

使用 SQLite 数据库存储古诗文和词性信息，通过 Python 脚本进行数据处理和生成。

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送分支
5. 开启 Pull Request

## 数据集

[中文诗词数据集](https://www.modelscope.cn/datasets/modelscope/chinese-poetry-collection/files) 