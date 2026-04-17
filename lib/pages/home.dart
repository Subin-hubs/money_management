import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/transaction.dart';
import '../../models/transaction_type.dart';
import '../../controllers/home_controller.dart';
import '../features/notficatation/notificatation_service.dart';

// ─── Design Tokens ───────────────────────────────────────────────────────────
class _C {
  static const bg          = Color(0xFFF2EFE9);
  static const surface     = Color(0xFFFFFFFF);
  static const ink         = Color(0xFF1C1917);
  static const accent      = Color(0xFF2D6A4F);
  static const accentLight = Color(0xFFD8F3DC);
  static const green       = Color(0xFF2D6A4F);
  static const red         = Color(0xFFB5383A);
  static const redLight    = Color(0xFFFBEAEA);
  static const amber       = Color(0xFFC77D24);
  static const amberLight  = Color(0xFFFFF3E0);
  static const muted       = Color(0xFF9E9C98);
  static const divider     = Color(0xFFE8E5DF);
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
IconData _catIcon(String label) {
  switch (label.toLowerCase()) {
    case 'food':          return Icons.restaurant_rounded;
    case 'transport':     return Icons.directions_bus_rounded;
    case 'shopping':      return Icons.shopping_bag_rounded;
    case 'health':        return Icons.favorite_rounded;
    case 'education':     return Icons.school_rounded;
    case 'salary':
    case 'income':        return Icons.account_balance_wallet_rounded;
    case 'rent':          return Icons.home_rounded;
    case 'entertainment': return Icons.movie_rounded;
    default:              return Icons.receipt_long_rounded;
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// ─────────────────────────────────────────────────────────────────────────────
//  HOME PAGE
// ─────────────────────────────────────────────────────────────────────────────
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final controller = HomeController();
  AnimationController? _fadeCtrl;
  Animation<double> _fadeAnim = const AlwaysStoppedAnimation(1.0);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl!, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txBox      = Hive.box<TransactionModel>('transactions');
    final pendingBox = Hive.box<TransactionModel>('pending_transactions');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: _C.bg,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [

              // ── App Bar ────────────────────────────────────────────────────
              _SliverHeader(pendingBox: pendingBox),

              // ── Balance Card ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: ValueListenableBuilder(
                  valueListenable: txBox.listenable(),
                  builder: (_, Box<TransactionModel> box, __) {
                    double inc = 0, exp = 0;
                    for (var t in box.values) {
                      t.type == TransactionType.income
                          ? inc += t.amount
                          : exp += t.amount;
                    }
                    return _BalanceCard(balance: inc - exp, income: inc, expense: exp);
                  },
                ),
              ),

              // ── Spending Chart ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: ValueListenableBuilder(
                  valueListenable: txBox.listenable(),
                  builder: (_, Box<TransactionModel> box, __) {
                    return _SpendingChart(transactions: box.values.toList());
                  },
                ),
              ),

              // ── Pending Card ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: ValueListenableBuilder(
                  valueListenable: pendingBox.listenable(),
                  builder: (_, Box<TransactionModel> box, __) {
                    if (box.isEmpty) return const SizedBox.shrink();
                    return _PendingCard(box: box);
                  },
                ),
              ),

              // ── Recent Header + View All ───────────────────────────────────
              SliverToBoxAdapter(
                child: ValueListenableBuilder(
                  valueListenable: txBox.listenable(),
                  builder: (_, Box<TransactionModel> box, __) {
                    final hasMore = box.length > 4;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 16, 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Recent",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _C.ink,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const Spacer(),
                          if (hasMore)
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AllTransactionsPage(txBox: box),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _C.accentLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      "View all",
                                      style: TextStyle(
                                        color: _C.accent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 3),
                                    Icon(Icons.arrow_forward_rounded,
                                        size: 13, color: _C.accent),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Last 4 Transactions ────────────────────────────────────────
              ValueListenableBuilder(
                valueListenable: txBox.listenable(),
                builder: (_, Box<TransactionModel> box, __) {
                  final list = box.values.toList().reversed.toList();
                  if (list.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(),
                    );
                  }
                  final recent = list.take(4).toList();
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (_, index) {
                        final tx = recent[index];
                        final showDate = index == 0 ||
                            !_sameDay(tx.date, recent[index - 1].date);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDate) _DateChip(date: tx.date),
                            _TransactionTile(
                              tx: tx,
                              onDelete: () async {
                                HapticFeedback.mediumImpact();
                                final realIndex =
                                box.values.toList().indexOf(tx);
                                if (realIndex >= 0) {
                                  await box.deleteAt(realIndex);
                                }
                              },
                            ),
                          ],
                        );
                      },
                      childCount: recent.length,
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ALL TRANSACTIONS PAGE
// ─────────────────────────────────────────────────────────────────────────────
class AllTransactionsPage extends StatelessWidget {
  final Box<TransactionModel> txBox;
  const AllTransactionsPage({super.key, required this.txBox});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _C.surface,
              shape: BoxShape.circle,
              border: Border.all(color: _C.divider),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                size: 18, color: _C.ink),
          ),
        ),
        title: const Text(
          "All Transactions",
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: _C.ink,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: txBox.listenable(),
        builder: (_, Box<TransactionModel> box, __) {
          final list = box.values.toList().reversed.toList();

          if (list.isEmpty) {
            return const _EmptyState();
          }

          // Group by date
          final Map<String, List<TransactionModel>> grouped = {};
          for (final tx in list) {
            final key = DateFormat('yyyy-MM-dd').format(tx.date);
            grouped.putIfAbsent(key, () => []).add(tx);
          }
          final keys = grouped.keys.toList();

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: keys.length,
            itemBuilder: (_, groupIndex) {
              final key    = keys[groupIndex];
              final dayTxs = grouped[key]!;
              final date   = DateFormat('yyyy-MM-dd').parse(key);

              double dayNet = 0;
              for (final t in dayTxs) {
                dayNet += t.type == TransactionType.income
                    ? t.amount
                    : -t.amount;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: Row(
                      children: [
                        _DateChip(date: date),
                        const Spacer(),
                        Text(
                          "${dayNet >= 0 ? '+' : ''}रु${NumberFormat('#,##0').format(dayNet)}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: dayNet >= 0 ? _C.green : _C.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...dayTxs.map((tx) => _TransactionTile(
                    tx: tx,
                    showTime: true,
                    onDelete: () async {
                      HapticFeedback.mediumImpact();
                      final realIndex = box.values.toList().indexOf(tx);
                      if (realIndex >= 0) await box.deleteAt(realIndex);
                    },
                  )),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SPENDING CHART  (last 7 days / 4 weeks — zero dependencies)
// ─────────────────────────────────────────────────────────────────────────────
class _SpendingChart extends StatefulWidget {
  final List<TransactionModel> transactions;
  const _SpendingChart({required this.transactions});

  @override
  State<_SpendingChart> createState() => _SpendingChartState();
}

class _SpendingChartState extends State<_SpendingChart>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  AnimationController? _barCtrl;
  Animation<double> _barAnim = const AlwaysStoppedAnimation(1.0);

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _barAnim =
        CurvedAnimation(parent: _barCtrl!, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _barCtrl?.dispose();
    super.dispose();
  }

  void _switchTab(int t) {
    if (_tab == t) return;
    setState(() => _tab = t);
    _barCtrl?.forward(from: 0);
  }

  List<_BarData> _weekData() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      double inc = 0, exp = 0;
      for (final t in widget.transactions) {
        if (_sameDay(t.date, day)) {
          t.type == TransactionType.income
              ? inc += t.amount
              : exp += t.amount;
        }
      }
      return _BarData(
        label: DateFormat('E').format(day).substring(0, 1),
        income: inc,
        expense: exp,
        isToday: _sameDay(day, now),
      );
    });
  }

  List<_BarData> _monthData() {
    final now = DateTime.now();
    return List.generate(4, (i) {
      final wEnd   = now.subtract(Duration(days: (3 - i) * 7));
      final wStart = now.subtract(Duration(days: (3 - i) * 7 + 6));
      double inc = 0, exp = 0;
      for (final t in widget.transactions) {
        final d = DateTime(t.date.year, t.date.month, t.date.day);
        final s = DateTime(wStart.year, wStart.month, wStart.day);
        final e = DateTime(wEnd.year, wEnd.month, wEnd.day);
        if (!d.isBefore(s) && !d.isAfter(e)) {
          t.type == TransactionType.income
              ? inc += t.amount
              : exp += t.amount;
        }
      }
      return _BarData(
          label: "W${i + 1}", income: inc, expense: exp, isToday: i == 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data   = _tab == 0 ? _weekData() : _monthData();
    final maxVal = data.map((d) => max(d.income, d.expense)).fold(0.0, max);
    final totalInc = data.fold(0.0, (s, d) => s + d.income);
    final totalExp = data.fold(0.0, (s, d) => s + d.expense);
    final fmt = NumberFormat('#,##0');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Row(
            children: [
              const Text("Overview",
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _C.ink,
                    letterSpacing: -0.3,
                  )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: _C.bg, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    _TabBtn(label: "Week",  active: _tab == 0, onTap: () => _switchTab(0)),
                    _TabBtn(label: "Month", active: _tab == 1, onTap: () => _switchTab(1)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Legend
          Row(
            children: [
              _LegendDot(color: _C.green, label: "Income",  amount: "रु${fmt.format(totalInc)}"),
              const SizedBox(width: 16),
              _LegendDot(color: _C.red,   label: "Expense", amount: "रु${fmt.format(totalExp)}"),
            ],
          ),

          const SizedBox(height: 20),

          // Bars
          AnimatedBuilder(
            animation: _barAnim,
            builder: (_, __) => SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data
                    .map((bar) => Expanded(
                  child: _BarGroup(
                    data: bar,
                    maxVal: maxVal == 0 ? 1 : maxVal,
                    animValue: _barAnim.value,
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarData {
  final String label;
  final double income, expense;
  final bool isToday;
  const _BarData(
      {required this.label,
        required this.income,
        required this.expense,
        required this.isToday});
}

class _BarGroup extends StatelessWidget {
  final _BarData data;
  final double maxVal, animValue;
  const _BarGroup(
      {required this.data, required this.maxVal, required this.animValue});

  @override
  Widget build(BuildContext context) {
    const maxH = 100.0;
    final incH = (data.income / maxVal) * maxH * animValue;
    final expH = (data.expense / maxVal) * maxH * animValue;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Bar(height: incH,
                color: data.isToday ? _C.green : _C.green.withOpacity(0.4)),
            const SizedBox(width: 3),
            _Bar(height: expH,
                color: data.isToday ? _C.red : _C.red.withOpacity(0.4)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          data.label,
          style: TextStyle(
            fontSize: 11,
            color: data.isToday ? _C.ink : _C.muted,
            fontWeight:
            data.isToday ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final Color color;
  const _Bar({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    final h = height < 4 && height > 0 ? 4.0 : height;
    return Container(
      width: 10,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(5)),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: active ? _C.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 1))
          ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? _C.ink : _C.muted,
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label, amount;
  const _LegendDot(
      {required this.color, required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration:
            BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, color: _C.muted)),
        const SizedBox(width: 4),
        Text(amount,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _C.ink)),
      ],
    );
  }
}

// ─── Sliver Header ───────────────────────────────────────────────────────────
class _SliverHeader extends StatelessWidget {
  final Box<TransactionModel> pendingBox;
  const _SliverHeader({required this.pendingBox});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: _C.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      title: Row(children: [
        const Text("Budget",
            style: TextStyle(
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: _C.ink,
              letterSpacing: -0.5,
            )),
        const Text("Track",
            style: TextStyle(
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w400,
              fontSize: 22,
              color: _C.muted,
              letterSpacing: -0.5,
            )),
      ]),
      actions: [_NotifBtn(pendingBox: pendingBox), const SizedBox(width: 12)],
    );
  }
}

class _NotifBtn extends StatelessWidget {
  final Box<TransactionModel> pendingBox;
  const _NotifBtn({required this.pendingBox});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: pendingBox.listenable(),
      builder: (_, Box<TransactionModel> box, __) {
        final has = box.isNotEmpty;
        return GestureDetector(
          onTap: () async {
            HapticFeedback.selectionClick();
            await NotificationService.showNotification(
              title: "Test Notification",
              body: "Rs 500 debited from account",
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: has ? _C.amberLight : _C.surface,
              shape: BoxShape.circle,
              border: Border.all(
                  color: has ? _C.amber.withOpacity(0.4) : _C.divider),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_none_rounded,
                    size: 20, color: has ? _C.amber : _C.ink),
                if (has)
                  Positioned(
                    top: -2, right: -2,
                    child: Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                          color: _C.amber, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Balance Card ─────────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final double balance, income, expense;
  const _BalanceCard(
      {required this.balance, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
          color: _C.accent, borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            right: -30, top: -30,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06)),
            ),
          ),
          Positioned(
            right: 30, bottom: -40,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Balance",
                    style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text("रु ${fmt.format(balance)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Georgia',
                      letterSpacing: -1,
                      height: 1.1,
                    )),
                const SizedBox(height: 24),
                Row(children: [
                  _BalStat(
                      icon: Icons.south_west_rounded,
                      label: "Income",
                      amount: fmt.format(income)),
                  const SizedBox(width: 12),
                  Container(width: 1, height: 36, color: Colors.white24),
                  const SizedBox(width: 12),
                  _BalStat(
                      icon: Icons.north_east_rounded,
                      label: "Expense",
                      amount: fmt.format(expense)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalStat extends StatelessWidget {
  final IconData icon;
  final String label, amount;
  const _BalStat(
      {required this.icon, required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white54, fontSize: 11, letterSpacing: 0.3)),
        Text("रु $amount",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ]),
    ]);
  }
}

// ─── Pending Card ─────────────────────────────────────────────────────────────
class _PendingCard extends StatelessWidget {
  final Box<TransactionModel> box;
  const _PendingCard({required this.box});

  @override
  Widget build(BuildContext context) {
    final pending = box.getAt(0)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.amberLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.amber.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: _C.amber.withOpacity(0.15),
                  shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: _C.amber, size: 16),
            ),
            const SizedBox(width: 10),
            const Text("Auto-Detected Transaction",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: _C.amber)),
          ]),
          const SizedBox(height: 12),
          Text(
            "रु ${NumberFormat('#,##0.00').format(pending.amount)}",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFamily: 'Georgia',
              color: _C.ink,
              letterSpacing: -0.5,
            ),
          ),
          if (pending.note != null && pending.note!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(pending.note!,
                style: const TextStyle(color: _C.muted, fontSize: 13)),
          ],
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _C.muted,
                  side: const BorderSide(color: _C.divider),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await box.deleteAt(0);
                },
                child: const Text("Ignore",
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.amber,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  final mainBox =
                  Hive.box<TransactionModel>('transactions');
                  final newTx = TransactionModel(
                    type: pending.type,
                    amount: pending.amount,
                    category: pending.category,
                    date: DateTime.now(),
                    note: pending.note,
                  );
                  await mainBox.add(newTx);
                  await box.deleteAt(0);
                },
                child: const Text("Confirm",
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ─── Date Chip ───────────────────────────────────────────────────────────────
class _DateChip extends StatelessWidget {
  final DateTime date;
  const _DateChip({required this.date});

  String _label() {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = DateTime(date.year, date.month, date.day);
    if (d == today) return "Today";
    if (d == today.subtract(const Duration(days: 1))) return "Yesterday";
    return DateFormat('MMMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 0, 4),
      child: Text(_label(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _C.muted,
            letterSpacing: 0.7,
          )),
    );
  }
}

// ─── Transaction Tile ─────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback onDelete;
  final bool showTime;
  const _TransactionTile(
      {required this.tx, required this.onDelete, this.showTime = true});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == TransactionType.income;
    final color    = isIncome ? _C.green : _C.red;
    final bgColor  = isIncome ? _C.accentLight : _C.redLight;
    final sign     = isIncome ? "+" : "−";
    final fmt      = NumberFormat('#,##0.00');

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: _C.redLight, borderRadius: BorderRadius.circular(16)),
        child:
        const Icon(Icons.delete_rounded, color: _C.red, size: 22),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.divider),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12)),
            child:
            Icon(_catIcon(tx.category.label), color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.category.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _C.ink)),
                if (tx.note != null && tx.note!.isNotEmpty)
                  Text(tx.note!,
                      style: const TextStyle(
                          fontSize: 12, color: _C.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("$sign रु${fmt.format(tx.amount)}",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.3,
                  )),
              if (showTime)
                Text(DateFormat('h:mm a').format(tx.date),
                    style: const TextStyle(
                        fontSize: 11, color: _C.muted)),
            ],
          ),
        ]),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _C.surface,
              shape: BoxShape.circle,
              border: Border.all(color: _C.divider, width: 1.5),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                size: 36, color: _C.muted),
          ),
          const SizedBox(height: 16),
          const Text("No transactions yet",
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18,
                color: _C.ink,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 6),
          const Text("Add your first one using the + button",
              style: TextStyle(fontSize: 13, color: _C.muted)),
        ],
      ),
    );
  }
}