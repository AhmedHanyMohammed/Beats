import 'package:flutter/cupertino.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);

// Login flow notifiers
ValueNotifier<bool> obscurePasswordNotifier = ValueNotifier(true);
ValueNotifier<bool> loginIsLoadingNotifier = ValueNotifier(false);
ValueNotifier<bool> loginShowSuccessNotifier = ValueNotifier(false);

// Register flow notifiers
ValueNotifier<bool> registerObscurePasswordNotifier = ValueNotifier(true);
ValueNotifier<bool> registerIsLoadingNotifier = ValueNotifier(false);
ValueNotifier<bool> registerShowSuccessNotifier = ValueNotifier(false);

// Forgot password flow notifiers (added)
ValueNotifier<bool> forgotIsLoadingNotifier = ValueNotifier(false);
ValueNotifier<bool> forgotShowSuccessNotifier = ValueNotifier(false);

// Current logged-in user's first name (UI only, not persisted)
ValueNotifier<String> userFirstNameNotifier = ValueNotifier<String>('Doctor');
