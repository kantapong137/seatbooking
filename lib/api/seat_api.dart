import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:seatbooking/model/seat_model.dart';

class SeatApi {
  final String apiUrl = 'https://xokthilat.github.io/json/seating.json'; // Replace with your API endpoint

  Future<List<List<Seat>?>?> fetchSeats() async {
    final response = await http.get(Uri.parse(apiUrl));
    final jsonData = json.decode(response.body);

    if (jsonData.containsKey("seatLayout")) {
      final rows = jsonData["seatLayout"]["rows"];
      final columns = jsonData["seatLayout"]["columns"];
      final seatData = jsonData["seatLayout"]["seats"];
      List<List<Seat>?> seats = [];
      for (var i = 0; i < rows; i++) {
        List<Seat> row = [];
        for (var j = 0; j < columns; j++) {
          final seatNumber = String.fromCharCode(65 + i) + (j + 1).toString();
          final status = seatData.firstWhere(
            (seat) => seat["seatNumber"] == seatNumber,
            orElse: () => {"status": "unavailable"},
          )["status"];
          row.add(Seat(seatNumber: seatNumber, status: status));
        }
        seats.add(row);
      }
      return seats;
    }
    return null;
  }
}
