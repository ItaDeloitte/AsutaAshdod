//Test: ValidateUtilTest
public class ValidateUtil {
    public static boolean isValidIdNumber(string idNumber) {
        if (idNumber.length() != 9 || (checkDigit(Integer.valueOf(idNumber.substring(0,8))) != Integer.valueOf(idNumber.substring(8,9)))) {
            return false;
        }
        return true;
    }

    public static Integer checkDigit(Integer num) {
        Integer digit, sum = 0;
        for (Integer i = 1; i <= 8; i++) {
            digit =  math.mod(num , 10);
            if ( math.mod(i , 2) != 0) digit *= 2;
            sum += math.mod(digit , 10) + digit / 10;
            num = num / 10;
        }
        Integer checkdigit  = (1 + sum / 10) * 10 - sum;
        checkdigit = math.mod(checkdigit , 10);
        return checkdigit;
    }

    

    public static Boolean isValidIsraeliMobile(String phone) {
        if(String.isBlank(phone)) {
            return false;
        }
        // replace all spaces and -
        String cleaned = phone.replaceAll('[^\\d]', '');

        // format with +972
        if(cleaned.startsWith('972') && cleaned.length() == 12) {
            cleaned = '0' + cleaned.substring(3);
        }

        if(cleaned.length() != 10 || !cleaned.startsWith('05')) {
            return false;
        }

        String thirdDigit = cleaned.substring(2, 3);
        Set<String> validOperators = new Set<String>{'0','1','2','3','4','5','7','8','9'};
        if(!validOperators.contains(thirdDigit)) {
            return false;
        }
        return true;
    }

}