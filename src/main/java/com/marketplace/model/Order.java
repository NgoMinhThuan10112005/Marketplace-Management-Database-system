package com.marketplace.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

// import javax.swing.table.AbstractTableModel;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor


public class Order {
    private int orderId;        
    private int buyerId;          
    private Timestamp orderAt;   
    private BigDecimal orderPrice;
    private String status;      
    private Integer paymentId;
}

