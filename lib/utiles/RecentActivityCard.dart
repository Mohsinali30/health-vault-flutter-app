import 'package:flutter/material.dart';

import 'AppColors.dart';


class RecentActivityCard extends StatelessWidget {
  final IconData icon;
  final Widget title;
  final String subtitle;
  final VoidCallback onViewDetails;
  final IconData  buttonicon;

   RecentActivityCard({
    Key? key,
    required this.icon,
    required this.title,
     this.subtitle='',
    required this.onViewDetails,
    required this.buttonicon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: cardBackgroundColor, // Use the defined card background color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 28.0, color: primaryGreen),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                       "$title",
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13.0,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onViewDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen, // Button background color
                  foregroundColor: Colors.white, // Button text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Icon(buttonicon,size: 25,color: lightGreen,)
              ),
            ),
          ],
        ),
      ),
    );
  }
}