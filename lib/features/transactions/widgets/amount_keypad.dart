import 'package:flutter/material.dart';

class AmountKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyTap;
  final VoidCallback onDone;

  const AmountKeypad({
    super.key,
    required this.onKeyTap,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      '1','2','3',
      '4','5','6',
      '7','8','9',
      '.','0','⌫',
    ];

    return Container(
      color: Colors.black26,
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: keys.length,
            itemBuilder: (context, i) {
              return InkWell(
                onTap: () => onKeyTap(keys[i]),
                child: Center(
                  child: Text(
                    keys[i],
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              );
            },
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: onDone,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
