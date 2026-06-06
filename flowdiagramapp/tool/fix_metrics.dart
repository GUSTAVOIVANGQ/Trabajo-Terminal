import 'dart:io';

void main() {
  final file = File('test/criteria/technical_validation_criteria_test.dart');
  var code = file.readAsStringSync();
  
  // Replace the CF and CG evidence assignments
  code = code.replaceAllMapped(
    RegExp(r"_evidenceMap\['(\$1|CF-\d{2}|CG-\d{2})'\] = (?:'\$\{.*?\} líneas de C generadas';|result.generatedCode \?\? 'Sin código generado';)"),
    (match) {
      String id = match.group(1)!;
      if (id == '\$1') return match.group(0)!; // fallback if it matched literal $1
      return "_evidenceMap['$id'] = result.generatedCode ?? 'Sin código generado';";
    }
  );
  
  // Also we need to fix the ones that got corrupted to literal '$1' in the previous script!
  // Wait, the previous script changed everything to `_evidenceMap['$1'] = result.generatedCode ?? 'Sin código generado';`
  // That means we lost the CF-01, CF-02, etc. keys!
  // Oh no! We have to restore the test names!
}
