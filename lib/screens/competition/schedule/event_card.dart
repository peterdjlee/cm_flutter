import 'package:cm_flutter/auth/auth_provider.dart';
import 'package:cm_flutter/firebase/firestore_provider.dart';
import 'package:cm_flutter/models/competition.dart';
import 'package:cm_flutter/models/event.dart';
import 'package:cm_flutter/screens/competition/schedule/event/edit_event_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final Competition competition;
  final VoidCallback onPressed;

  EventCard({this.event, this.competition, this.onPressed});

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final FirestoreProvider db = FirestoreProvider();
  bool isEditing = true;

  final AuthProvider authProvider = AuthProvider();

  bool isUserSubscribed = false;

  Future<Event> checkSubscribers(Event event) async {
    Event newEvent = event;
    List<dynamic> subscribers = event.subscribers;
    AuthProvider auth = AuthProvider();

    if (subscribers != null) {
      subscribers.forEach((id) async {
        FirebaseUser user = await auth.getCurrentUser();
        if (user.uid == id) {
          newEvent.isUserSubscribed = true;
        }
      });
    }
    return newEvent;
  }

  @override
  void initState() {
    super.initState();

    // Checks if user is subscribed to the events loaded.
    List<dynamic> subscribers = widget.event.subscribers;
    AuthProvider auth = AuthProvider();
    if (subscribers != null) {
      subscribers.forEach((id) {
        auth.getCurrentUser().then((user) {
          if (user.uid == id) {
            setState(() {
              isUserSubscribed = true;
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String startTime = DateFormat.jm().format(widget.event.startTime);
    String endTime = DateFormat.jm().format(widget.event.endTime);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              startTime,
              style: TextStyle(color: Colors.black54, fontSize: 16.0),
            ),
            SizedBox(height: 6.0),
            Text(
              endTime,
              style: TextStyle(color: Colors.black54, fontSize: 16.0),
            ),
          ],
        ),
        SizedBox(width: 48.0),
        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.event.name,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.0),
                      Text(
                        'On deck at ' +
                            DateFormat.jm().format(widget.event.startTime
                                .subtract(Duration(minutes: 20))),
                        style: TextStyle(fontSize: 16.0, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                !isEditing
                    ? IconButton(
                        icon: !isUserSubscribed
                            ? Icon(
                                Icons.star_border,
                                color: Colors.blueAccent,
                                size: 32.0,
                              )
                            : Icon(
                                Icons.star,
                                color: Colors.blueAccent,
                                size: 32.0,
                              ),
                        onPressed: () async {
                          if (!isUserSubscribed) {
                            FirebaseUser user =
                                await authProvider.getCurrentUser();
                            db.addSubscriber(
                                widget.competition.id, widget.event.id, user);
                            setState(() {
                              isUserSubscribed = true;
                            });
                          } else {
                            FirebaseUser user =
                                await authProvider.getCurrentUser();
                            db.removeSubscriber(
                                widget.competition.id, widget.event.id, user);
                            setState(() {
                              isUserSubscribed = false;
                            });
                          }
                          widget.onPressed();
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Route route = MaterialPageRoute(
                            builder: (BuildContext context) => EditEventScreen(
                              competition: widget.competition,
                              event: widget.event,
                            ),
                          );
                          Navigator.of(context).push(route);
                        },
                      )
              ],
            ),
          ),
        )
      ],
    );
  }
}
