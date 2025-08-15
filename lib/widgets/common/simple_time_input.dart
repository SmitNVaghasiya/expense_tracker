import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/time_format_service.dart';

class SimpleTimeInput extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChanged;
  final String? label;
  final bool enabled;
  final bool? use24HourFormat; // Made optional to allow auto-detection

  const SimpleTimeInput({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
    this.label,
    this.enabled = true,
    this.use24HourFormat, // Allow null for auto-detection
  });

  @override
  State<SimpleTimeInput> createState() => _SimpleTimeInputState();
}

class _SimpleTimeInputState extends State<SimpleTimeInput> {
  late TextEditingController _controller;
  late TimeOfDay _currentTime;
  bool _hasError = false;
  bool _is24HourFormat = true;
  bool _isAM = true;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.initialTime;
    _isAM = _currentTime.hour < 12;
    _initializeTimeFormat();
    _controller = TextEditingController(
      text: _formatTimeOfDay(_currentTime),
    );
  }

  Future<void> _initializeTimeFormat() async {
    await TimeFormatService.initialize();
    setState(() {
      // Use provided preference or auto-detect from system
      _is24HourFormat = widget.use24HourFormat ?? TimeFormatService.is24HourFormat;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    if (_is24HourFormat) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      int hour12 = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
      return '${hour12.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  void _onTimeChanged(String value) {
    if (value.length == 5 && value.contains(':')) {
      final parts = value.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        
        if (hour != null && minute != null && 
            minute >= 0 && minute <= 59) {
          
          int finalHour = hour;
          
          if (!_is24HourFormat) {
            // Convert 12-hour to 24-hour format
            if (hour == 12) {
              finalHour = _isAM ? 0 : 12;
            } else if (hour < 12) {
              finalHour = _isAM ? hour : hour + 12;
            } else {
              finalHour = _isAM ? hour - 12 : hour;
            }
          }
          
          if (finalHour >= 0 && finalHour <= 23) {
            final newTime = TimeOfDay(hour: finalHour, minute: minute);
            setState(() {
              _currentTime = newTime;
              _hasError = false;
            });
            widget.onTimeChanged(newTime);
            return;
          }
        }
      }
    }
    
    // Show error state for invalid input
    setState(() {
      _hasError = true;
    });
  }

  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _currentTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _currentTime) {
      setState(() {
        _currentTime = picked;
        _isAM = picked.hour < 12;
        _controller.text = _formatTimeOfDay(picked);
        _hasError = false;
      });
      widget.onTimeChanged(picked);
    }
  }

  void _toggleFormat() {
    setState(() {
      _is24HourFormat = !_is24HourFormat;
      _controller.text = _formatTimeOfDay(_currentTime);
    });
    // Update the service preference
    TimeFormatService.setTimeFormat(_is24HourFormat);
  }

  void _toggleAMPM() {
    setState(() {
      _isAM = !_isAM;
      // Convert current time to new AM/PM
      int newHour = _currentTime.hour;
      if (_isAM && _currentTime.hour >= 12) {
        newHour = _currentTime.hour - 12;
      } else if (!_isAM && _currentTime.hour < 12) {
        newHour = _currentTime.hour + 12;
      }
      if (newHour == 0) newHour = 12;
      if (newHour == 24) newHour = 12;
      
      _currentTime = TimeOfDay(hour: newHour, minute: _currentTime.minute);
      _controller.text = _formatTimeOfDay(_currentTime);
      widget.onTimeChanged(_currentTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Format Toggle Row
        Row(
          children: [
            Expanded(
              child: Text(
                'Time Format',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            GestureDetector(
              onTap: _toggleFormat,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _is24HourFormat 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _is24HourFormat 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Text(
                  '24H',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _is24HourFormat 
                        ? Colors.white 
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _toggleFormat,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: !_is24HourFormat 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !_is24HourFormat 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Text(
                  '12H',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: !_is24HourFormat 
                        ? Colors.white 
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Time Input Row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: InputDecoration(
                  hintText: _is24HourFormat ? 'HH:MM (00:00-23:59)' : 'HH:MM (01:00-12:59)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _hasError 
                          ? Colors.red 
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _hasError 
                          ? Colors.red 
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _hasError 
                          ? Colors.red 
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  suffixIcon: Icon(
                    Icons.access_time,
                    color: _hasError 
                        ? Colors.red 
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                onChanged: _onTimeChanged,
                onTap: () {
                  // Auto-format when user starts typing
                  if (_controller.text.isEmpty) {
                    _controller.text = _is24HourFormat ? '00:00' : '12:00';
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            
            // AM/PM Toggle (only for 12-hour format)
            if (!_is24HourFormat) ...[
              GestureDetector(
                onTap: _toggleAMPM,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isAM 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isAM 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Text(
                    'AM',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _isAM 
                          ? Colors.white 
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: _toggleAMPM,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: !_isAM 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: !_isAM 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Text(
                    'PM',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: !_isAM 
                          ? Colors.white 
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            
            // Time Picker Button
            if (widget.enabled)
              IconButton(
                onPressed: _showTimePicker,
                icon: const Icon(Icons.schedule),
                tooltip: 'Pick time',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
        
        // Visual Cues Row
        Row(
          children: [
            Expanded(
              child: Text(
                _is24HourFormat 
                    ? 'Hours: 00-23 | Minutes: 00-59'
                    : 'Hours: 01-12 | Minutes: 00-59',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
        
        if (_hasError) ...[
          const SizedBox(height: 4),
          Text(
            _is24HourFormat
                ? 'Please enter time in HH:MM format (e.g., 14:30)'
                : 'Please enter time in HH:MM format (e.g., 02:30)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}
