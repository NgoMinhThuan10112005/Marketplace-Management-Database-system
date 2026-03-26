package com.marketplace.model;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ProductViewModel {
    private int productId;
    private int variantId;
    private String displayName;
    private String category;
    private double averageRating;
    private int totalReviews;
    private BigDecimal price;
    private String imageUrl;
}
