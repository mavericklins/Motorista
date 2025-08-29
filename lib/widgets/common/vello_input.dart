
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/vello_tokens.dart';

/// Tipos de input Vello Premium
enum VelloInputType {
  text,
  email,
  password,
  phone,
  number,
  search,
  multiline,
}

/// Estados do input Vello Premium
enum VelloInputState {
  normal,
  success,
  error,
  disabled,
}

/// Input padronizado do Vello Motorista Premium
/// Implementa design system consistente com floating label
class VelloInput extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VelloInputType type;
  final VelloInputState state;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;

  const VelloInput({
    Key? key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.controller,
    this.onChanged,
    this.onTap,
    this.type = VelloInputType.text,
    this.state = VelloInputState.normal,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines,
    this.maxLength,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.autovalidateMode,
    this.validator,
  }) : super(key: key);

  /// Input de texto simples
  const VelloInput.text({
    Key? key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.controller,
    this.onChanged,
    this.onTap,
    this.state = VelloInputState.normal,
    this.readOnly = false,
    this.enabled = true,
    this.maxLength,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.autovalidateMode,
    this.validator,
  }) : type = VelloInputType.text,
       maxLines = 1,
       super(key: key);

  /// Input de email
  const VelloInput.email({
    Key? key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.controller,
    this.onChanged,
    this.onTap,
    this.state = VelloInputState.normal,
    this.readOnly = false,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.autovalidateMode,
    this.validator,
  }) : type = VelloInputType.email,
       prefixIcon = Icons.email_outlined,
       maxLines = 1,
       maxLength = null,
       inputFormatters = null,
       super(key: key);

  /// Input de senha
  const VelloInput.password({
    Key? key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.state = VelloInputState.normal,
    this.readOnly = false,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.autovalidateMode,
    this.validator,
  }) : type = VelloInputType.password,
       prefixIcon = Icons.lock_outlined,
       suffixIcon = null,
       onSuffixIconPressed = null,
       maxLines = 1,
       maxLength = null,
       inputFormatters = null,
       super(key: key);

  /// Input de telefone
  const VelloInput.phone({
    Key? key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.controller,
    this.onChanged,
    this.onTap,
    this.state = VelloInputState.normal,
    this.readOnly = false,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.autovalidateMode,
    this.validator,
  }) : type = VelloInputType.phone,
       prefixIcon = Icons.phone_outlined,
       maxLines = 1,
       maxLength = null,
       inputFormatters = null,
       super(key: key);

  /// Input de pesquisa
  const VelloInput.search({
    Key? key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.controller,
    this.onChanged,
    this.onTap,
    this.state = VelloInputState.normal,
    this.readOnly = false,
    this.enabled = true,
    this.textInputAction,
    this.onSubmitted,
    this.autovalidateMode,
    this.validator,
  }) : type = VelloInputType.search,
       prefixIcon = Icons.search,
       maxLines = 1,
       maxLength = null,
       inputFormatters = null,
       super(key: key);

  /// Input multiline
  const VelloInput.multiline({
    Key? key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.controller,
    this.onChanged,
    this.onTap,
    this.state = VelloInputState.normal,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 4,
    this.maxLength,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.autovalidateMode,
    this.validator,
  }) : type = VelloInputType.multiline,
       super(key: key);

  @override
  State<VelloInput> createState() => _VelloInputState();
}

