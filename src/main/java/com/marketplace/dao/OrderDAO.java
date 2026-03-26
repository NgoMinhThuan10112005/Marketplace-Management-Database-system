package com.marketplace.dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.marketplace.config.DatabaseConnection;
import com.marketplace.model.Order;
public class OrderDAO {

    public void insertOrder(Order order) throws SQLException {
        String query = "{CALL sp_CreateOrder(?, ?, ?, ?)}";

        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             CallableStatement stmt = conn.prepareCall(query)) {
            stmt.setInt(1, order.getBuyerId());
            stmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            stmt.setBigDecimal(3, order.getOrderPrice());
            stmt.registerOutParameter(4, java.sql.Types.INTEGER);
            stmt.execute();
            int newOrderId = stmt.getInt(4);
            order.setOrderId(newOrderId);
            order.setStatus("Draft"); 
        }
    }

    public boolean updateOrder(Order order) throws SQLException {
        String query = "{CALL sp_UpdateOrder(?, ?, ?)}";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             CallableStatement stmt = conn.prepareCall(query)) {
            stmt.setInt(1, order.getOrderId());
            if (order.getOrderPrice() != null) {
                stmt.setBigDecimal(2, order.getOrderPrice());
            } else {
                stmt.setNull(2, java.sql.Types.DECIMAL);
            }
            if (order.getStatus() != null) {
                stmt.setString(3, order.getStatus());
            } else {
                stmt.setNull(3, java.sql.Types.VARCHAR);
            }

            stmt.execute();
            return true;
        }
    }

    public List<Order> getOrders(String keyword) throws SQLException {
        
        List<Order> orders = new ArrayList<Order>();
        String query = "SELECT * from `Order`";

        try(Connection conn = DatabaseConnection.getInstance().getConnection();
            CallableStatement stmt = conn.prepareCall(query);
            ResultSet rs = stmt.executeQuery();){

            while(rs.next()){
                Order order = new Order();
                order.setOrderId(rs.getInt("OrderID"));
                order.setBuyerId(rs.getInt("BuyerID"));
                order.setOrderAt(rs.getTimestamp("OrderAt"));
                order.setOrderPrice(rs.getBigDecimal("OrderPrice"));
                order.setStatus(rs.getString("Status"));
                int paymentId = rs.getInt("PaymentID");
                if(rs.wasNull()){
                    order.setPaymentId(null);
                } else {
                    order.setPaymentId(paymentId);
                }
                orders.add(order);
            }

        } catch (SQLException e) {
            System.err.println("Error fetching orders: " + e.getMessage());
            e.printStackTrace();
        }
        return orders;
    }
    public boolean isBuyerValid(int buyerId) {
        String query = "SELECT COUNT(*) FROM Buyer WHERE UserID = ?";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, buyerId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error checking buyer validity: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public Order getOrderById(int orderId) throws SQLException {
        String query = "SELECT * FROM `Order` WHERE OrderID = ?";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
            PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, orderId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getInt("OrderID"));
                    order.setBuyerId(rs.getInt("BuyerID"));
                    order.setOrderAt(rs.getTimestamp("OrderAt"));
                    order.setOrderPrice(rs.getBigDecimal("OrderPrice"));
                    order.setStatus(rs.getString("Status"));
                    
                    int paymentId = rs.getInt("PaymentID");
                    if (rs.wasNull()) {
                        order.setPaymentId(null);
                    } else {
                        order.setPaymentId(paymentId);
                    }
                    return order;
                }
            }
        }
        return null; 
    }

    public boolean deleteOrder(int orderId) throws SQLException {
        String query = "{CALL sp_DeleteOrder(?)}";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             CallableStatement stmt = conn.prepareCall(query)) {
            stmt.setInt(1, orderId);
            stmt.execute();
            return true;
        }
    }

    public int addOrderItem(int orderId, int variantId, int productId, int quantity) throws SQLException {
        String query = "{CALL sp_AddOrderItem(?, ?, ?, ?, ?)}";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             CallableStatement stmt = conn.prepareCall(query)) {
            stmt.setInt(1, orderId);
            stmt.setInt(2, variantId);
            stmt.setInt(3, productId);
            stmt.setInt(4, quantity);
            stmt.registerOutParameter(5, java.sql.Types.INTEGER);
            stmt.execute();
            return stmt.getInt(5);
        }
    }
}