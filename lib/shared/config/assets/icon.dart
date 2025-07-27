import 'package:flutter/material.dart';

/// Essential icons for Agent Business Management Application
class AgentIcons {
  
  // ===== MAIN NAVIGATION =====
  static const IconData dashboard = Icons.dashboard_outlined;
  static const IconData dashboardFilled = Icons.dashboard;
  static const IconData orders = Icons.receipt_long_outlined;
  static const IconData ordersFilled = Icons.receipt_long;
  static const IconData inventory = Icons.inventory_2_outlined;
  static const IconData inventoryFilled = Icons.inventory_2;
  static const IconData customers = Icons.people_outline;
  static const IconData customersFilled = Icons.people;
  static const IconData analytics = Icons.analytics_outlined;
  static const IconData analyticsFilled = Icons.analytics;
  static const IconData chat = Icons.chat_outlined;
  static const IconData chatFilled = Icons.chat;
  static const IconData settings = Icons.settings_outlined;
  static const IconData settingsFilled = Icons.settings;
  
  // ===== AUTHENTICATION & PROFILE =====
  static const IconData login = Icons.login;
  static const IconData logout = Icons.logout;
  static const IconData profile = Icons.account_circle_outlined;
  static const IconData email = Icons.email_outlined;
  static const IconData phone = Icons.phone_outlined;
  static const IconData password = Icons.lock_outline;
  static const IconData verification = Icons.verified_user;
  
  // ===== BUSINESS OPERATIONS =====
  static const IconData business = Icons.business_outlined;
  static const IconData store = Icons.storefront_outlined;
  static const IconData sales = Icons.trending_up;
  static const IconData revenue = Icons.monetization_on_outlined;
  static const IconData performance = Icons.speed;
  
  // ===== ORDER MANAGEMENT =====
  static const IconData newOrder = Icons.add_shopping_cart;
  static const IconData orderPending = Icons.pending_actions;
  static const IconData orderConfirmed = Icons.check_circle_outline;
  static const IconData orderProcessing = Icons.autorenew;
  static const IconData orderDelivered = Icons.delivery_dining;
  static const IconData orderCancelled = Icons.cancel_outlined;
  static const IconData invoice = Icons.description_outlined;
  static const IconData payment = Icons.payment;
  
  // ===== INVENTORY MANAGEMENT =====
  static const IconData product = Icons.category_outlined;
  static const IconData productAdd = Icons.add_box_outlined;
  static const IconData productEdit = Icons.edit_outlined;
  static const IconData stock = Icons.inventory_outlined;
  static const IconData lowStock = Icons.warning_amber_outlined;
  static const IconData outOfStock = Icons.not_interested;
  static const IconData barcode = Icons.qr_code_scanner;
  
  // ===== CUSTOMER MANAGEMENT =====
  static const IconData customer = Icons.person_outline;
  static const IconData customerNew = Icons.person_add_outlined;
  static const IconData customerVip = Icons.star_outlined;
  static const IconData customerHistory = Icons.history;
  static const IconData customerFeedback = Icons.rate_review_outlined;
  
  // ===== COMMUNICATION =====
  static const IconData message = Icons.message_outlined;
  static const IconData send = Icons.send;
  static const IconData notification = Icons.notifications_outlined;
  static const IconData notificationFilled = Icons.notifications;
  
  // ===== ANALYTICS & REPORTS =====
  static const IconData chart = Icons.insert_chart_outlined;
  static const IconData report = Icons.assessment_outlined;
  static const IconData export = Icons.file_download_outlined;
  static const IconData filter = Icons.filter_list;
  
  // ===== ESSENTIAL ACTIONS =====
  static const IconData add = Icons.add;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline;
  static const IconData save = Icons.save_outlined;
  static const IconData cancel = Icons.cancel_outlined;
  static const IconData search = Icons.search;
  static const IconData refresh = Icons.refresh;
  static const IconData menu = Icons.menu;
  static const IconData back = Icons.arrow_back;
  static const IconData more = Icons.more_vert;
  
  // ===== STATUS INDICATORS =====
  static const IconData success = Icons.check_circle_outline;
  static const IconData error = Icons.error_outline;
  static const IconData warning = Icons.warning_amber_outlined;
  static const IconData info = Icons.info_outline;
  static const IconData loading = Icons.hourglass_empty;
  static const IconData done = Icons.done;
  static const IconData pending = Icons.pending;
  
  // ===== FILE & MEDIA =====
  static const IconData camera = Icons.camera_alt_outlined;
  static const IconData image = Icons.image_outlined;
  static const IconData upload = Icons.file_upload_outlined;
  static const IconData download = Icons.file_download_outlined;
  
  // ===== LOCATION & DELIVERY =====
  static const IconData location = Icons.location_on_outlined;
  static const IconData delivery = Icons.delivery_dining;
  static const IconData pickup = Icons.store_outlined;
  
  // ===== HELP & SUPPORT =====
  static const IconData help = Icons.help_outline;
  static const IconData support = Icons.support_outlined;
  static const IconData faq = Icons.quiz_outlined;
}

/// Business Type Icons for Agent Registration
class BusinessTypeIcons {
  static const IconData retail = Icons.storefront;
  static const IconData restaurant = Icons.restaurant;
  static const IconData electronics = Icons.electrical_services;
  static const IconData clothing = Icons.checkroom;
  static const IconData grocery = Icons.local_grocery_store;
  static const IconData pharmacy = Icons.local_pharmacy;
  static const IconData automotive = Icons.directions_car;
  static const IconData fitness = Icons.fitness_center;
  static const IconData healthcare = Icons.local_hospital;
  static const IconData other = Icons.business;
}

/// Order Status Icons
class OrderStatusIcons {
  static const Map<String, IconData> icons = {
    'pending': Icons.pending_actions,
    'confirmed': Icons.check_circle_outline,
    'processing': Icons.autorenew,
    'ready': Icons.done_all,
    'shipped': Icons.local_shipping,
    'delivered': Icons.check_circle,
    'cancelled': Icons.cancel,
    'returned': Icons.keyboard_return,
  };
}

/// Inventory Status Icons
class InventoryStatusIcons {
  static const Map<String, IconData> icons = {
    'in_stock': Icons.check_circle,
    'low_stock': Icons.warning_amber,
    'out_of_stock': Icons.cancel,
    'discontinued': Icons.not_interested,
  };
}

/// Agent Verification Status Icons
class VerificationStatusIcons {
  static const Map<String, IconData> icons = {
    'pending': Icons.pending,
    'approved': Icons.verified,
    'rejected': Icons.cancel,
    'suspended': Icons.block,
    'under_review': Icons.rate_review,
  };
}