class _VelloInputState extends State<VelloInput> {
  late bool _isPasswordVisible;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = widget.type != VelloInputType.password;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: VelloTokens.animationMedium,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            autovalidateMode: widget.autovalidateMode,
            obscureText: !_isPasswordVisible,
            readOnly: widget.readOnly,
            enabled: widget.enabled && widget.state != VelloInputState.disabled,
            maxLines: widget.type == VelloInputType.multiline ? widget.maxLines : 1,
            maxLength: widget.maxLength,
            textInputAction: widget.textInputAction,
            keyboardType: _getKeyboardType(),
            inputFormatters: _getInputFormatters(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: _getTextColor(theme),
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hintText,
              helperText: widget.helperText,
              errorText: widget.state == VelloInputState.error ? widget.errorText : null,
              prefixIcon: widget.prefixIcon != null
                  ? AnimatedContainer(
                      duration: VelloTokens.animationMedium,
                      child: Icon(
                        widget.prefixIcon,
                        color: _getPrefixIconColor(theme),
                        size: 20,
                      ),
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(theme),
              filled: true,
              fillColor: _getFillColor(theme),
              border: _getBorder(theme, isDefault: true),
              enabledBorder: _getBorder(theme, isEnabled: true),
              focusedBorder: _getBorder(theme, isFocused: true),
              errorBorder: _getBorder(theme, isError: true),
              focusedErrorBorder: _getBorder(theme, isError: true, isFocused: true),
              disabledBorder: _getBorder(theme, isDisabled: true),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: widget.type == VelloInputType.multiline 
                  ? VelloTokens.spaceL
                  : VelloTokens.spaceM,
              ),
              counterStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              helperStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              errorStyle: theme.textTheme.bodySmall?.copyWith(
                color: VelloTokens.danger,
              ),
            ),
          ),
        ),
        if (widget.state == VelloInputState.success && widget.helperText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: VelloTokens.success,
              ),
              const SizedBox(width: 6),
              Text(
                widget.helperText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: VelloTokens.success,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon(ThemeData theme) {
    if (widget.type == VelloInputType.password) {
      return IconButton(
        icon: AnimatedSwitcher(
          duration: VelloTokens.animationMedium,
          child: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            key: ValueKey(_isPasswordVisible),
            color: _getSuffixIconColor(theme),
            size: 20,
          ),
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: _getSuffixIconColor(theme),
          size: 20,
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    }

    if (widget.state == VelloInputState.success) {
      return Icon(
        Icons.check_circle,
        color: VelloTokens.success,
        size: 20,
      );
    }

    if (widget.state == VelloInputState.error) {
      return Icon(
        Icons.error,
        color: VelloTokens.danger,
        size: 20,
      );
    }

    return null;
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case VelloInputType.email:
        return TextInputType.emailAddress;
      case VelloInputType.phone:
        return TextInputType.phone;
      case VelloInputType.number:
        return TextInputType.number;
      case VelloInputType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    if (widget.inputFormatters != null) {
      return widget.inputFormatters;
    }

    switch (widget.type) {
      case VelloInputType.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      case VelloInputType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return null;
    }
  }

  Color _getTextColor(ThemeData theme) {
    switch (widget.state) {
      case VelloInputState.disabled:
        return theme.colorScheme.onSurfaceVariant.withOpacity(0.5);
      case VelloInputState.error:
        return VelloTokens.danger;
      case VelloInputState.success:
        return theme.colorScheme.onSurface;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  Color _getFillColor(ThemeData theme) {
    if (widget.state == VelloInputState.disabled) {
      return theme.colorScheme.surfaceVariant.withOpacity(0.5);
    }
    
    if (_isFocused) {
      return theme.colorScheme.surface;
    }

    return theme.colorScheme.surfaceVariant.withOpacity(0.3);
  }

  Color _getPrefixIconColor(ThemeData theme) {
    if (widget.state == VelloInputState.disabled) {
      return theme.colorScheme.onSurfaceVariant.withOpacity(0.5);
    }

    if (_isFocused) {
      return theme.colorScheme.primary;
    }

    return theme.colorScheme.onSurfaceVariant;
  }

  Color _getSuffixIconColor(ThemeData theme) {
    switch (widget.state) {
      case VelloInputState.success:
        return VelloTokens.success;
      case VelloInputState.error:
        return VelloTokens.danger;
      case VelloInputState.disabled:
        return theme.colorScheme.onSurfaceVariant.withOpacity(0.5);
      default:
        if (_isFocused) {
          return theme.colorScheme.primary;
        }
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  OutlineInputBorder _getBorder(ThemeData theme, {
    bool isDefault = false,
    bool isEnabled = false,
    bool isFocused = false,
    bool isError = false,
    bool isDisabled = false,
  }) {
    Color borderColor;
    double borderWidth = 1;

    if (isError) {
      borderColor = VelloTokens.danger;
      borderWidth = isFocused ? 2 : 1;
    } else if (isDisabled) {
      borderColor = theme.colorScheme.outline.withOpacity(0.3);
    } else if (isFocused) {
      borderColor = theme.colorScheme.primary;
      borderWidth = 2;
    } else if (widget.state == VelloInputState.success) {
      borderColor = VelloTokens.success;
    } else {
      borderColor = theme.colorScheme.outline.withOpacity(0.5);
    }

    return OutlineInputBorder(
      borderRadius: VelloTokens.radiusLarge,
      borderSide: BorderSide(
        color: borderColor,
        width: borderWidth,
      ),
    );
  }
}
