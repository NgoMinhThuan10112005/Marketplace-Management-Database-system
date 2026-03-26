package com.marketplace.dao;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.marketplace.config.DatabaseConnection;
import com.marketplace.model.OrderSummaryByBuyer;

public class OrderSummaryDAO {
    public List<OrderSummaryByBuyer> getOrderSummaryByBuyer(
            String status,
            java.sql.Timestamp startDate,
            java.sql.Timestamp endDate,
            Integer minOrderCount,
            BigDecimal minTotalSpent) throws SQLException {
        
        List<OrderSummaryByBuyer> summaries = new ArrayList<>();
        String sql = "{CALL sp_GetOrderSummaryByBuyer(?, ?, ?, ?, ?)}";
        
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             CallableStatement stmt = conn.prepareCall(sql)) {
            if (status == null) {
                stmt.setNull(1, Types.VARCHAR);
            } else {
                stmt.setString(1, status);
            }
            if (startDate == null) {
                stmt.setNull(2, Types.DATE);
            } else {
                stmt.setDate(2, new java.sql.Date(startDate.getTime()));
            }
            if (endDate == null) {
                stmt.setNull(3, Types.DATE);
            } else {
                stmt.setDate(3, new java.sql.Date(endDate.getTime()));
            }
            if (minOrderCount == null) {
                stmt.setNull(4, Types.INTEGER);
            } else {
                stmt.setInt(4, minOrderCount);
            }
            if (minTotalSpent == null) {
                stmt.setNull(5, Types.DECIMAL);
            } else {
                stmt.setBigDecimal(5, minTotalSpent);
            }
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                OrderSummaryByBuyer summary = new OrderSummaryByBuyer();
                summary.setBuyerID(rs.getInt("BuyerID"));
                summary.setBuyerName(rs.getString("BuyerName"));
                summary.setBuyerEmail(rs.getString("BuyerEmail"));
                summary.setTotalOrders(rs.getInt("TotalOrders"));
                summary.setTotalItemsPurchased(rs.getInt("TotalItemsPurchased"));
                summary.setTotalSpent(rs.getBigDecimal("TotalSpent"));
                summary.setTotalTax(rs.getBigDecimal("TotalTax"));
                summary.setGrandTotal(rs.getBigDecimal("GrandTotal"));
                summary.setAverageOrderValue(rs.getBigDecimal("AverageOrderValue"));
                summaries.add(summary);
            }
        } catch (SQLException e) {
            System.err.println("Error calling sp_GetOrderSummaryByBuyer: " + e.getMessage());
            throw e;
        }
        return summaries;
    }
}