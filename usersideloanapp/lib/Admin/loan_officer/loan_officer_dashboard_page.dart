import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'loan_officer_widgets.dart';

class LoanOfficerDashboardPage extends StatefulWidget {
  const LoanOfficerDashboardPage({Key? key}) : super(key: key);

  @override
  State<LoanOfficerDashboardPage> createState() =>
      _LoanOfficerDashboardPageState();
}

class _LoanOfficerDashboardPageState extends State<LoanOfficerDashboardPage> {
  List<LoanApplication> queue = [];
  LoanApplication? selectedApp;
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    queue = [
      LoanApplication(
        id: 'LA001',
        name: 'John Smith',
        loanType: 'Personal Loan',
        status: 'Under Review',
        credit: 720,
        amount: '\u20B9 5,00,000',
        date: DateTime(2024, 1, 15),
        tenureMonths: 36,
        interestRate: 12.5,
        documents: [
          DocumentModel(
            id: 'D1',
            name: 'Aadhaar Card',
            status: 'Verified',
            verifiedOn: DateTime(2024, 1, 16),
          ),
          DocumentModel(
            id: 'D2',
            name: 'PAN Card',
            status: 'Verified',
            verifiedOn: DateTime(2024, 1, 16),
          ),
          DocumentModel(
            id: 'D3',
            name: 'Salary Slip (3 months)',
            status: 'Pending',
          ),
          DocumentModel(id: 'D4', name: 'Bank Statement', status: 'Pending'),
        ],
      ),
      LoanApplication(
        id: 'LA002',
        name: 'Emily Davis',
        loanType: 'Home Loan',
        status: 'Manager Review',
        credit: 750,
        amount: '\u20B9 2,50,000',
        date: DateTime(2024, 1, 20),
        tenureMonths: 240,
        interestRate: 9.2,
        documents: [
          DocumentModel(id: 'D1', name: 'Aadhaar Card', status: 'Pending'),
          DocumentModel(id: 'D2', name: 'PAN Card', status: 'Pending'),
        ],
      ),
      LoanApplication(
        id: 'LA003',
        name: 'Michael Chen',
        loanType: 'Vehicle Loan',
        status: 'Submitted',
        credit: 695,
        amount: '\u20B9 8,00,000',
        date: DateTime(2024, 1, 25),
        tenureMonths: 60,
        interestRate: 11.0,
        documents: [],
      ),
    ];

    // default selection
    selectedApp = queue.isNotEmpty ? queue[0] : null;
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width > 900;

