import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../models/user_model.dart';
import '../../models/shop_profile_model.dart';
import '../../models/part_model.dart';
import '../../models/customer_model.dart';
import '../../models/supplier_model.dart';
import '../../models/invoice_model.dart';
import '../../models/purchase_model.dart';
import '../../models/stock_history_model.dart';
import '../../models/used_vehicle_model.dart';
import 'sample_data.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('autospare_pro.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
    await _ensureAathavaMotorsSeedData(db);
    return db;
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Shop Profile
    await db.execute('''
      CREATE TABLE shop_profile (
        id TEXT PRIMARY KEY,
        shopName TEXT NOT NULL,
        ownerName TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        gstin TEXT NOT NULL,
        address TEXT NOT NULL,
        state TEXT NOT NULL,
        upiId TEXT,
        invoicePrefix TEXT,
        nextInvoiceNumber INTEGER,
        termsAndConditions TEXT,
        logoPath TEXT
      )
    ''');

    // 2. Users (Authentication & Roles)
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        shopId TEXT,
        createdAt TEXT
      )
    ''');

    // 3. Spare Parts (Inventory)
    await db.execute('''
      CREATE TABLE parts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        partNumber TEXT,
        brand TEXT,
        hsnCode TEXT,
        category TEXT,
        purchasePrice REAL NOT NULL,
        sellingPrice REAL NOT NULL,
        gstRate REAL NOT NULL,
        stockQuantity REAL NOT NULL,
        minStockAlert REAL NOT NULL,
        unit TEXT,
        barcode TEXT,
        isGstInclusive INTEGER NOT NULL,
        createdAt TEXT
      )
    ''');

    // 4. Customers
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        vehicleNumber TEXT,
        address TEXT,
        state TEXT,
        gstin TEXT,
        pendingBalance REAL,
        totalPurchases REAL,
        invoiceCount INTEGER,
        createdAt TEXT
      )
    ''');

    // 5. Stock Movement History
    await db.execute('''
      CREATE TABLE stock_history (
        id TEXT PRIMARY KEY,
        partId TEXT NOT NULL,
        partName TEXT NOT NULL,
        changeType TEXT NOT NULL,
        quantityChange REAL NOT NULL,
        resultingStock REAL NOT NULL,
        referenceNumber TEXT,
        notes TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    // 6. Invoices (Billing)
    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        invoiceNumber TEXT NOT NULL,
        customerId TEXT,
        customerName TEXT NOT NULL,
        customerPhone TEXT,
        vehicleNumber TEXT,
        customerAddress TEXT,
        customerGstin TEXT,
        customerState TEXT,
        date TEXT NOT NULL,
        itemsJson TEXT NOT NULL,
        isGstInclusive INTEGER NOT NULL,
        isInterState INTEGER NOT NULL,
        subtotalTaxable REAL NOT NULL,
        cgstTotal REAL NOT NULL,
        sgstTotal REAL NOT NULL,
        igstTotal REAL NOT NULL,
        totalTax REAL NOT NULL,
        discountTotal REAL NOT NULL,
        roundOff REAL NOT NULL,
        grandTotal REAL NOT NULL,
        paymentMode TEXT NOT NULL,
        paidAmount REAL NOT NULL,
        balanceDue REAL NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        createdBy TEXT
      )
    ''');

    // 7. Suppliers
    await db.execute('''
      CREATE TABLE suppliers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        company TEXT,
        phone TEXT,
        email TEXT,
        gstin TEXT,
        address TEXT,
        state TEXT,
        createdAt TEXT
      )
    ''');

    // 8. Purchases
    await db.execute('''
      CREATE TABLE purchases (
        id TEXT PRIMARY KEY,
        purchaseInvoiceNumber TEXT NOT NULL,
        supplierId TEXT NOT NULL,
        supplierName TEXT NOT NULL,
        date TEXT NOT NULL,
        itemsJson TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        notes TEXT
      )
    ''');

    // 9. Pre-Owned Vehicles for Sale (Used Cars & Bikes)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS used_vehicles (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        vehicleType TEXT NOT NULL,
        brand TEXT NOT NULL,
        year INTEGER NOT NULL,
        regNumber TEXT NOT NULL,
        kmDriven INTEGER NOT NULL,
        fuelType TEXT NOT NULL,
        transmission TEXT,
        ownershipCount INTEGER,
        sellingPrice REAL NOT NULL,
        isNegotiable INTEGER,
        insuranceValidity TEXT,
        status TEXT NOT NULL,
        inspectionScore TEXT,
        features TEXT,
        description TEXT,
        contactPhone TEXT,
        sellerName TEXT,
        createdAt TEXT
      )
    ''');

    // Seed Initial Data
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // 1. Shop Profile (AATHAVA MOTORS)
    await db.insert('shop_profile', SampleData.defaultShop.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    // 2. Users (Admin, User, Worker for login)
    for (final user in SampleData.defaultUsers) {
      await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 3. Customer: Mr. Satheesh Kumar
    await db.insert('customers', SampleData.defaultCustomers.first.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    // 4. Spare parts from Bill 081
    for (final part in SampleData.defaultParts) {
      await db.insert('parts', part.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 5. Add ONLY this Bill: Bill No. 081 (Rs. 42,520)
    await db.insert('invoices', SampleData.aathavaBill081.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _ensureAathavaMotorsSeedData(Database db) async {
    try {
      // 1. Update/insert AATHAVA MOTORS Shop Profile
      final shopCheck = await db.query('shop_profile', limit: 1);
      if (shopCheck.isEmpty) {
        await db.insert('shop_profile', SampleData.defaultShop.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      } else {
        final currentShop = shopCheck.first;
        if (currentShop['shopName'] != 'AATHAVA MOTORS') {
          await db.update('shop_profile', SampleData.defaultShop.toMap(), where: 'id = ?', whereArgs: [currentShop['id']]);
        }
      }

      // 2. Customer: Mr. Sathish Kumar (Phone: 89517 77054)
      await db.insert('customers', SampleData.defaultCustomers.first.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

      // 2b. User account for Customer Portal login
      await db.insert('users', SampleData.defaultUsers[1].toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

      // 3. Spare parts from Bill 081
      for (final part in SampleData.defaultParts) {
        await db.insert('parts', part.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // 4. Add ONLY this Bill: Bill No. 081 (Rs. 42,520)
      await db.insert('invoices', SampleData.aathavaBill081.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

      // 5. Pre-Owned Cars & Bikes for Sale
      await db.execute('''
        CREATE TABLE IF NOT EXISTS used_vehicles (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          vehicleType TEXT NOT NULL,
          brand TEXT NOT NULL,
          year INTEGER NOT NULL,
          regNumber TEXT NOT NULL,
          kmDriven INTEGER NOT NULL,
          fuelType TEXT NOT NULL,
          transmission TEXT,
          ownershipCount INTEGER,
          sellingPrice REAL NOT NULL,
          isNegotiable INTEGER,
          insuranceValidity TEXT,
          status TEXT NOT NULL,
          inspectionScore TEXT,
          features TEXT,
          description TEXT,
          contactPhone TEXT,
          sellerName TEXT,
          createdAt TEXT
        )
      ''');

      final existingVehicles = await db.query('used_vehicles', limit: 1);
      if (existingVehicles.isEmpty) {
        for (final v in SampleData.defaultUsedVehicles) {
          await db.insert('used_vehicles', v.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    } catch (_) {}
  }

  /// Full purge helper to clear all transactions and inventory
  Future<void> clearAllDummyData() async {
    final db = await database;
    await db.delete('invoices');
    await db.delete('purchases');
    await db.delete('stock_history');
    await db.delete('customers');
    await db.delete('parts');
    await db.delete('suppliers');
  }

  // ==================== SHOP PROFILE ====================
  Future<ShopProfileModel> getShopProfile() async {
    final db = await database;
    final res = await db.query('shop_profile', limit: 1);
    if (res.isNotEmpty) {
      return ShopProfileModel.fromMap(res.first);
    }
    // fallback
    await db.insert('shop_profile', SampleData.defaultShop.toMap());
    return SampleData.defaultShop;
  }

  Future<void> updateShopProfile(ShopProfileModel profile) async {
    final db = await database;
    await db.update(
      'shop_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // ==================== USERS & AUTH ====================
  Future<UserModel?> authenticateUser(String email, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'LOWER(email) = ? AND password = ?',
      whereArgs: [email.toLowerCase().trim(), password],
    );
    if (res.isNotEmpty) {
      return UserModel.fromMap(res.first);
    }
    return null;
  }

  Future<UserModel?> getUserByPhone(String phone) async {
    final db = await database;
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final res = await db.query('users');
    for (final row in res) {
      final userPhone = (row['phone'] as String).replaceAll(RegExp(r'\D'), '');
      if (userPhone.endsWith(cleanPhone) || cleanPhone.endsWith(userPhone)) {
        return UserModel.fromMap(row);
      }
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final res = await db.query('users');
    return res.map((m) => UserModel.fromMap(m)).toList();
  }

  Future<void> insertUser(UserModel user) async {
    final db = await database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ==================== PARTS (INVENTORY) ====================
  Future<List<PartModel>> getAllParts() async {
    final db = await database;
    final res = await db.query('parts', orderBy: 'name ASC');
    return res.map((m) => PartModel.fromMap(m)).toList();
  }

  Future<PartModel?> getPartById(String id) async {
    final db = await database;
    final res = await db.query('parts', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) {
      return PartModel.fromMap(res.first);
    }
    return null;
  }

  Future<PartModel?> getPartByBarcode(String barcode) async {
    final db = await database;
    final res = await db.query('parts', where: 'barcode = ?', whereArgs: [barcode]);
    if (res.isNotEmpty) {
      return PartModel.fromMap(res.first);
    }
    return null;
  }

  Future<void> insertPart(PartModel part) async {
    final db = await database;
    await db.insert('parts', part.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePart(PartModel part) async {
    final db = await database;
    await db.update('parts', part.toMap(), where: 'id = ?', whereArgs: [part.id]);
  }

  Future<void> deletePart(String id) async {
    final db = await database;
    await db.delete('parts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updatePartStock(String partId, double newStock) async {
    final db = await database;
    await db.update('parts', {'stockQuantity': newStock}, where: 'id = ?', whereArgs: [partId]);
  }

  // ==================== CUSTOMERS ====================
  Future<List<CustomerModel>> getAllCustomers() async {
    final db = await database;
    final res = await db.query('customers', orderBy: 'name ASC');
    return res.map((m) => CustomerModel.fromMap(m)).toList();
  }

  Future<CustomerModel?> getCustomerById(String id) async {
    final db = await database;
    final res = await db.query('customers', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) {
      return CustomerModel.fromMap(res.first);
    }
    return null;
  }

  Future<void> insertCustomer(CustomerModel customer) async {
    final db = await database;
    await db.insert('customers', customer.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    final db = await database;
    await db.update('customers', customer.toMap(), where: 'id = ?', whereArgs: [customer.id]);
  }

  Future<void> deleteCustomer(String id) async {
    final db = await database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateCustomerBalance(String customerId, double balanceChange, double purchaseAmountChange, {bool incrementInvoice = false}) async {
    final db = await database;
    final cust = await getCustomerById(customerId);
    if (cust != null) {
      final newBalance = (cust.pendingBalance + balanceChange).clamp(0.0, double.infinity);
      final newPurchases = cust.totalPurchases + purchaseAmountChange;
      final newInvoiceCount = cust.invoiceCount + (incrementInvoice ? 1 : 0);

      await db.update(
        'customers',
        {
          'pendingBalance': newBalance,
          'totalPurchases': newPurchases,
          'invoiceCount': newInvoiceCount,
        },
        where: 'id = ?',
        whereArgs: [customerId],
      );
    }
  }

  // ==================== STOCK HISTORY ====================
  Future<List<StockHistoryModel>> getAllStockHistory() async {
    final db = await database;
    final res = await db.query('stock_history', orderBy: 'timestamp DESC');
    return res.map((m) => StockHistoryModel.fromMap(m)).toList();
  }

  Future<List<StockHistoryModel>> getStockHistoryByPart(String partId) async {
    final db = await database;
    final res = await db.query('stock_history', where: 'partId = ?', whereArgs: [partId], orderBy: 'timestamp DESC');
    return res.map((m) => StockHistoryModel.fromMap(m)).toList();
  }

  Future<void> insertStockHistory(StockHistoryModel history) async {
    final db = await database;
    await db.insert('stock_history', history.toMap());
  }

  // ==================== INVOICES ====================
  Future<List<InvoiceModel>> getAllInvoices() async {
    final db = await database;
    final res = await db.query('invoices', orderBy: 'date DESC');
    return res.map((m) => InvoiceModel.fromMap(m)).toList();
  }

  Future<InvoiceModel?> getInvoiceById(String id) async {
    final db = await database;
    final res = await db.query('invoices', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) {
      return InvoiceModel.fromMap(res.first);
    }
    return null;
  }

  Future<void> insertInvoice(InvoiceModel invoice) async {
    final db = await database;
    await db.insert('invoices', invoice.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateInvoice(InvoiceModel invoice) async {
    final db = await database;
    await db.update('invoices', invoice.toMap(), where: 'id = ?', whereArgs: [invoice.id]);
  }

  // ==================== SUPPLIERS ====================
  Future<List<SupplierModel>> getAllSuppliers() async {
    final db = await database;
    final res = await db.query('suppliers', orderBy: 'name ASC');
    return res.map((m) => SupplierModel.fromMap(m)).toList();
  }

  Future<void> insertSupplier(SupplierModel supplier) async {
    final db = await database;
    await db.insert('suppliers', supplier.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    final db = await database;
    await db.update('suppliers', supplier.toMap(), where: 'id = ?', whereArgs: [supplier.id]);
  }

  Future<void> deleteSupplier(String id) async {
    final db = await database;
    await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== PURCHASES ====================
  Future<List<PurchaseModel>> getAllPurchases() async {
    final db = await database;
    final res = await db.query('purchases', orderBy: 'date DESC');
    return res.map((m) => PurchaseModel.fromMap(m)).toList();
  }

  Future<void> insertPurchase(PurchaseModel purchase) async {
    final db = await database;
    await db.insert('purchases', purchase.toMap());
  }

  // ==================== BACKUP & RESTORE ====================
  Future<Map<String, dynamic>> dumpEntireDatabase() async {
    final profile = await getShopProfile();
    final users = await getAllUsers();
    final parts = await getAllParts();
    final customers = await getAllCustomers();
    final invoices = await getAllInvoices();
    final stockHistory = await getAllStockHistory();
    final suppliers = await getAllSuppliers();
    final purchases = await getAllPurchases();

    return {
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'shop_profile': profile.toMap(),
      'users': users.map((u) => u.toMap()).toList(),
      'parts': parts.map((p) => p.toMap()).toList(),
      'customers': customers.map((c) => c.toMap()).toList(),
      'invoices': invoices.map((i) => i.toMap()).toList(),
      'stock_history': stockHistory.map((s) => s.toMap()).toList(),
      'suppliers': suppliers.map((s) => s.toMap()).toList(),
      'purchases': purchases.map((p) => p.toMap()).toList(),
    };
  }

  Future<void> restoreEntireDatabase(Map<String, dynamic> data) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('shop_profile');
      await txn.delete('users');
      await txn.delete('parts');
      await txn.delete('customers');
      await txn.delete('invoices');
      await txn.delete('stock_history');
      await txn.delete('suppliers');
      await txn.delete('purchases');

      if (data['shop_profile'] != null) {
        await txn.insert('shop_profile', data['shop_profile'] as Map<String, dynamic>);
      }
      if (data['users'] != null) {
        for (final item in (data['users'] as List)) {
          await txn.insert('users', item as Map<String, dynamic>);
        }
      }
      if (data['parts'] != null) {
        for (final item in (data['parts'] as List)) {
          await txn.insert('parts', item as Map<String, dynamic>);
        }
      }
      if (data['customers'] != null) {
        for (final item in (data['customers'] as List)) {
          await txn.insert('customers', item as Map<String, dynamic>);
        }
      }
      if (data['invoices'] != null) {
        for (final item in (data['invoices'] as List)) {
          await txn.insert('invoices', item as Map<String, dynamic>);
        }
      }
      if (data['stock_history'] != null) {
        for (final item in (data['stock_history'] as List)) {
          await txn.insert('stock_history', item as Map<String, dynamic>);
        }
      }
      if (data['suppliers'] != null) {
        for (final item in (data['suppliers'] as List)) {
          await txn.insert('suppliers', item as Map<String, dynamic>);
        }
      }
      if (data['purchases'] != null) {
        for (final item in (data['purchases'] as List)) {
          await txn.insert('purchases', item as Map<String, dynamic>);
        }
      }
    });
  }

  // ==================== USED VEHICLES (CARS & BIKES) ====================

  Future<List<UsedVehicleModel>> getUsedVehicles() async {
    final db = await database;
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS used_vehicles (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          vehicleType TEXT NOT NULL,
          brand TEXT NOT NULL,
          year INTEGER NOT NULL,
          regNumber TEXT NOT NULL,
          kmDriven INTEGER NOT NULL,
          fuelType TEXT NOT NULL,
          transmission TEXT,
          ownershipCount INTEGER,
          sellingPrice REAL NOT NULL,
          isNegotiable INTEGER,
          insuranceValidity TEXT,
          status TEXT NOT NULL,
          inspectionScore TEXT,
          features TEXT,
          description TEXT,
          contactPhone TEXT,
          sellerName TEXT,
          createdAt TEXT
        )
      ''');
      final result = await db.query('used_vehicles', orderBy: 'createdAt DESC');
      if (result.isEmpty) {
        for (final v in SampleData.defaultUsedVehicles) {
          await db.insert('used_vehicles', v.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        }
        return SampleData.defaultUsedVehicles;
      }
      return result.map((m) => UsedVehicleModel.fromMap(m)).toList();
    } catch (_) {
      return SampleData.defaultUsedVehicles;
    }
  }

  Future<int> insertUsedVehicle(UsedVehicleModel vehicle) async {
    final db = await database;
    return await db.insert('used_vehicles', vehicle.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateUsedVehicle(UsedVehicleModel vehicle) async {
    final db = await database;
    return await db.update('used_vehicles', vehicle.toMap(), where: 'id = ?', whereArgs: [vehicle.id]);
  }

  Future<int> deleteUsedVehicle(String id) async {
    final db = await database;
    return await db.delete('used_vehicles', where: 'id = ?', whereArgs: [id]);
  }
}
