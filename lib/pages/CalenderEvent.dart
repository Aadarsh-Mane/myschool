import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate = DateTime.now();
  Map<String, List<Map<String, dynamic>>> mySelectedEvents = {};
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = _focusedDay;
    loadPreviousEvents();
  }

  loadPreviousEvents() async {
    QuerySnapshot eventsSnapshot = await firestore.collection('events').get();

    mySelectedEvents.clear(); // Clear existing events
    eventsSnapshot.docs.forEach((eventDoc) {
      Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
      String eventDate = eventData['eventDate'];

      if (mySelectedEvents[eventDate] != null) {
        mySelectedEvents[eventDate]?.add({
          'eventTitle': eventData['eventTitle'],
          'eventDesc': eventData['eventDesc'],
          'eventId': eventDoc.id,
        });
      } else {
        mySelectedEvents[eventDate] = [
          {
            'eventTitle': eventData['eventTitle'],
            'eventDesc': eventData['eventDesc'],
            'eventId': eventDoc.id,
          }
        ];
      }
    });
  }

  List<Map<String, dynamic>> _listOfDayEvents(DateTime dateTime) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return mySelectedEvents[formattedDate] ?? [];
  }

  _showAddEventDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add New Event',
          textAlign: TextAlign.center,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: descController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            child: const Text('Add Event'),
            onPressed: () async {
              if (titleController.text.isEmpty && descController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Required title and description'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              String formattedDate =
                  DateFormat('yyyy-MM-dd').format(_selectedDate!);

              // Check if the event already exists
              bool eventExists = mySelectedEvents[formattedDate]?.any((event) =>
                      event['eventTitle'] == titleController.text &&
                      event['eventDesc'] == descController.text) ??
                  false;

              if (eventExists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event already exists'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              await firestore.collection('events').add({
                'eventTitle': titleController.text,
                'eventDesc': descController.text,
                'eventDate': formattedDate,
              });

              // Reload events after adding
              loadPreviousEvents();

              titleController.clear();
              descController.clear();
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  _showEditEventDialog(Map<String, dynamic> event) async {
    titleController.text = event['eventTitle'];
    descController.text = event['eventDesc'];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Event',
          textAlign: TextAlign.center,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: descController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            child: const Text('Update Event'),
            onPressed: () async {
              if (titleController.text.isEmpty && descController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Required title and description'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              await firestore
                  .collection('events')
                  .doc(event['eventId'])
                  .update({
                'eventTitle': titleController.text,
                'eventDesc': descController.text,
              });

              // Reload events after updating
              loadPreviousEvents();

              titleController.clear();
              descController.clear();
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  _showDeleteEventDialog(String eventId) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Event',
          textAlign: TextAlign.center,
        ),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await firestore.collection('events').doc(eventId).delete();

              // Reload events after deleting
              loadPreviousEvents();

              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Calendar Example'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2023),
            lastDay: DateTime(2026),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDate, selectedDay)) {
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _listOfDayEvents,
          ),
          ..._listOfDayEvents(_selectedDate!).map(
            (myEvents) => ListTile(
              leading: const Icon(
                Icons.done,
                color: Colors.teal,
              ),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Event Title:   ${myEvents['eventTitle']}'),
              ),
              subtitle: Text('Description:   ${myEvents['eventDesc']}'),
              onTap: () {
                _showEditEventDialog(myEvents);
              },
              onLongPress: () {
                _showDeleteEventDialog(myEvents['eventId']);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventDialog(),
        label: const Text('Add Event'),
      ),
    );
  }
}
