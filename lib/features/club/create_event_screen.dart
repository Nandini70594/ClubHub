// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../models/event_model.dart';
// import '../../providers/auth_provider.dart';

// class CreateEventScreen extends ConsumerStatefulWidget {
//   final EventModel? event;

//   const CreateEventScreen({
//     super.key,
//     this.event,
//   });

//   @override
//   ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
// }

// class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
//   late final TextEditingController _titleController;
//   late final TextEditingController _descriptionController;
//   late final TextEditingController _venueController;
//   late final TextEditingController _dateController;

//   bool _loading = false;
//   String? _error;

//   bool get isEditMode => widget.event != null;

//   @override
//   void initState() {
//     super.initState();

//     _titleController = TextEditingController(
//       text: widget.event?.title ?? '',
//     );
//     _descriptionController = TextEditingController(
//       text: widget.event?.description ?? '',
//     );
//     _venueController = TextEditingController(
//       text: widget.event?.venue ?? '',
//     );
//     _dateController = TextEditingController(
//       text: widget.event?.eventDate ?? '',
//     );
//   }

//   Future<void> _submit() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       if (isEditMode) {
//         await ref.read(eventServiceProvider).updateEvent(
//               eventId: widget.event!.id,
//               title: _titleController.text.trim(),
//               description: _descriptionController.text.trim(),
//               eventDate: _dateController.text.trim(),
//               venue: _venueController.text.trim(),
//             );
//       } else {
//         await ref.read(eventServiceProvider).createEvent(
//               title: _titleController.text.trim(),
//               description: _descriptionController.text.trim(),
//               eventDate: _dateController.text.trim(),
//               venue: _venueController.text.trim(),
//             );
//       }

//       if (!mounted) return;
//       Navigator.pop(context, true);
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _loading = false);
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _venueController.dispose();
//     _dateController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final titleText = isEditMode ? 'Edit Event' : 'Create Event';
//     final buttonText = isEditMode ? 'Update Event' : 'Create Event';

//     return Scaffold(
//       appBar: AppBar(title: Text(titleText)),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: const InputDecoration(labelText: 'Title'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _descriptionController,
//               decoration: const InputDecoration(labelText: 'Description'),
//               maxLines: 3,
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _venueController,
//               decoration: const InputDecoration(labelText: 'Venue'),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _dateController,
//               decoration: const InputDecoration(
//                 labelText: 'Event Date',
//                 hintText: 'YYYY-MM-DD',
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (_error != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Text(
//                   _error!,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               ),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _loading ? null : _submit,
//                 child: _loading
//                     ? const SizedBox(
//                         height: 18,
//                         width: 18,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : Text(buttonText),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import 'shared_widgets.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  final EventModel? event;
  const CreateEventScreen({super.key, this.event});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _venueController;
  late final TextEditingController _dateController;

  bool _loading = false;
  String? _error;

  bool get isEditMode => widget.event != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _venueController = TextEditingController(text: widget.event?.venue ?? '');
    _dateController = TextEditingController(text: widget.event?.eventDate ?? '');
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (isEditMode) {
        await ref.read(eventServiceProvider).updateEvent(
          eventId: widget.event!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          eventDate: _dateController.text.trim(),
          venue: _venueController.text.trim(),
        );
      } else {
        await ref.read(eventServiceProvider).createEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          eventDate: _dateController.text.trim(),
          venue: _venueController.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _dateController.dispose();
    super.dispose();
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
        title: Text(
          isEditMode ? 'Edit Event' : 'Create Event',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(label: 'Event Information'),
            const SizedBox(height: 12),
            FormCard(
              children: [
                FieldGroup(
                  label: 'Title',
                  child: StyledTextField(
                    controller: _titleController,
                    hint: 'e.g. Annual Tech Fest',
                    icon: Icons.title_outlined,
                  ),
                ),
                const FieldDivider(),
                FieldGroup(
                  label: 'Description',
                  child: StyledTextField(
                    controller: _descriptionController,
                    hint: 'Describe the event...',
                    icon: Icons.notes_outlined,
                    maxLines: 3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SectionLabel(label: 'Schedule & Location'),
            const SizedBox(height: 12),
            FormCard(
              children: [
                FieldGroup(
                  label: 'Venue',
                  child: StyledTextField(
                    controller: _venueController,
                    hint: 'e.g. Seminar Hall A',
                    icon: Icons.location_on_outlined,
                  ),
                ),
                const FieldDivider(),
                FieldGroup(
                  label: 'Event Date',
                  child: StyledTextField(
                    controller: _dateController,
                    hint: 'YYYY-MM-DD',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.datetime,
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              ErrorBanner(message: _error!),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5BDB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        isEditMode ? 'Update Event' : 'Create Event',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}