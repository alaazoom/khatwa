import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
      Image.asset(
        'assets/images/logo.png',),
        // const SizedBox(height: 12),
        // Text(
        //   'app_name'.tr,
        //   style: text.headlineMedium
        //       ?.copyWith(fontWeight: FontWeight.w800, color: scheme.primary),
        // ),
        // const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.obscure = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscure;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon,color:Color(0xff94A3B8)),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: scheme.onPrimary,
              ),
            )
          : Text(label),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectionCard extends StatelessWidget {
  const SelectionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: selected ? scheme.primaryContainer : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(color: color),
                    ),
                  ],
                ),
                if (selected)
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: scheme.primary,
                      child: Icon(Icons.check_rounded,
                          size: 14, color: scheme.onPrimary),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatusMessage extends StatelessWidget {
  const StatusMessage({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: scheme.onSurfaceVariant),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        if (body != null) ...[
          const SizedBox(height: 8),
          Text(
            body!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 20),
          FilledButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ],
    );
  }
}