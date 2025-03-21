import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/widgets/custom_flash_bar.dart';
import '../models/grocery_model.dart';
import 'package:uuid/uuid.dart';

class GroceryListController extends GetxController {
  var selectedFilter = "All".obs;
  var currentListId = ''.obs;
  var groceryItems = <GroceryItem>[].obs;
  var itemQuantities = <String, int>{}.obs;
  var recentlyAddedItem = RxString('');
  var isLoading = true.obs;
  var groceryLists = <GroceryList>[].obs;
  late Box<GroceryList> groceryListBox;
  late Box<GroceryItem> groceryItemBox;

  var allItems = <String>[].obs;

  final List<String> initialSuggestions = [
    'Shopping', 'Groceries', 'Trip', 'Weekend', 'Wednesday', 'House', 'Supermarket', 'Food', 'Pharmacy'
  ];

  final List<String> predefinedItems = [
    'Bread', 'Milk', 'Eggs', 'Ham', 'Butter', 'Meat', 'Potatoes', 'Tomatoes', 'Cheese', 'Yogurt',
    'Chicken', 'Rice', 'Pasta', 'Apples', 'Bananas', 'Carrots', 'Onions', 'Cereal', 'Coffee', 'Tea',
  ];

  @override
  void onInit() {
    super.onInit();
    _initHive().then((_) {
      isLoading.value = false;
      allItems.value = [...predefinedItems];
      _updateGroceryLists();
      _listenToHiveChanges();
    });
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(GroceryListAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(GroceryItemAdapter());
    groceryListBox = await Hive.openBox<GroceryList>('groceryLists');
    groceryItemBox = await Hive.openBox<GroceryItem>('groceryItems');
  }

  void _updateGroceryLists() {
    if (!isLoading.value) {
      groceryLists.value = groceryListBox.values.toList();
      update(); // Ensure the UI updates when lists change
    }
  }

  void _listenToHiveChanges() {
    // Listen for changes in the groceryListBox
    final box = Hive.box<GroceryList>('groceryLists');
    box.listenable().addListener(() {
      _updateGroceryLists(); // Update the reactive list when the box changes
    });

    // Listen for changes in the groceryItemBox
    final itemBox = Hive.box<GroceryItem>('groceryItems');
    itemBox.listenable().addListener(() {
      if (currentListId.value.isNotEmpty) {
        loadCurrentList(); // Update items for the current list
      }
      _updateGroceryLists(); // Also update lists in case items affect progress
    });
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }

  void setCurrentList(String id, String name) {
    if (!isLoading.value) {
      currentListId.value = id;
      loadCurrentList();
    }
  }

  void createNewList(String name) {
    if (!isLoading.value && name.trim().isNotEmpty) {
      final id = Uuid().v4();
      final list = GroceryList(id: id, name: name, isStarred: false);
      groceryListBox.add(list);
      currentListId.value = id;
      _updateGroceryLists();
      loadCurrentList();
    }
  }

  void toggleStarred(String listId) {
    if (!isLoading.value) {
      final list = groceryLists.firstWhereOrNull((l) => l.id == listId);
      if (list != null) {
        list.isStarred = !list.isStarred;
        list.save();
        _updateGroceryLists();
      }
    }
  }

  void deleteList(String listId,BuildContext context) {
    if (!isLoading.value) {
      // Find the index of the list to delete
      final index = groceryLists.indexWhere((list) => list.id == listId);

      if (index != -1) {
        // Delete from Hive box
        groceryListBox.deleteAt(index);

        // Remove the list from observable list
        groceryLists.removeAt(index);

        // Delete all associated items from groceryItemBox
        final itemsToDelete = groceryItemBox.values.where((item) => item.listId == listId).toList();
        for (var item in itemsToDelete) {
          item.delete();
        }

        // Clear current list if it matches the deleted list
        if (currentListId.value == listId) {
          currentListId.value = '';
          groceryItems.clear();
          itemQuantities.clear();
        }

        _updateGroceryLists(); // Refresh the list of grocery lists
        update(); // Force UI update

        // Notify user
        CustomFlashBar.show(
          context: context,
          message: "List deleted successfully",
          isAdmin: true, // optional
          isShaking: false, // optional
          primaryColor: AppColors.primary, // optional
          secondaryColor: Colors.white, // optional
        );
      }
    }
  }


  void permanentlyDeleteList(String listId,BuildContext context) {
    if (!isLoading.value) {
      // This method can be the same as deleteList for now, but with a different name for clarity
      deleteList(listId, context); // Reuse the existing deletion logic

      // Optionally, add additional cleanup or logging for permanent deletion
      CustomFlashBar.show(
        context: context,
        message: "List and all items permanently delete",
        isAdmin: true, // optional
        isShaking: false, // optional
        primaryColor: AppColors.primary, // optional
        secondaryColor: Colors.white, // optional
      );
    }
  }

  List<GroceryList> getFilteredLists() {
    if (selectedFilter.value == "Starred") {
      return groceryLists.where((list) => list.isStarred).toList();
    }
    return groceryLists.toList();
  }

  void toggleItemCompletion(String itemName, bool isCompleted) {
    if (!isLoading.value && currentListId.value.isNotEmpty) {
      final item = groceryItems.firstWhereOrNull((i) => i.name == itemName);
      if (item != null) {
        item.isCompleted = isCompleted;
        item.save();
        update();
      }
    }
  }

  void loadCurrentList() {
    groceryItems.clear();
    itemQuantities.clear();
    if (currentListId.value.isNotEmpty) {
      groceryItems.value = groceryItemBox.values
          .where((item) => item.listId == currentListId.value)
          .toList();
      itemQuantities.value = {for (var item in groceryItems) item.name: item.quantity};
    }
    update();
  }

  void addItem(String name, int quantity, {bool isCompleted = false}) {
    if (!isLoading.value && currentListId.value.isNotEmpty) {
      final item = GroceryItem(
        name: name,
        quantity: quantity,
        listId: currentListId.value,
        isCompleted: isCompleted,
      );
      groceryItemBox.add(item);
      groceryItems.add(item);
      itemQuantities[name] = quantity;
      recentlyAddedItem.value = name;
      Future.delayed(Duration(seconds: 2), () => recentlyAddedItem.value = '');
      update();
    } else {
      Get.snackbar('Error', 'Please select a list before adding items.');
    }
  }

  void updateQuantity(String itemName, int newQuantity, {bool? isCompleted}) {
    if (!isLoading.value && currentListId.value.isNotEmpty) {
      if (newQuantity < 0) newQuantity = 0;
      final item = groceryItems.firstWhereOrNull((i) => i.name == itemName);
      if (item != null) {
        item.quantity = newQuantity;
        if (isCompleted != null) item.isCompleted = isCompleted;
        item.save();
        itemQuantities[itemName] = newQuantity;
      } else {
        addItem(itemName, newQuantity, isCompleted: isCompleted ?? false);
      }
      update();
    }
  }

  void addPredefinedItem(String itemName,BuildContext context) {
    if (!isLoading.value && currentListId.value.isNotEmpty) {
      final currentQuantity = itemQuantities[itemName] ?? 0;
      updateQuantity(itemName, currentQuantity + 1);
    } else {
      CustomFlashBar.show(
        context: context,
        message: "Please select a list before adding items",
        isAdmin: true, // optional
        isShaking: false, // optional
        primaryColor: AppColors.primary, // optional
        secondaryColor: Colors.white, // optional
      );
    }
  }

  void removeQuantity(String itemName) {
    if (!isLoading.value && currentListId.value.isNotEmpty) {
      final currentQuantity = itemQuantities[itemName] ?? 0;
      if (currentQuantity > 0) {
        updateQuantity(itemName, currentQuantity - 1);
      }
    }
  }

  Map<String, double> getListProgress(String listId) {
    final items = groceryItemBox.values
        .where((item) => item.listId == listId && item.quantity > 0)
        .toList();
    if (items.isEmpty) return {'completed': 0, 'total': 1};
    final total = items.length;
    final completed = items.where((item) => item.isCompleted).length;
    return {'completed': completed.toDouble(), 'total': total.toDouble()};
  }
}