    final pendingReviews = queue
        .where(
          (a) =>
              a.status.toLowerCase() != 'approved' &&
              a.status.toLowerCase() != 'rejected',
        )
        .length;
    final slaBreaching = queue
        .where(
          (a) =>
              DateTime.now().difference(a.date).inHours > 48 &&
              a.status.toLowerCase() != 'approved' &&
              a.status.toLowerCase() != 'rejected',
        )
        .length;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            //if (wide) _buildSideNav(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Application Review',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Review and verify loan applications',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: searchCtrl,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Search applications',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const CircleAvatar(child: Text('SJ')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Stats
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        statCard(
                          icon: Icons.schedule,
                          title: 'Pending Verifications',
                          value: pendingReviews.toString(),
                          color: Colors.orange,
                        ),
                        statCard(
                          icon: Icons.check_circle,
                          title: 'Completed Today',
                          value: '1',
                          color: Colors.green,
                        ),
                        statCard(
                          icon: Icons.priority_high,
                          title: 'High Priority',
                          value: slaBreaching.toString(),
                          color: Colors.red,
                        ),
                        statCard(
                          icon: Icons.insert_drive_file,
                          title: 'Total Documents',
                          value: queue
                              .fold<int>(0, (p, c) => p + c.documents.length)
                              .toString(),
                          color: Colors.indigo,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Main content two columns
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left: applications list
                          Container(
                            width: 360,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Applications to Review',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Scrollbar(
                                        child: ListView.separated(
                                          itemCount: queue
                                              .where(
                                                (a) =>
                                                    a.name
                                                        .toLowerCase()
                                                        .contains(
                                                          searchCtrl.text
                                                              .toLowerCase(),
                                                        ) ||
                                                    a.id.toLowerCase().contains(
                                                      searchCtrl.text
                                                          .toLowerCase(),
                                                    ),
                                              )
                                              .length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 8),
                                          itemBuilder: (context, index) {
                                            final filtered = queue
                                                .where(
                                                  (a) =>
                                                      a.name
                                                          .toLowerCase()
                                                          .contains(
                                                            searchCtrl.text
                                                                .toLowerCase(),
                                                          ) ||
                                                      a.id
                                                          .toLowerCase()
                                                          .contains(
                                                            searchCtrl.text
                                                                .toLowerCase(),
                                                          ),
                                                )
                                                .toList();
                                            final app = filtered[index];
                                            return applicationListItem(
                                              app,
                                              selected:
                                                  selectedApp?.id == app.id,
                                              onTap: () => setState(
                                                () => selectedApp = app,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 18),

                          // Right: detail panel
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: selectedApp == null
                                    ? Center(
                                        child: Text(
                                          'Select an application to view details',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Header
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    selectedApp!.name,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    '${selectedApp!.id}  •  Applied on ${selectedApp!.date.toLocal().toString().split(' ')[0]}',
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: () =>
                                                        _changeStatus(
                                                          'Approved',
                                                        ),
                                                    icon: const Icon(
                                                      Icons.check,
                                                      color: Colors.green,
                                                    ),
                                                    label: const Text(
                                                      'Approve',
                                                    ),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.white,
                                                          foregroundColor:
                                                              Colors.black,
                                                          side:
                                                              const BorderSide(
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                        ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  ElevatedButton.icon(
                                                    onPressed: () =>
                                                        _changeStatus(
                                                          'On Hold',
                                                        ),
                                                    icon: const Icon(
                                                      Icons.pause,
                                                      color: Colors.orange,
                                                    ),
                                                    label: const Text('Hold'),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.white,
                                                          foregroundColor:
                                                              Colors.black,
                                                          side:
                                                              const BorderSide(
                                                                color: Colors
                                                                    .orange,
                                                              ),
                                                        ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  ElevatedButton.icon(
                                                    onPressed: () =>
                                                        _changeStatus(
                                                          'Rejected',
                                                        ),
                                                    icon: const Icon(
                                                      Icons.close,
                                                      color: Colors.red,
                                                    ),
                                                    label: const Text('Reject'),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.white,
                                                          foregroundColor:
                                                              Colors.black,
                                                          side:
                                                              const BorderSide(
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),

                                          // Tabs
                                          DefaultTabController(
                                            length: 4,
                                            child: Expanded(
                                              child: Column(
                                                children: [
                                                  TabBar(
                                                    labelColor: Colors.black87,
                                                    unselectedLabelColor:
                                                        Colors.grey,
                                                    tabs: const [
                                                      Tab(text: 'Loan Details'),
                                                      Tab(
                                                        text: 'Applicant Info',
                                                      ),
                                                      Tab(text: 'Documents'),
                                                      Tab(text: 'Eligibility'),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Expanded(
                                                    child: TabBarView(
                                                      children: [
                                                        // Loan Details
                                                        SingleChildScrollView(
                                                          child: Wrap(
                                                            spacing: 12,
                                                            runSpacing: 12,
                                                            children: [
                                                              _infoCard(
                                                                'Loan Type',
                                                                selectedApp!
                                                                    .loanType,
                                                              ),
                                                              _infoCard(
                                                                'Amount',
                                                                selectedApp!
                                                                    .amount,
                                                              ),
                                                              _infoCard(
                                                                'Tenure',
                                                                '${selectedApp!.tenureMonths} months',
                                                              ),
                                                              _infoCard(
                                                                'Interest Rate',
                                                                '${selectedApp!.interestRate}% p.a.',
                                                              ),
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      14,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .grey[100],
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Monthly EMI',
                                                                      style: TextStyle(
                                                                        color: Colors
                                                                            .grey[700],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    Text(
                                                                      '₹${_calculateEmi(selectedApp!).toStringAsFixed(0)}',
                                                                      style: const TextStyle(
                                                                        fontSize:
                                                                            22,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        // Applicant Info
                                                        SingleChildScrollView(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8.0,
                                                                ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: const [
                                                                Text(
                                                                  'Applicant details go here...',
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                        // Documents
                                                        SingleChildScrollView(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8.0,
                                                                ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Documents (${selectedApp!.documents.length})',
                                                                  style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 12,
                                                                ),
                                                                ...selectedApp!
                                                                    .documents
                                                                    .map(
                                                                      (
                                                                        d,
                                                                      ) => Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          vertical:
                                                                              6,
                                                                        ),
                                                                        child: documentRow(
                                                                          d,
                                                                          onReview: () async {
                                                                            final res = await showDocumentVerificationDialog(
                                                                              context,
                                                                              d,
                                                                              title: 'Verify ${d.name}',
                                                                            );
                                                                            setState(
                                                                              () {},
                                                                            );
                                                                            if (res ==
                                                                                true) {
                                                                              ScaffoldMessenger.of(
                                                                                context,
                                                                              ).showSnackBar(
                                                                                SnackBar(
                                                                                  content: Text(
                                                                                    '${d.name} verified',
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            } else if (res ==
                                                                                false) {
                                                                              ScaffoldMessenger.of(
                                                                                context,
                                                                              ).showSnackBar(
                                                                                SnackBar(
                                                                                  content: Text(
                                                                                    '${d.name} rejected',
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            }
                                                                          },
                                                                        ),
                                                                      ),
                                                                    )
                                                                    .toList(),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                        // Eligibility
                                                        SingleChildScrollView(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8.0,
                                                                ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: const [
                                                                Text(
                                                                  'Eligibility checks and scoring...',
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      //  drawer: wide ? null : Drawer(child: _buildSideNav()),
    );
  }

  double _calculateEmi(LoanApplication app) {
    // EMI formula: E = P*r*(1+r)^n/((1+r)^n-1)
    final p = _parseAmount(app.amount);
    final annual = app.interestRate / 100;
    final monthly = annual / 12;
    final n = app.tenureMonths;
    if (monthly <= 0 || n == 0) return 0;
    final pow = (1 + monthly);
    final factor = pow == 1 ? n : (pow == 0 ? 1 : Math.pow(1 + monthly, n));
    final emi = p * monthly * (factor) / (factor - 1);
    return emi;
  }

  double _parseAmount(String amount) {
    // remove non digits
    final digits = amount.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(digits) ?? 0.0;
  }

  void _changeStatus(String newStatus) {
    if (selectedApp == null) return;
    setState(() {
      selectedApp!.status = newStatus;
      // replace in queue as well
      final idx = queue.indexWhere((a) => a.id == selectedApp!.id);
      if (idx >= 0) queue[idx].status = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Application ${selectedApp!.id} marked as $newStatus'),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Widget _buildSideNav() {
  //   return Container(
  //     width: 260,
  //     color: const Color(0xFF1f2a36),
  //     padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: Colors.teal,
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: const Icon(Icons.account_balance, color: Colors.white),
  //             ),
  //             const SizedBox(width: 12),
  //             const Text(
  //               'LoanFlow',
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 24),
  //         _navItem(
  //           Icons.dashboard,
  //           'Dashboard',
  //           onTap: () => Navigator.pushReplacementNamed(
  //             context,
  //             '/loan_officer/dashboard',
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         _navItem(
  //           Icons.description,
  //           'Applications',
  //           onTap: () =>
  //               Navigator.pushNamed(context, '/loan_officer/applications'),
  //         ),
  //         const SizedBox(height: 8),
  //         _navItem(
  //           Icons.verified,
  //           'Verifications',
  //           onTap: () =>
  //               Navigator.pushNamed(context, '/loan_officer/verifications'),
  //         ),
  //         const Spacer(),
  //         Row(
  //           children: const [
  //             CircleAvatar(child: Text('SJ')),
  //             SizedBox(width: 8),
  //             Text('Sarah Johnson', style: TextStyle(color: Colors.white)),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _navItem(IconData icon, String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
