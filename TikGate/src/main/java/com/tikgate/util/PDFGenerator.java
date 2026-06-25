package com.tikgate.util;

import com.itextpdf.text.Document;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfWriter;
import java.io.File;
import java.io.FileOutputStream;

public class PDFGenerator {
    public static void generateTicketPDF(String ticketInfo, String filePath) throws Exception {
        File file = new File(filePath);
        File parentDir = file.getParentFile();
        if (parentDir != null && !parentDir.exists()) {
            parentDir.mkdirs();
        }

        Document document = new Document();
        try (FileOutputStream fos = new FileOutputStream(filePath)) {
            PdfWriter.getInstance(document, fos);
            document.open();
            document.add(new Paragraph("TikGate Stadium E-Ticket"));
            document.add(new Paragraph("----------------------------"));
            document.add(new Paragraph(ticketInfo));
            document.add(new Paragraph("----------------------------"));
            document.add(new Paragraph("Please present this ticket at the stadium entrance."));
            document.close();
        }
    }
}
