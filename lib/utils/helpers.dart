// Date and time formatting utilities
String formatDate(DateTime date) {
  // Use the date as is, without timezone conversion
  return '${date.day}/${date.month}/${date.year}';
}

String formatTime(DateTime date) {
  // Format the time using the system time formatting
  return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}

// Alternative implementation that handles timezone explicitly
String formatTimeWithTimezone(DateTime date) {
  // Get the local timezone offset in hours
  final offset = DateTime.now().timeZoneOffset.inHours;
  
  // Add the offset to get local time
  final localHour = (date.hour + offset) % 24;
  String hours = localHour.toString().padLeft(2, '0');
  String minutes = date.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

// Format game duration
String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  
  if (minutes > 0) {
    return '${minutes}m ${remainingSeconds}s';
  } else {
    return '${remainingSeconds}s';
  }
}

// Format game information including mode and value
String formatGameInfo(String gameMode, String gameValue) {
  if (gameMode == 'Time') {
    return 'Time: $gameValue';
  } else if (gameMode == 'Points') {
    return 'First to $gameValue';
  } else {
    return '$gameMode: $gameValue';
  }
}

// You can add other helper functions below as needed