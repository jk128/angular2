import 'dart:async';

import 'package:angular2/src/transform/common/asset_reader.dart';
import 'package:angular2/src/transform/common/names.dart';
import 'package:angular2/src/transform/common/zone.dart' as zone;
import 'package:barback/barback.dart';

import 'processor.dart';

/// Pre-compiles CSS stylesheet files to Dart code for Angular 2.
class StylesheetCompiler extends Transformer implements LazyTransformer {
  StylesheetCompiler();

  @override
  bool isPrimary(AssetId id) {
    return id.path.endsWith(CSS_EXTENSION);
  }

  @override
  declareOutputs(DeclaringTransform transform) {
    // Note: we check this assumption below.
    _getExpectedOutputs(transform.primaryId).forEach(transform.declareOutput);
  }

  List<AssetId> _getExpectedOutputs(AssetId cssId) =>
      [shimmedStylesheetAssetId(cssId), nonShimmedStylesheetAssetId(cssId)];

  @override
  Future apply(Transform transform) async {
    final reader = new AssetReader.fromTransform(transform);
    return zone.exec(() async {
      var primaryId = transform.primaryInput.id;
      var outputs = await processStylesheet(reader, primaryId);
      var expectedIds = _getExpectedOutputs(primaryId);
      outputs.forEach((Asset compiledStylesheet) {
        var id = compiledStylesheet.id;
        if (!expectedIds.contains(id)) {
          throw new StateError(
              'Unexpected output for css processing of $primaryId: $id');
        }
        transform.addOutput(compiledStylesheet);
      });
    }, log: transform.logger);
  }
}
