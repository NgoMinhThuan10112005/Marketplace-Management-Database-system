package com.marketplace.model;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ProductVariant {
    private int variantId;
    private int productId;
    private String variantName;
    private String color;
    private String size;
    private BigDecimal price;
    private int stockQuantity;
    private String status;
    private String imageUrl;
}
