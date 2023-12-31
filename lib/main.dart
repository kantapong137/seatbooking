import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api/seat_api.dart';
import 'model/seat_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, widget) => ResponsiveWrapper.builder(
        BouncingScrollWrapper.builder(context, widget!),
        maxWidth: 500,
        minWidth: 450,
        defaultScale: true,
      ),
      home: const SeatReservationApp(),
    );
  }
}

class SeatReservationApp extends StatefulWidget {
  const SeatReservationApp({super.key});

  @override
  _SeatReservationAppState createState() => _SeatReservationAppState();
}

class _SeatReservationAppState extends State<SeatReservationApp> {
  List<List<Seat>?> seats = [];
  String selectedSeat = ''; 
  final seatApi = SeatApi();
  Venue? venue;
  @override
  void initState() {
    super.initState();
    fetchVenueData();
    fetchSeats();
  }

  void fetchVenueData() async {
    final venueData = await seatApi.fetchVenueData();
    setState(() {
      venue = Venue(
        name: venueData["name"],
        capacity: venueData["capacity"],
      );
    });
  }

  void fetchSeats() async {
    List<List<Seat>?>? fetchedSeats = await seatApi.fetchSeats();
    if (fetchedSeats != null) {
      setState(() {
        seats = fetchedSeats;
        // print(seats[0]![0].seatNumber);
        // print(seats[0]![1].seatNumber);
        // print(seats[0]![2].seatNumber);
      });
    }
  }

  void toggleSeat(String seatNumber) {
    if (selectedSeat == seatNumber) {
      selectedSeat = '';
    } else {
      selectedSeat = seatNumber;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Align(
          alignment: const AlignmentDirectional(0.00, 0.00),
          child: Text(
            'เลือกที่นั่ง',
            style: GoogleFonts.getFont(
              'Kanit',
              color: Colors.black,
              fontSize: 24,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 0),
              child: Column(
                children: [
                  Text(
                    'สถานที่จัดงาน: ${venue?.name}',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'ความจุทั้งหมด: ${venue?.capacity} ที่',
                    style: GoogleFonts.getFont(
                      'Kanit',
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(padding: const EdgeInsets.only(top: 20)),
            if (seats.isEmpty)
              const CircularProgressIndicator()
            else
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: seats[0]!.length,
                      childAspectRatio: (20 / 20),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: seats.length * seats[0]!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final i = index ~/ seats[0]!.length;
                      final j = index % seats[0]!.length;
                      final seat = seats[i]![j];
                      Color backgroundColor;
                      if (seat.status == 'available') {
                        if (seat.seatNumber == selectedSeat) {
                          backgroundColor = Colors.orange;
                        } else {
                          backgroundColor = Colors.grey;
                        }
                      } else {
                        backgroundColor = Colors.red;
                      }
                      return GestureDetector(
                        onTap: () {
                          if (seat.status == 'available') {
                            toggleSeat(seat.seatNumber);
                          }
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle,
                            color: backgroundColor,
                          ),
                          child: Center(
                            child: Text(
                              seat.status == 'available'
                                  ? seat.seatNumber
                                  : ' ',
                              style: GoogleFonts.getFont(
                                'Kanit',
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const Divider(
              thickness: 1,
              color: Color(0xFF9E9E9E),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: selectedSeat.isNotEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Align(
                                alignment:
                                    const AlignmentDirectional(0.00, 0.00),
                                child: Text(
                                  selectedSeat,
                                  style: GoogleFonts.getFont(
                                    'Kanit',
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.clear_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                onPressed: () {
                                  selectedSeat = '';
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Container(
                      width: 100,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
            ),
            Container(padding: const EdgeInsets.only(bottom: 10)),
          ],
        ),
      ),
    );
  }
}
