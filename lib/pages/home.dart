import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/transaction.dart';
import '../../models/transaction_type.dart';
import '../../controllers/home_controller.dart';
import '../features/notficatation/notificatation_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = HomeController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),

      appBar: AppBar(
        title: const Text(
          "Student Budget",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),

      body: Column(
        children: [

          // 🔥 TEST BUTTON (Notification Reader Trigger)
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () async {
                await NotificationService.showNotification(
                  title: "Test Notification",
                  body: "Rs 500 debited from account",
                );
              },
              child: const Text("Test Notification Reader"),
            ),
          ),

          _buildSummaryHeader(),
          _buildPendingNotificationSection(),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Expanded(
            child: ValueListenableBuilder(
              valueListenable:
              Hive.box<TransactionModel>('transactions').listenable(),
              builder: (context, Box<TransactionModel> box, _) {
                final transactions =
                box.values.toList().reversed.toList();

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text("No transactions yet. Add some!"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                          tx.category.color.withOpacity(0.1),
                          child: Icon(
                            tx.category.icon,
                            color: tx.category.color,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          tx.category.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          tx.note ?? "No notes",
                          style:
                          TextStyle(color: Colors.grey.shade600),
                        ),
                        trailing: Text(
                          "${tx.type == TransactionType.income ? '+' : '-'} रु ${tx.amount}",
                          style: TextStyle(
                            color: tx.type == TransactionType.income
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
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

  // ── Pending Notification Section ──
  Widget _buildPendingNotificationSection() {
    return ValueListenableBuilder(
      valueListenable:
      Hive.box<TransactionModel>('pending_transactions').listenable(),
      builder: (context, Box<TransactionModel> box, _) {
        if (box.isEmpty) return const SizedBox.shrink();

        final pending = box.values.first;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text(
                    "Transaction Detected",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => box.deleteAt(0),
                  ),
                ],
              ),
              Text(
                "Found a spend of रु ${pending.amount}. Add this?",
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => box.deleteAt(0),
                      child: const Text("Ignore"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final mainBox =
                        Hive.box<TransactionModel>('transactions');

                        await mainBox.add(pending);
                        await box.deleteAt(0);

                        setState(() {}); // refresh UI
                      },
                      child: const Text("Confirm"),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            "Total Balance",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "रु ${controller.balance}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}