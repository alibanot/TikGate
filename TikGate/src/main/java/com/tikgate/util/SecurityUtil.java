package com.tikgate.util;

import com.tikgate.model.User;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

public final class SecurityUtil {
    public static final int ROLE_ADMIN = 1;
    public static final int ROLE_CUSTOMER = 2;
    public static final int ROLE_STAFF = 3;

    private static final String CSRF_SESSION_KEY = "csrfToken";
    private static final SecureRandom RANDOM = new SecureRandom();

    private SecurityUtil() {}

    public static User currentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null ? null : (User) session.getAttribute("user");
    }

    public static boolean isAdmin(User user) {
        return user != null && user.getRoleId() == ROLE_ADMIN;
    }

    public static boolean isCustomer(User user) {
        return user != null && user.getRoleId() == ROLE_CUSTOMER;
    }

    public static boolean isStaffOrAdmin(User user) {
        return user != null && (user.getRoleId() == ROLE_STAFF || user.getRoleId() == ROLE_ADMIN);
    }

    public static boolean canManageCatalog(User user) {
        return isStaffOrAdmin(user);
    }

    public static String ensureCsrfToken(HttpServletRequest request) {
        HttpSession session = request.getSession();
        String token = (String) session.getAttribute(CSRF_SESSION_KEY);
        if (token == null || token.isEmpty()) {
            token = newToken();
            session.setAttribute(CSRF_SESSION_KEY, token);
        }
        return token;
    }

    public static boolean isValidCsrf(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        String expected = (String) session.getAttribute(CSRF_SESSION_KEY);
        String actual = request.getParameter("csrfToken");
        return expected != null && actual != null && expected.equals(actual);
    }

    public static String hashPassword(String password) {
        return "sha256:" + sha256Hex(ValidationUtil.clean(password));
    }

    public static boolean passwordMatches(String rawPassword, String storedPassword) {
        if (storedPassword == null) {
            return false;
        }
        String cleanStored = storedPassword.trim();
        if (cleanStored.startsWith("sha256:")) {
            return hashPassword(rawPassword).equals(cleanStored);
        }
        return ValidationUtil.clean(rawPassword).equals(storedPassword);
    }

    public static boolean isLegacyPlainPassword(String storedPassword) {
        return storedPassword != null && !storedPassword.trim().startsWith("sha256:");
    }

    public static String escapeHtml(Object value) {
        if (value == null) {
            return "";
        }
        String text = String.valueOf(value);
        StringBuilder escaped = new StringBuilder(text.length());
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            switch (c) {
                case '&':
                    escaped.append("&amp;");
                    break;
                case '<':
                    escaped.append("&lt;");
                    break;
                case '>':
                    escaped.append("&gt;");
                    break;
                case '"':
                    escaped.append("&quot;");
                    break;
                case '\'':
                    escaped.append("&#x27;");
                    break;
                default:
                    escaped.append(c);
                    break;
            }
        }
        return escaped.toString();
    }

    private static String newToken() {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        return toHex(bytes);
    }

    private static String sha256Hex(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return toHex(digest.digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 is unavailable", ex);
        }
    }

    private static String toHex(byte[] bytes) {
        StringBuilder hex = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            hex.append(String.format("%02x", b));
        }
        return hex.toString();
    }
}
