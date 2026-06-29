package com.tikgate.util;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Date;
import java.util.regex.Pattern;

public final class ValidationUtil {
    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[A-Za-z0-9_]{3,30}$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9]{10,15}$");
    private static final Pattern TIME_PATTERN = Pattern.compile("^([01][0-9]|2[0-3]):[0-5][0-9]$");
    private static final Pattern UUID_PATTERN = Pattern.compile("^[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12}$");

    private ValidationUtil() {}

    public static String clean(String value) {
        return value == null ? "" : value.trim();
    }

    public static boolean isBlank(String value) {
        return clean(value).isEmpty();
    }

    public static boolean isSafeText(String value, int minLength, int maxLength) {
        String clean = clean(value);
        return clean.length() >= minLength
            && clean.length() <= maxLength
            && !clean.contains("<")
            && !clean.contains(">")
            && !containsControlCharacters(clean);
    }

    public static boolean isValidUsername(String username) {
        return USERNAME_PATTERN.matcher(clean(username)).matches();
    }

    public static boolean isValidFullName(String fullName) {
        return isSafeText(fullName, 2, 100);
    }

    public static boolean isValidEmail(String email) {
        return EMAIL_PATTERN.matcher(clean(email)).matches() && clean(email).length() <= 100;
    }

    public static boolean isValidPhone(String phone) {
        return PHONE_PATTERN.matcher(clean(phone)).matches();
    }

    public static boolean isValidPassword(String password) {
        String clean = clean(password);
        return clean.length() >= 8
            && clean.length() <= 72
            && clean.matches(".*[A-Za-z].*")
            && clean.matches(".*[0-9].*")
            && !clean.matches(".*\\s.*");
    }

    public static boolean isValidTime(String time) {
        return TIME_PATTERN.matcher(clean(time)).matches();
    }

    public static boolean isEndAfterStart(String startTime, String endTime) {
        if (!isValidTime(startTime) || !isValidTime(endTime)) {
            return false;
        }
        return clean(endTime).compareTo(clean(startTime)) > 0;
    }

    public static boolean isTodayOrFuture(Date date) {
        if (date == null) {
            return false;
        }
        LocalDate input = new java.sql.Date(date.getTime()).toLocalDate();
        return !input.isBefore(LocalDate.now());
    }

    public static Integer parsePositiveInt(String value) {
        try {
            int parsed = Integer.parseInt(clean(value));
            return parsed > 0 ? parsed : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    public static BigDecimal parsePositiveMoney(String value) {
        try {
            BigDecimal parsed = new BigDecimal(clean(value));
            return parsed.compareTo(BigDecimal.ZERO) > 0 ? parsed : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    public static boolean isAllowedPaymentMethod(String paymentMethod) {
        String method = clean(paymentMethod);
        return "Credit Card".equals(method) || "Online Banking".equals(method) || "E-Wallet".equals(method);
    }

    public static String digitsOnly(String value) {
        return clean(value).replaceAll("\\D", "");
    }

    public static boolean isValidCardNumber(String cardNumber) {
        String digits = digitsOnly(cardNumber);
        if (!digits.matches("^[0-9]{13,19}$")) {
            return false;
        }
        int sum = 0;
        boolean doubleDigit = false;
        for (int i = digits.length() - 1; i >= 0; i--) {
            int digit = digits.charAt(i) - '0';
            if (doubleDigit) {
                digit *= 2;
                if (digit > 9) {
                    digit -= 9;
                }
            }
            sum += digit;
            doubleDigit = !doubleDigit;
        }
        return sum % 10 == 0;
    }

    public static boolean isValidExpiry(String expiry) {
        String clean = clean(expiry);
        if (!clean.matches("^(0[1-9]|1[0-2])/[0-9]{2}$")) {
            return false;
        }
        try {
            YearMonth cardMonth = YearMonth.parse("20" + clean.substring(3) + "-" + clean.substring(0, 2), DateTimeFormatter.ofPattern("yyyy-MM"));
            return !cardMonth.isBefore(YearMonth.now());
        } catch (DateTimeParseException ex) {
            return false;
        }
    }

    public static boolean isValidCvv(String cvv) {
        return clean(cvv).matches("^[0-9]{3,4}$");
    }

    public static boolean isValidQrCode(String qrCode) {
        return UUID_PATTERN.matcher(clean(qrCode)).matches();
    }

    private static boolean containsControlCharacters(String value) {
        for (int i = 0; i < value.length(); i++) {
            if (Character.isISOControl(value.charAt(i))) {
                return true;
            }
        }
        return false;
    }
}
