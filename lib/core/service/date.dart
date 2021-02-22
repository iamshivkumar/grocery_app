import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Date {
  String activeDate(int days) {
    DateTime now = DateTime.now().add(Duration(days: days));
    String formattedDate = DateFormat('MMMd').format(now);
    return formattedDate;
  }

  String activeDay(int days) {
    DateTime now = DateTime.now().add(Duration(days: days));
    String formattedDate = DateFormat('EEEE').format(now);
    return formattedDate;
  }

//13:27:00
  bool deliverable({String value}) {
    TimeOfDay timeOfDay = TimeOfDay.now();
    TimeOfDay newValue =
        TimeOfDay.fromDateTime(DateTime.parse("2012-02-27 " + value));
    double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;
    return toDouble(newValue) > toDouble(timeOfDay);
  }

  String datetime(Timestamp timestamp) {
    
    var datetime =
        DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch);
    return DateFormat('MMM d, h:mm a').format(datetime);
  }
  

}
