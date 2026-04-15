import 'package:copper_hub/utils/app_colors.dart';
import 'package:copper_hub/utils/input_decoration.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final Function(String) onChanged;
  final IconData Function(String)? iconBuilder;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.iconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(value),
      initialValue: value,
      decoration: AppDecorations.textField(label: label),
      dropdownColor: AppColors.white,
      borderRadius: BorderRadius.circular(8),
      icon: const Icon(Icons.keyboard_arrow_down),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Row(
            children: [
              if (iconBuilder != null) ...[
                Icon(iconBuilder!(item), size: 18, color: AppColors.orangeDark),
                const SizedBox(width: 8),
              ],
              Text(item, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }
}
