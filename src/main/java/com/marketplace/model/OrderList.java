package com.marketplace.model;

import java.sql.Timestamp;
import java.text.DecimalFormat;

import javax.swing.table.AbstractTableModel;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor


public class OrderList {
    private int OrderID;         
    private Timestamp OrderAt;         
    private double OrderPrice;    
    private double TaxAmount;          
    private String Status;        
    private int BuyerID;    
    private String BuyerName;
    private String BuyerEmail;
    private String PaymentStatus;
}

