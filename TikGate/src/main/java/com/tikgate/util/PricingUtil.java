package com.tikgate.util;

public final class PricingUtil {
    private static final double TICKET_PRICE = 150.00;

    private PricingUtil() {}

    public static double getTicketPrice() {
        return TICKET_PRICE;
    }
}
