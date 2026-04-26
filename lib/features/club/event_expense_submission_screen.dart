// import 'dart:typed_data';

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../models/event_model.dart';
// import '../../providers/auth_provider.dart';

// class EventExpenseSubmissionScreen extends ConsumerStatefulWidget {
//   final String eventId;

//   const EventExpenseSubmissionScreen({
//     super.key,
//     required this.eventId,
//   });

//   @override
//   ConsumerState<EventExpenseSubmissionScreen> createState() =>
//       _EventExpenseSubmissionScreenState();
// }

// class _EventExpenseSubmissionScreenState
//     extends ConsumerState<EventExpenseSubmissionScreen> {
//   final _amountController = TextEditingController();
//   final _summaryController = TextEditingController();

//   final List<String> _fileTypes = const [
//     'BILL',
//     'INVOICE',
//     'CO',
//     'PO',
//     'OTHER',
//   ];

//   final Map<String, Uint8List?> _fileBytes = {};
//   final Map<String, String?> _fileNames = {};

//   bool _isSubmitting = false;

//   @override
//   void initState() {
//     super.initState();
//     for (final type in _fileTypes) {
//       _fileBytes[type] = null;
//       _fileNames[type] = null;
//     }
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _summaryController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickFile(String type) async {
//     final result = await FilePicker.pickFiles(withData: true);

//     if (result == null || result.files.isEmpty) return;

//     final file = result.files.first;

//     if (file.bytes == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to read file')),
//       );
//       return;
//     }

//     setState(() {
//       _fileBytes[type] = file.bytes;
//       _fileNames[type] = file.name;
//     });
//   }

//   String _label(String type) {
//     switch (type) {
//       case 'BILL':
//         return 'Bills / Receipts';
//       case 'INVOICE':
//         return 'Invoice';
//       case 'CO':
//         return 'CO - Comparative Order';
//       case 'PO':
//         return 'PO - Purchase Order';
//       case 'OTHER':
//         return 'Other Supporting Document';
//       default:
//         return type;
//     }
//   }

//   Future<void> _submit() async {
//     final amount = double.tryParse(_amountController.text.trim());

//     if (amount == null || amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Enter valid actual expense amount')),
//       );
//       return;
//     }

//     if (_summaryController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Enter expense summary')),
//       );
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       final storageService = ref.read(storageServiceProvider);
//       final postEventService = ref.read(postEventServiceProvider);

//       final files = <Map<String, dynamic>>[];

//       for (final type in _fileTypes) {
//         if (_fileBytes[type] != null && _fileNames[type] != null) {
//           final uploaded = await storageService.uploadExpenseFile(
//             eventId: widget.eventId,
//             fileType: type,
//             fileName: _fileNames[type]!,
//             bytes: _fileBytes[type]!,
//           );

//           files.add({
//             'file_type': type,
//             'file_name': uploaded['file_name'],
//             'storage_path': uploaded['storage_path'],
//           });
//         }
//       }

//       await postEventService.submitExpense(
//         eventId: widget.eventId,
//         actualAmount: amount,
//         summaryNote: _summaryController.text.trim(),
//         files: files,
//       );

//       if (!mounted) return;
//       Navigator.pop(context, true);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to submit expenses: $e')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final eventService = ref.read(eventServiceProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Submit Expense Proofs')),
//       body: FutureBuilder<EventModel>(
//         future: eventService.getEventById(widget.eventId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData) {
//             return const Center(child: Text('Event not found'));
//           }

//           final event = snapshot.data!;

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Event Details',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 12),
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Event: ${event.title}'),
//                         const SizedBox(height: 8),
//                         Text('Date: ${event.eventDate}'),
//                         const SizedBox(height: 8),
//                         Text('Venue: ${event.venue ?? '-'}'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextField(
//                   controller: _amountController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: 'Actual Expense Amount',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: _summaryController,
//                   maxLines: 4,
//                   decoration: const InputDecoration(
//                     labelText: 'Expense Summary',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Upload Expense Documents',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 12),
//                 ..._fileTypes.map((type) {
//                   return Card(
//                     child: ListTile(
//                       title: Text(_label(type)),
//                       subtitle: Text(_fileNames[type] ?? 'No file selected'),
//                       trailing: TextButton(
//                         onPressed: () => _pickFile(type),
//                         child: const Text('Upload'),
//                       ),
//                     ),
//                   );
//                 }),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isSubmitting ? null : _submit,
//                     child: Text(
//                       _isSubmitting ? 'Submitting...' : 'Submit Expenses',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import 'shared_widgets.dart';

class EventExpenseSubmissionScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventExpenseSubmissionScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventExpenseSubmissionScreen> createState() => _EventExpenseSubmissionScreenState();
}

