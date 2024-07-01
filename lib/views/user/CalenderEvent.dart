import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserCalendarScreen extends StatefulWidget {
  const UserCalendarScreen({Key? key}) : super(key: key);

  @override
  State<UserCalendarScreen> createState() => _UserCalendarScreenState();
}

class _UserCalendarScreenState extends State<UserCalendarScreen>
    with AutomaticKeepAliveClientMixin {
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
    _loadEvents();
  }

  _loadEvents() async {
    QuerySnapshot eventsSnapshot = await firestore.collection('events').get();

    mySelectedEvents.clear();
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

    setState(() {}); // Trigger a rebuild after loading events
  }

  List<Map<String, dynamic>> _listOfDayEvents(DateTime dateTime) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return mySelectedEvents[formattedDate] ?? [];
  }

  _showAddEventDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
          // ... your existing AlertDialog setup
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure super.build is called

    return Scaffold(
      backgroundColor: Color(0xFFF5EEE6),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 30.0,
        ),
        child: Column(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
