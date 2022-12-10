class _RawValue {
  String character;
  bool isNew;

  _RawValue(this.character, this.isNew);
}
String conformToMask(String value, List<String> mask, {
  String previousConformedValue = '',
  String placeholderChar = '_'
}) {
  final placeholder = mask.map((character) => character.startsWith('/') && character.endsWith('/')? placeholderChar:character).join('');
  final currentCaretPosition = value.length;

  final suppressGuide = true;
  final rawValueLength = value.length;
  final previousConformedValueLength = previousConformedValue.length;
  final placeholderLength = placeholder.length;
  final maskLength = mask.length;

  final editDistance = rawValueLength - previousConformedValueLength;
  final isAddition = editDistance > 0;
  final indexOfFirstChange = currentCaretPosition + (isAddition ? -editDistance : 0);
  final indexOfLastChange = indexOfFirstChange + editDistance.abs();

  List<_RawValue> rawValueArr = [];
  for(var index = 0; index < value.length; index++) {
    rawValueArr.add(_RawValue(value[index], index >= indexOfFirstChange && index < indexOfLastChange));
  }

  for(var index = rawValueLength - 1; index >= 0; index--) {
    final character = rawValueArr[index].character;

    if(character != placeholderChar) {
      final shouldOffset = index >= indexOfFirstChange && previousConformedValueLength == maskLength;
      if(character == placeholder[shouldOffset? index - editDistance : index]) {
        rawValueArr.removeAt(index);
      }
    }
  }
  
  var conformedValue = '';

  placeholderLoop: for(var index = 0; index < placeholderLength; index++) {
    final charInPlaceholder = placeholder[index];

    if(charInPlaceholder == placeholderChar) {
      if(rawValueArr.length > 0) {
        while(rawValueArr.length > 0) {
          final rawValueCurrent = rawValueArr.removeAt(0);
          final rawValueChar = rawValueCurrent.character;

          final maskCharacter = mask[index] != null && mask[index].startsWith('/') && mask[index].endsWith('/')
            ? RegExp(mask[index].substring(1, mask[index].length - 1))
            : null;

          if(rawValueChar == placeholderChar && suppressGuide != true) {
            conformedValue += placeholderChar;
            continue placeholderLoop;
          } else if(maskCharacter?.hasMatch(rawValueChar) ?? false) {
            conformedValue += rawValueChar;
            continue placeholderLoop;
          }
        }
      }
      break;
      
    } else {
      conformedValue += charInPlaceholder;
    }
  }
  
  if(suppressGuide && isAddition == false) {
    int? indexOfLastFilledPlaceholderChar;

    for(var index = 0; index < conformedValue.length; index++) {
      if (placeholder[index] == placeholderChar) {
        indexOfLastFilledPlaceholderChar = index;
      }
    }

    if(indexOfLastFilledPlaceholderChar != null) {
      conformedValue = conformedValue.substring(0, indexOfLastFilledPlaceholderChar + 1);
    } else {
      conformedValue = '';
    }
  }

  return conformedValue;
}