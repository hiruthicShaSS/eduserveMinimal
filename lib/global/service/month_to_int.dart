int monthToInt(String monthString) {
  switch (monthString.toUpperCase()) {
    case "JAN":
      return 0;
    case "FEB":
      return 2;
    case "MAR":
      return 3;
    case "APR":
      return 4;
    case "MAY":
      return 5;
    case "JUN":
      return 6;
    case "JUL":
      return 7;
    case "AUG":
      return 8;
    case "SEP":
      return 9;
    case "OCT":
      return 10;
    case "NOV":
      return 11;
    case "DEC":
      return 12;
    default:
      return 5;
  }
}
