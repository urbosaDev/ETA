import 'package:flutter/material.dart';

class NumberPickerModal extends StatefulWidget {
  final List<int> values;
  final int initialValue;
  final String title;
  final TextTheme textTheme;

  const NumberPickerModal({
    super.key,
    required this.values,
    required this.initialValue,
    required this.title,
    required this.textTheme,
  });

  @override
  State<NumberPickerModal> createState() => _NumberPickerModalState();
}

class _NumberPickerModalState extends State<NumberPickerModal> {
  late FixedExtentScrollController _scrollController;
  late int _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;

    final initialIndex = widget.values.indexOf(widget.initialValue);
    _scrollController = FixedExtentScrollController(
      initialItem: initialIndex != -1 ? initialIndex : 0,
    );

    _scrollController.addListener(() {
      if (_scrollController.hasClients &&
          !_scrollController.position.isScrollingNotifier.value) {
        final int newSelectedValue =
            widget.values[_scrollController.selectedItem];
        if (_selectedValue != newSelectedValue) {
          setState(() {
            _selectedValue = newSelectedValue;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xff1a1a1a),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.title,
              style: widget.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.white12, thickness: 0.2),
          Expanded(
            child: ListView.builder(
              itemExtent: 48,
              itemCount: widget.values.length,
              controller: _scrollController,
              itemBuilder: (context, index) {
                final value = widget.values[index];
                final isSelected = (value == _selectedValue);
                return ListTile(
                  title: Center(
                    child: Text(
                      '$value',
                      style: widget.textTheme.bodyMedium?.copyWith(
                        color:
                            isSelected
                                ? Theme.of(context)
                                        .elevatedButtonTheme
                                        .style
                                        ?.backgroundColor
                                        ?.resolve({}) ??
                                    Colors.pinkAccent
                                : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  onTap: () {
                    _scrollController.animateToItem(
                      index,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                    );
                    setState(() {
                      _selectedValue = value;
                    });
                  },
                  selected: isSelected,
                  selectedTileColor: Colors.white.withOpacity(0.05),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_selectedValue),
                style: Theme.of(context).elevatedButtonTheme.style,
                child: Text(
                  '선택 완료',
                  style: widget.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
