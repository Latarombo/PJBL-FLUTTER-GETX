import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

// PrimaryButton
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56, // layout concern
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

/// SocialButton
class SocialButton extends StatelessWidget {
  final String text;
  final String assetIcon;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.text,
    required this.assetIcon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(assetIcon, height: 24, width: 24),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: textTheme.labelLarge,
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward,
              color: colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

