import 'package:firebase_practice/utiles/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting


class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Appointment'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // Here is the card widget
          child: EventCard(),
        ),
      ),
    );
  }
}

/// A stateful widget that manages its own edit/display state.
class EventCard extends StatefulWidget {
  const EventCard({super.key});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  // State variables
  bool _isEditing = true; // Start in edit mode by default
  final TextEditingController _textController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Toggles between editing and saving.
  void _toggleEditSave() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // "Save" action was pressed
        // In a real app, you would save this data to your database
        // or state management solution.
        print('Saved: ${_textController.text}');
        print('Date: $_selectedDate');
        print('Time: $_selectedTime');

        // Optionally show a confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event Saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  /// Shows the date picker dialog.
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Shows the time picker dialog.
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Make the card wrap its content
          children: [
            // Row for Text Field and Edit/Save Button
            Row(
              children: [
                // The main text input
                Expanded(
                  child: _isEditing
                      ? TextField(
                    controller: _textController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter your event title...',
                      border: InputBorder.none,

                    ),
                  )
                      : Text(
                    _textController.text.isEmpty
                        ? 'No Event Title'
                        : _textController.text,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                // The Edit/Save icon button
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit,color: primaryGreen,),
                  onPressed: _toggleEditSave,
                  tooltip: _isEditing ? 'Save' : 'Edit',
                ),
              ],
            ),
            const Divider(),
            // Row for Calendar Picker
            ListTile(
              leading: const Icon(Icons.calendar_today,color: primaryGreen,),
              title: Text(
                _selectedDate == null
                    ? 'Pick Date'
                    : DateFormat.yMMMd().format(_selectedDate!), // 'Nov 7, 2025'
              ),
              onTap: _isEditing ? () => _pickDate(context) : null,
              enabled: _isEditing,
            ),
            // Row for Time Picker
            ListTile(
              leading: const Icon(Icons.access_time,color: primaryGreen,),
              title: Text(
                _selectedTime == null
                    ? 'Pick Time'
                    : _selectedTime!.format(context), // '9:44 PM'
              ),
              onTap: _isEditing ? () => _pickTime(context) : null,
              enabled: _isEditing,
            ),
          ],
        ),
      ),
    );
  }
}