class _EventExpenseSubmissionScreenState extends ConsumerState<EventExpenseSubmissionScreen> {
  final _amountController = TextEditingController();
  final _summaryController = TextEditingController();

  final List<String> _fileTypes = const ['BILL', 'INVOICE', 'CO', 'PO', 'OTHER'];
  final Map<String, Uint8List?> _fileBytes = {};
  final Map<String, String?> _fileNames = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (final type in _fileTypes) {
      _fileBytes[type] = null;
      _fileNames[type] = null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  String _label(String type) {
    switch (type) {
      case 'BILL': return 'Bills / Receipts';
      case 'INVOICE': return 'Invoice';
      case 'CO': return 'CO – Comparative Order';
      case 'PO': return 'PO – Purchase Order';
      case 'OTHER': return 'Other Supporting Document';
      default: return type;
    }
  }

  Future<void> _pickFile(String type) async {
    final result = await FilePicker.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to read file')));
      return;
    }
    setState(() { _fileBytes[type] = file.bytes; _fileNames[type] = file.name; });
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid actual expense amount')));
      return;
    }
    if (_summaryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter expense summary')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final storageService = ref.read(storageServiceProvider);
      final postEventService = ref.read(postEventServiceProvider);
      final files = <Map<String, dynamic>>[];

      for (final type in _fileTypes) {
        if (_fileBytes[type] != null && _fileNames[type] != null) {
          final uploaded = await storageService.uploadExpenseFile(
            eventId: widget.eventId, fileType: type,
            fileName: _fileNames[type]!, bytes: _fileBytes[type]!,
          );
          files.add({'file_type': type, 'file_name': uploaded['file_name'], 'storage_path': uploaded['storage_path']});
        }
      }

      await postEventService.submitExpense(
        eventId: widget.eventId,
        actualAmount: amount,
        summaryNote: _summaryController.text.trim(),
        files: files,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit expenses: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1A1F36)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Submit Expense Proofs',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: FutureBuilder<EventModel>(
        future: ref.read(eventServiceProvider).getEventById(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3B5BDB)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFFDC2626))));
          }
          if (!snapshot.hasData) return const Center(child: Text('Event not found'));

          final event = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.event_outlined, color: Color(0xFF3B5BDB), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(event.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36))),
                          const SizedBox(height: 3),
                          Text('${event.eventDate} • ${event.venue ?? '-'}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionLabel(label: 'Expense Details'),
                const SizedBox(height: 12),
                FormCard(
                  children: [
                    FieldGroup(
                      label: 'Actual Expense Amount (₹)',
                      child: StyledTextField(
                        controller: _amountController,
                        hint: 'e.g. 18500',
                        icon: Icons.currency_rupee_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    FieldDivider(),
                    FieldGroup(
                      label: 'Expense Summary',
                      child: StyledTextField(
                        controller: _summaryController,
                        hint: 'Describe how funds were spent...',
                        icon: Icons.notes_outlined,
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SectionLabel(label: 'Expense Documents'),
                const SizedBox(height: 12),
                ..._fileTypes.map((type) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FileUploadCard(
                    fileName: _fileNames[type],
                    fileSize: null,
                    onTap: () => _pickFile(type),
                    buttonLabel: 'Upload',
                    label: _label(type),
                  ),
                )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B5BDB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Submit Expenses', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}