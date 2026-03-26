package com.marketplace.model;

import java.util.List;

import javax.swing.table.AbstractTableModel;

public class OrderTableModel extends AbstractTableModel {

    private List<OrderList> orderList;
    private String[] columnNames = 
    {"Order ID",
     "Order At",
     "Order Price",
     "Tax Amount",
     "Status",
     "Buyer ID",
     "Buyer Name",
     "Buyer Email",
     "Payment Status",}; 
    
    public OrderTableModel(List<OrderList> orderList){
        this.orderList = orderList;
    }
    
    @Override
    public int getRowCount(){
        return orderList.size();
    }

    @Override
    public int getColumnCount(){
        return columnNames.length;
    }

    @Override
    public String getColumnName(int column){
        return columnNames[column];
    }
    
    @Override
    public Object getValueAt(int rowIndex, int columnIndex){
        OrderList order = orderList.get(rowIndex);
        switch (columnIndex) {
            case 0:
                return order.getOrderID();
            case 1:
                return order.getOrderAt();
            case 2:
                return order.getOrderPrice();
            case 3:
                return order.getTaxAmount();
            case 4:
                return order.getStatus();
            case 5:
                return order.getBuyerID();
            case 6:
                return order.getBuyerName();
            case 7:
                return order.getBuyerEmail();
            case 8:
                return order.getPaymentStatus();
            default:
                return null;
        }
    }
}