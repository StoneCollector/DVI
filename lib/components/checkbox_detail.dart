import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckboxDetail extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String price;
  final String slash;
  final String value;

  const CheckboxDetail({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.slash,
    required this.value,
  });

  @override
  State<CheckboxDetail> createState() => _CheckboxDetailState();
}

class _CheckboxDetailState extends State<CheckboxDetail> {
  bool? isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: EdgeInsets.only(right: 10, top: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(110, 145, 141, 141),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Checkbox(
            value: isChecked,
            activeColor: Color(0xff0c1c2c),
            onChanged: (newBool) {
              setState(() {
                isChecked = newBool;
              });
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(widget.icon, color: Color.fromARGB(255, 212, 175, 55)),
                    Text(
                      widget.title,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0c1c2c),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    widget.subtitle,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(12, 28, 44, 0.651),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.price,
                          style: GoogleFonts.urbanist(
                            color: Color.fromARGB(255, 212, 175, 55),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.slash,
                          style: GoogleFonts.urbanist(
                            color: Color(0xff0c1c2c),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5),
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.remove),
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text(
                            widget.value,
                            style: GoogleFonts.urbanist(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xff0c1c2c),
                            ),
                          ),
                        ),
                        Container(
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
