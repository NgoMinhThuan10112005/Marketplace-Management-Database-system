package com.marketplace.model;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;

import javax.swing.table.AbstractTableModel;

public class OrderSummaryTableModel extends AbstractTableModel {
    
    private List<OrderSummaryByBuyer> summaries;
    private final String[] columnNames = {
        "Buyer ID",
        "Buyer Name", 
        "Email",
        "Total Orders",
        "Total Items",
        "Total Spent",
        "Total Tax",
        "Grand Total",
        "Avg Order Value"
    };
    
    private final NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(Locale.US);
    
    public OrderSummaryTableModel(List<OrderSummaryByBuyer> summaries) {
        this.summaries = summaries;
    }
    
    @Override
    public int getRowCount() {
        return summaries.size();
    }
    
    @Override
    public int getColumnCount() {
        return columnNames.length;
    }
    
    @Override
    public String getColumnName(int column) {
        return columnNames[column];
    }
    
    @Override
    public Class<?> getColumnClass(int columnIndex) {
        switch (columnIndex) {
            case 0:
            case 3:
            case 4:
                return Integer.class;
            case 5:
            case 6:
            case 7:
            case 8:
                return String.class;
            default:
                return String.class;
        }
    }
    
    @Override
    public Object getValueAt(int rowIndex, int columnIndex) {
        OrderSummaryByBuyer summary = summaries.get(rowIndex);
        
        switch (columnIndex) {
            case 0:
                return summary.getBuyerID();
            case 1:
                return summary.getBuyerName();
            case 2:
                return summary.getBuyerEmail();
            case 3:
                return summary.getTotalOrders();
            case 4:
                return summary.getTotalItemsPurchased();
            case 5:
                return formatCurrency(summary.getTotalSpent());
            case 6:
                return formatCurrency(summary.getTotalTax());
            case 7:
                return formatCurrency(summary.getGrandTotal());
            case 8:
                return formatCurrency(summary.getAverageOrderValue());
            default:
                return null;
        }
    }
    
    private String formatCurrency(BigDecimal amount) {
        if (amount == null) {
            return "$0.00";
        }
        return currencyFormat.format(amount);
    }
    
    public OrderSummaryByBuyer getSummaryAt(int rowIndex) {
        return summaries.get(rowIndex);
    }
}