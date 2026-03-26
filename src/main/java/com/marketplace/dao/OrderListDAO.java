package com.marketplace.dao;

import com.marketplace.config.DatabaseConnection;
import com.marketplace.model.*;
import java.sql.*;

import java.util.*;
public class OrderListDAO {
    
    public List<OrderList> getOrderList(String p_status, Integer p_buyerID,
                                 Timestamp p_startDate, Timestamp p_endDate,
                                 String p_sortColumn, String p_sortDirection) {
        List<OrderList> orderLists = new ArrayList<>();
        String query = "CALL sp_GetOrdersList(?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             CallableStatement stmt = conn.prepareCall(query)) {

             if (p_status != null) {
                 stmt.setString(1, p_status);
             } else {
                 stmt.setNull(1, java.sql.Types.VARCHAR);
             }
             if (p_buyerID != null) {
                 stmt.setInt(2, p_buyerID);
             } else {
                 stmt.setNull(2, java.sql.Types.INTEGER);
             }
             if (p_startDate != null) {
                 stmt.setTimestamp(3, p_startDate);
             } else {
                 stmt.setNull(3, java.sql.Types.TIMESTAMP);
             }
             if (p_endDate != null) {
                 stmt.setTimestamp(4, p_endDate);
             } else {
                 stmt.setNull(4, java.sql.Types.TIMESTAMP);
             }
             if (p_sortColumn != null) {
                 stmt.setString(5, p_sortColumn);
             } else {
                 stmt.setNull(5, java.sql.Types.VARCHAR);
             }
             if (p_sortDirection != null) {
                 stmt.setString(6, p_sortDirection);
             } else {
                 stmt.setNull(6, java.sql.Types.VARCHAR);
             }
            
             ResultSet rs = stmt.executeQuery(); 

            while (rs.next()) {
                OrderList orderList = new OrderList();
                orderList.setOrderID(rs.getInt("OrderID"));
                orderList.setOrderAt(rs.getTimestamp("OrderAt"));
                orderList.setOrderPrice(rs.getDouble("OrderPrice"));
                orderList.setTaxAmount(rs.getDouble("TaxAmount"));
                orderList.setStatus(rs.getString("Status"));
                orderList.setBuyerID(rs.getInt("BuyerID"));
                orderList.setBuyerName(rs.getString("BuyerName"));
                orderList.setBuyerEmail(rs.getString("BuyerEmail"));
                orderList.setPaymentStatus(rs.getString("PaymentStatus"));
                
                orderLists.add(orderList);
            }

        } catch (Exception e) {
            System.err.println("Lỗi lấy danh sách đơn hàng: " + e.getMessage());
            e.printStackTrace();
        }

        return orderLists;
    }
    
}
