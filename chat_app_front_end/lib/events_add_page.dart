import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

class Event {
  final String eventId;
  final String eventName;
  late final DateTime eventDate;

  Event({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
  });
}

class EventManagementPage extends StatefulWidget {
  @override
  _EventManagementPageState createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  List<Event> events = [];
  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _eventDateController = TextEditingController();
  bool _isEditing = false;
  late Event _selectedEvent;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final response = await supabase.from('events').select().execute();

    final List<dynamic> eventData = response.data;
    final List<Event> fetchedEvents = eventData.map((data) {
      final String eventId = data['event_id'] as String;
      final String eventName = data['event_name'] as String;
      final String dateString = data['event_date'] as String;
      final DateTime eventDate =
          DateTime.parse(dateString.replaceAll('/', '-'));
      return Event(
          eventId: eventId, eventName: eventName, eventDate: eventDate);
    }).toList();

    setState(() {
      events = fetchedEvents;
    });
  }

  void resetForm() {
    _eventNameController.text = '';
    _eventDateController.text = '';
    _isEditing = false;
  }

  Future<void> addEvent() async {
    final String eventName = _eventNameController.text;
    final DateTime eventDate = DateTime.parse(_eventDateController.text);

    // Add the event to the events table
    // You can use Supabase or any other database API to insert the event
    // and handle any error cases.
    // Example:
    final response = await supabase.from('events').insert({
      'event_name': eventName,
      'event_date': eventDate.toIso8601String(),
    }).execute();
    if (response.status != 201) {
      // Handle error
      throw Error();
    }

    final String eventId = response.data[0]['event_id'] as String;

    setState(() {
      events.add(
          Event(eventId: eventId, eventName: eventName, eventDate: eventDate));
    });

    resetForm();
  }

  Future<void> updateEvent() async {
    final String eventName = _eventNameController.text;
    final DateTime eventDate = DateTime.parse(_eventDateController.text);

    // Update the selected event in the events table
    // You can use Supabase or any other database API to update the event
    // and handle any error cases.
    // Example:
    final response = await supabase
        .from('events')
        .update({
          'event_name': eventName,
          'event_date': eventDate.toIso8601String(),
        })
        .eq('event_id', _selectedEvent.eventId)
        .execute();
    if (response.status != 200) {
      // Handle error
      throw Error();
    }

    setState(() {
      final index =
          events.indexWhere((event) => event.eventId == _selectedEvent.eventId);
      if (index != -1) {
        events[index] = Event(
            eventId: _selectedEvent.eventId,
            eventName: eventName,
            eventDate: eventDate);
      }
    });

    resetForm();
  }
void deleteEvent(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Delete the event from the events table
                // You can use Supabase or any other database API to delete the event
                // and handle any error cases.
                // Example:
                final response = await supabase
                    .from('events')
                    .delete()
                    .eq('event_id', event.eventId)
                    .execute();
                if (response.status != 200) {
                  // Handle error
                  throw Error();
                }

                // Placeholder code to delete the event from the events list for demonstration purposes
                setState(() {
                  events.remove(event);
                });

                Navigator.pop(context);
                              Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EventManagementPage())); // Reload the page

              } catch (error) {
                // Handle error
                print(error);
              }
            },
            child: const Text('Delete'),
            
          ),
        ],
      ),
    );
  }


  void editEvent(Event event) {
    setState(() {
      _isEditing = true;
      _selectedEvent = event;
      _eventNameController.text = event.eventName;
      _eventDateController.text =
          event.eventDate.toIso8601String().split('T')[0];
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Event'),
        content: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _eventNameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: event.eventDate,
                    firstDate: DateTime(2021),
                    lastDate: DateTime(2025),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _eventDateController.text =
                          selectedDate.toIso8601String().split('T')[0];
                    });
                  }
                },
                child: const Text('Select Event Date'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              resetForm();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              updateEvent();
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final formattedDate =
              '${event.eventDate.year}/${event.eventDate.month}/${event.eventDate.day}';

          return ListTile(
            title: Text(event.eventName),
            subtitle: Text('Date: ${formattedDate}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.blue,
                  onPressed: () => editEvent(event),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () => deleteEvent(event),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add/Edit Event'),
              content: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _eventNameController,
                      decoration:
                          const InputDecoration(labelText: 'Event Name'),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2021),
                          lastDate: DateTime(2025),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _eventDateController.text =
                                selectedDate.toIso8601String().split('T')[0];
                          });
                        }
                      },
                      child: const Text('Select Event Date'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_isEditing) {
                      updateEvent();
                    } else {
                      addEvent();
                    }
                    Navigator.pop(context);
                  },
                  child: Text(_isEditing ? 'Update' : 'Add'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
