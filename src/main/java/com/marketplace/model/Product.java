package com.marketplace.model;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Product {
    private int productId;
    private int userId;
    private String productName;
    private String description;
    private String category;
    private String status;
    private Timestamp addedAt;
    private int totalReviews;
    private double averageRating;
}