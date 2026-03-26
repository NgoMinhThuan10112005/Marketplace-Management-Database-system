package com.marketplace.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.marketplace.config.DatabaseConnection;
import com.marketplace.model.Product;
import com.marketplace.model.ProductViewModel;

public class ProductDAO {

    public List<ProductViewModel> getAllProductVariants() {
        List<ProductViewModel> products = new ArrayList<>();
        Map<Integer, ProductViewModel> productMap = new HashMap<>();
        String query = "SELECT p.ProductName, p.ProductID, p.Category, p.AverageRating, p.TotalReviews, " +
                       "(SELECT pi.ImageURL FROM product_images pi WHERE pi.ProductID = p.ProductID LIMIT 1) AS ImageURL, " +
                       "pv.VariantID, pv.VariantName, pv.Price " +
                       "FROM Product p " +
                       "JOIN ProductVariant pv ON p.ProductID = pv.ProductID " +
                       "WHERE pv.Status = 'Available' " +
                       "ORDER BY p.ProductID, pv.VariantID";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                int productId = rs.getInt("ProductID");
                if (!productMap.containsKey(productId)) {
                    ProductViewModel vm = new ProductViewModel();
                    vm.setProductId(productId);
                    vm.setVariantId(rs.getInt("VariantID"));
                    vm.setDisplayName(rs.getString("VariantName"));
                    vm.setCategory(rs.getString("Category"));
                    vm.setAverageRating(rs.getDouble("AverageRating"));
                    vm.setTotalReviews(rs.getInt("TotalReviews"));
                    vm.setPrice(rs.getBigDecimal("Price"));
                    vm.setImageUrl(rs.getString("ImageURL"));
                    productMap.put(productId, vm);
                    products.add(vm);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching product variants: " + e.getMessage());
            e.printStackTrace();
        }
        return products;
    }

    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        String query = "SELECT * FROM Product"; 
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Product product = new Product();
                product.setProductId(rs.getInt("ProductID"));
                product.setUserId(rs.getInt("UserID"));
                product.setProductName(rs.getString("ProductName"));
                product.setDescription(rs.getString("Description"));
                product.setCategory(rs.getString("Category"));
                product.setStatus(rs.getString("Status"));
                product.setAddedAt(rs.getTimestamp("AddedAt"));
                product.setTotalReviews(rs.getInt("TotalReviews"));
                product.setAverageRating(rs.getDouble("AverageRating"));
                products.add(product);
            }
        } catch (SQLException e) {
             System.err.println("Error fetching products: " + e.getMessage());
             e.printStackTrace();
        }
        return products;
    }
}