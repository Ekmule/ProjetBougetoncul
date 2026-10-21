import 'package:flutter/material.dart';

import 'package:mya/l10n/mya_localizations.dart';



/// Rétrocompatibilité phase A — préférer [MyaLocalizations] / `context.l10n`.

typedef PhaseAString = MyaLocalizations;



extension PhaseAStringContext on BuildContext {

  PhaseAString get phaseA => MyaLocalizations.of(this);

}


