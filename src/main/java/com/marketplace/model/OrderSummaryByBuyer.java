package com.marketplace.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.DecimalFormat;

import javax.swing.table.AbstractTableModel;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor

public class OrderSummaryByBuyer {
    private Integer buyerID;
    private String buyerName;
    private String buyerEmail;
    private Integer totalOrders;
    private Integer totalItemsPurchased;
    private BigDecimal totalSpent;
    private BigDecimal totalTax;
    private BigDecimal grandTotal;
    private BigDecimal averageOrderValue;

    public String toString(){
        return "OrderSummaryByBuyer{" +
                "buyerID=" + buyerID +
                ", buyerName='" + buyerName + '\'' +
                ", buyerEmail='" + buyerEmail + '\'' +
                ", totalOrders=" + totalOrders +
                ", totalItemsPurchased=" + totalItemsPurchased +
                ", totalSpent=" + totalSpent +
                ", totalTax=" + totalTax +
                ", grandTotal=" + grandTotal +
                ", averageOrderValue=" + averageOrderValue +
                '}';
    }
}
