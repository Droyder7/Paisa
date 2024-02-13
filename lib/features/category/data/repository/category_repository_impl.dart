// 📦 Package imports:
import 'package:injectable/injectable.dart';

// 🌎 Project imports:
import 'package:paisa/core/common.dart';
import 'package:paisa/features/category/data/data_sources/local/category_data_source.dart';
import 'package:paisa/features/category/data/model/category_model.dart';
import 'package:paisa/features/category/domain/entities/category.dart';
import 'package:paisa/features/category/domain/repository/category_repository.dart';
import 'package:paisa/features/transaction/data/data_sources/local/transaction_data_manager.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl extends CategoryRepository {
  CategoryRepositoryImpl({
    required this.dataSources,
    required this.expenseDataManager,
  });

  final CategoryDataSource dataSources;
  final TransactionDataSource expenseDataManager;

  @override
  Future<void> add({
    required String? name,
    required int? icon,
    required int? color,
    required String? desc,
    required bool? isBudget,
    required double? budget,
    required bool? isDefault,
  }) {
    return dataSources.add(CategoryModel(
      description: desc ?? '',
      name: name,
      icon: icon,
      budget: budget,
      isBudget: isBudget,
      color: color,
      isDefault: isDefault,
    ));
  }

  @override
  Future<void> clear() => dataSources.clear();

  @override
  Future<void> delete(int key) => dataSources.delete(key);

  @override
  CategoryModel? fetchById(int? categoryId) => dataSources.findById(categoryId);

  @override
  List<CategoryEntity> defaultCategories() {
    return dataSources.defaultCategories().toEntities();
  }

  @override
  Future<void> update({
    required int? key,
    required String? name,
    required int? icon,
    required int? color,
    required String? desc,
    required double? budget,
    required bool isBudget,
    required bool isDefault,
  }) {
    return dataSources.update(CategoryModel(
      description: desc,
      name: name,
      icon: icon,
      budget: budget,
      isBudget: isBudget,
      isDefault: isDefault,
      color: color,
      superId: key,
    ));
  }
}
