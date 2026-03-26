package com.marketplace.ui.components;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.GridLayout;
import java.awt.Image;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import javax.imageio.ImageIO;
import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.DefaultCellEditor;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSpinner;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.SpinnerNumberModel;
import javax.swing.SwingUtilities;
import javax.swing.border.EmptyBorder;
import javax.swing.table.DefaultTableModel;

import com.marketplace.dao.OrderDAO;
import com.marketplace.dao.ProductDAO;
import com.marketplace.model.Order;
// import com.marketplace.model.Product;
import com.marketplace.model.ProductViewModel;

public class BuyerView extends JFrame {
    private JLabel lblTitle;
    private JPanel productPanel;
    private JButton btnAddOrder;
    private JButton btnViewCart;
    private JScrollPane scrollPane;
    private OrderDAO orderDAO;
    private JTextField txtBuyerId;
    
    private Map<String, CartItem> shoppingCart;
    
    private BuyerView() {
        shoppingCart = new HashMap<>();
        orderDAO = new OrderDAO();
        initComponents();
        setTitle("Buyer View");
        setSize(900, 600);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);
    }
    public static BuyerView instance;
    
    public static BuyerView getInstance() {
        if (instance == null) {
            instance = new BuyerView();
        }
        return instance;
    }
    
    private void initComponents() {
        setLayout(new BorderLayout(10, 10));
        
        JPanel northPanel = new JPanel(new BorderLayout());
        northPanel.setBackground(new Color(52, 152, 219));
        northPanel.setBorder(new EmptyBorder(20, 10, 20, 10));
        
        lblTitle = new JLabel("BK");
        lblTitle.setFont(new Font("Arial", Font.BOLD, 28));
        lblTitle.setForeground(Color.WHITE);
        northPanel.add(lblTitle, BorderLayout.WEST);
        
        JPanel buyerPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        buyerPanel.setOpaque(false);
        JLabel lblBuyer = new JLabel("Buyer ID:");
        lblBuyer.setFont(new Font("Arial", Font.BOLD, 14));
        lblBuyer.setForeground(Color.WHITE);
        
        txtBuyerId = new JTextField(10);
        txtBuyerId.setFont(new Font("Arial", Font.PLAIN, 14));
        
        buyerPanel.add(lblBuyer);
        buyerPanel.add(txtBuyerId);
        northPanel.add(buyerPanel, BorderLayout.EAST);
        
        add(northPanel, BorderLayout.NORTH);
        productPanel = new JPanel();
        productPanel.setLayout(new GridLayout(0, 3, 15, 15));
        productPanel.setBorder(new EmptyBorder(20, 20, 20, 20));
        productPanel.setBackground(Color.WHITE);
        loadProducts();   
        scrollPane = new JScrollPane(productPanel);
        scrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED);
        scrollPane.getVerticalScrollBar().setUnitIncrement(16);
        add(scrollPane, BorderLayout.CENTER);
        JPanel southPanel = new JPanel();
        southPanel.setBorder(new EmptyBorder(15, 10, 15, 10));
        southPanel.setBackground(new Color(236, 240, 241));
        southPanel.setLayout(new FlowLayout(FlowLayout.CENTER, 20, 0));
        
        btnViewCart = new JButton("View Cart (0)");
        btnViewCart.setFont(new Font("Arial", Font.BOLD, 16));
        btnViewCart.setPreferredSize(new Dimension(200, 45));
        btnViewCart.setBackground(new Color(52, 152, 219));
        btnViewCart.setForeground(Color.WHITE);
        btnViewCart.setFocusPainted(false);
        btnViewCart.setBorderPainted(false);
        btnViewCart.setCursor(new Cursor(Cursor.HAND_CURSOR));
        btnViewCart.addActionListener(e -> viewCart());
        
        btnAddOrder = new JButton("Place Order");
        btnAddOrder.setFont(new Font("Arial", Font.BOLD, 16));
        btnAddOrder.setPreferredSize(new Dimension(200, 45));
        btnAddOrder.setBackground(new Color(46, 204, 113));
        btnAddOrder.setForeground(Color.WHITE);
        btnAddOrder.setFocusPainted(false);
        btnAddOrder.setBorderPainted(false);
        btnAddOrder.setCursor(new Cursor(Cursor.HAND_CURSOR));
        btnAddOrder.addActionListener(e -> handlePlaceOrder());
        
        southPanel.add(btnViewCart);
        southPanel.add(btnAddOrder);
        add(southPanel, BorderLayout.SOUTH);
    }
    
    private void loadProducts() {
        ProductDAO productDAO = new ProductDAO();
        java.util.List<ProductViewModel> products = productDAO.getAllProductVariants();
        
        if (products.isEmpty()) {
            JLabel lblNoProducts = new JLabel("No product variants available.");
            lblNoProducts.setHorizontalAlignment(JLabel.CENTER);
            lblNoProducts.setFont(new Font("Arial", Font.ITALIC, 18));
            productPanel.add(lblNoProducts);
        } else {
            for (ProductViewModel product : products) {
                JPanel productCard = createProductCard(product);
                productPanel.add(productCard);
            }
        }
    }
    
    private JPanel createProductCard(ProductViewModel product) {
        JPanel card = new JPanel();
        card.setLayout(new BorderLayout(5, 5));
        card.setBorder(BorderFactory.createCompoundBorder(
            BorderFactory.createLineBorder(new Color(189, 195, 199), 1),
            new EmptyBorder(10, 10, 10, 10)
        ));
        card.setBackground(Color.WHITE);
        
        JLabel lblImage = new JLabel();
        lblImage.setPreferredSize(new Dimension(180, 180));
        lblImage.setHorizontalAlignment(JLabel.CENTER);
        lblImage.setOpaque(true);
        lblImage.setBackground(new Color(236, 240, 241));
        lblImage.setBorder(BorderFactory.createLineBorder(new Color(189, 195, 199)));
        
        boolean imageLoaded = false;
        if (product.getImageUrl() != null && !product.getImageUrl().isEmpty()) {
            try {
                URL url = java.net.URI.create(product.getImageUrl()).toURL();
                Image image = ImageIO.read(url);
                if (image != null) {
                    Image scaledImage = image.getScaledInstance(180, 180, Image.SCALE_SMOOTH);
                    lblImage.setIcon(new ImageIcon(scaledImage));
                    imageLoaded = true;
                }
            } catch (Exception e) {
                System.err.println("Failed to load image for " + product.getDisplayName() + ": " + e.getMessage());
            }
        }
        
        if (!imageLoaded) {
            lblImage.setText("🖼️");
            lblImage.setFont(new Font("Arial", Font.PLAIN, 48));
        }
        
        card.add(lblImage, BorderLayout.CENTER);
        
        JPanel infoPanel = new JPanel();
        infoPanel.setLayout(new BoxLayout(infoPanel, BoxLayout.Y_AXIS));
        infoPanel.setBackground(Color.WHITE);
        
        JLabel lblName = new JLabel(product.getDisplayName());
        lblName.setFont(new Font("Arial", Font.BOLD, 14));
        lblName.setAlignmentX(Component.CENTER_ALIGNMENT);
        
        JLabel lblPrice = new JLabel(String.format("$%.2f", product.getPrice()));
        lblPrice.setFont(new Font("Arial", Font.PLAIN, 16));
        lblPrice.setForeground(new Color(231, 76, 60)); 
        lblPrice.setAlignmentX(Component.CENTER_ALIGNMENT);
        
        JLabel lblCategory = new JLabel(String.format("Category: %s", product.getCategory()));
        lblCategory.setFont(new Font("Arial", Font.PLAIN, 12));
        lblCategory.setForeground(Color.GRAY);
        lblCategory.setAlignmentX(Component.CENTER_ALIGNMENT);

        JLabel lblRating = new JLabel(String.format("Rating: %.1f/5.0 (%d)", product.getAverageRating(), product.getTotalReviews()));
        lblRating.setFont(new Font("Arial", Font.PLAIN, 12));
        lblRating.setForeground(new Color(255, 165, 0)); 
        lblRating.setAlignmentX(Component.CENTER_ALIGNMENT);
        
        JButton btnAddToCart = new JButton("Add to Cart");
        btnAddToCart.setAlignmentX(Component.CENTER_ALIGNMENT);
        btnAddToCart.setBackground(new Color(52, 152, 219));
        btnAddToCart.setForeground(Color.WHITE);
        btnAddToCart.setFocusPainted(false);
        btnAddToCart.setCursor(new Cursor(Cursor.HAND_CURSOR));
        
        btnAddToCart.addActionListener(e -> addToCart(product.getVariantId(), product.getProductId(), product.getDisplayName(), product.getPrice().doubleValue()));
        
        infoPanel.add(Box.createVerticalStrut(5));
        infoPanel.add(lblName);
        infoPanel.add(Box.createVerticalStrut(5));
        infoPanel.add(lblPrice);
        infoPanel.add(Box.createVerticalStrut(5));
        infoPanel.add(lblCategory);
        infoPanel.add(lblRating);
        infoPanel.add(Box.createVerticalStrut(10));
        infoPanel.add(btnAddToCart);
        
        card.add(infoPanel, BorderLayout.SOUTH);
        
        return card;
    }
    
    private void addToCart(int variantId, int productId, String productName, double price) {
        SpinnerNumberModel spinnerModel = new SpinnerNumberModel(1, -100, 100, 1); 
        JSpinner quantitySpinner = new JSpinner(spinnerModel);
        quantitySpinner.setPreferredSize(new Dimension(100, 30));
        
        JPanel panel = new JPanel(new GridLayout(3, 1, 5, 5));
        panel.add(new JLabel("Product: " + productName));
        panel.add(new JLabel("Price: $" + String.format("%.2f", price)));
        
        JPanel quantityPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        quantityPanel.add(new JLabel("Quantity: "));
        quantityPanel.add(quantitySpinner);
        panel.add(quantityPanel);
        
        int result = JOptionPane.showConfirmDialog(this, panel, 
            "Add to Cart", JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);
        
        if (result == JOptionPane.OK_OPTION) {
            int quantity = (Integer) quantitySpinner.getValue();
            
            if (quantity <= 0) {
                JOptionPane.showMessageDialog(this,
                    "Quantity must be greater than 0!",
                    "Invalid Quantity",
                    JOptionPane.ERROR_MESSAGE);
                return;
            }
            
            String cartKey = productId + "_" + variantId;
            
            if (shoppingCart.containsKey(cartKey)) {
                CartItem item = shoppingCart.get(cartKey);
                item.quantity += quantity;
            } else {
                shoppingCart.put(cartKey, new CartItem(variantId, productId, productName, price, quantity));
            }
            
            updateCartButton();
            JOptionPane.showMessageDialog(this,
                quantity + "x " + productName + " added to cart!",
                "Success",
                JOptionPane.INFORMATION_MESSAGE);
        }
    }
    
    private void updateCartButton() {
        int totalItems = shoppingCart.values().stream()
            .mapToInt(item -> item.quantity)
            .sum();
        btnViewCart.setText("View Cart (" + totalItems + ")");
    }
    
    private void viewCart() {
        if (shoppingCart.isEmpty()) {
            JOptionPane.showMessageDialog(this,
                "Your cart is empty!",
                "Cart",
                JOptionPane.INFORMATION_MESSAGE);
            return;
        }
        
        JDialog cartDialog = new JDialog(this, "Shopping Cart", true);
        cartDialog.setLayout(new BorderLayout(10, 10));
        cartDialog.setSize(600, 400);
        cartDialog.setLocationRelativeTo(this);
        
        String[] columnNames = {"Product", "Price", "Quantity", "Subtotal", "Action"};
        DefaultTableModel tableModel = new DefaultTableModel(columnNames, 0) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return column == 4; 
            }
        };
        JTable cartTable = new JTable(tableModel);
        cartTable.setRowHeight(30);
                double total = 0;
        for (Map.Entry<String, CartItem> entry : shoppingCart.entrySet()) {
            CartItem item = entry.getValue();
            double subtotal = item.price * item.quantity;
            total += subtotal;
            
            tableModel.addRow(new Object[]{
                item.name,
                String.format("$%.2f", item.price),
                item.quantity,
                String.format("$%.2f", subtotal),
                "Remove"
            });
        }
        cartTable.getColumn("Action").setCellRenderer((table, value, isSelected, hasFocus, row, column) -> {
            JButton btn = new JButton("Remove");
            btn.setBackground(new Color(231, 76, 60));
            btn.setForeground(Color.WHITE);
            return btn;
        });
        
        final double finalTotal = total;
        cartTable.getColumn("Action").setCellEditor(new DefaultCellEditor(new JCheckBox()) {
            @Override
            public Component getTableCellEditorComponent(JTable table, Object value,
                    boolean isSelected, int row, int column) {
                JButton btn = new JButton("Remove");
                btn.setBackground(new Color(231, 76, 60));
                btn.setForeground(Color.WHITE);
                btn.addActionListener(e -> {
                    int modelRow = table.convertRowIndexToModel(row);
                    String productName = (String) tableModel.getValueAt(modelRow, 0);
                    shoppingCart.entrySet().removeIf(entry -> entry.getValue().name.equals(productName));
                    tableModel.removeRow(modelRow);
                    updateCartButton();
                    if (shoppingCart.isEmpty()) {
                        cartDialog.dispose();
                        JOptionPane.showMessageDialog(BuyerView.this,
                            "Cart is now empty!",
                            "Cart",
                            JOptionPane.INFORMATION_MESSAGE);
                    }
                });
                return btn;
            }
        });
        
        JScrollPane scrollPane = new JScrollPane(cartTable);
        cartDialog.add(scrollPane, BorderLayout.CENTER);
        JPanel bottomPanel = new JPanel(new BorderLayout());
        bottomPanel.setBorder(new EmptyBorder(10, 10, 10, 10));
        
        JLabel lblTotal = new JLabel("Total: $" + String.format("%.2f", finalTotal));
        lblTotal.setFont(new Font("Arial", Font.BOLD, 18));
        lblTotal.setForeground(new Color(231, 76, 60));
        bottomPanel.add(lblTotal, BorderLayout.WEST);
        
        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        JButton btnClearCart = new JButton("Clear Cart");
        btnClearCart.setBackground(new Color(231, 76, 60));
        btnClearCart.setForeground(Color.WHITE);
        btnClearCart.addActionListener(e -> {
            int confirm = JOptionPane.showConfirmDialog(cartDialog,
                "Clear all items from cart?",
                "Confirm",
                JOptionPane.YES_NO_OPTION);
            if (confirm == JOptionPane.YES_OPTION) {
                shoppingCart.clear();
                updateCartButton();
                cartDialog.dispose();
            }
        });
        
        JButton btnClose = new JButton("Continue Shopping");
        btnClose.setBackground(new Color(52, 152, 219));
        btnClose.setForeground(Color.WHITE);
        btnClose.addActionListener(e -> cartDialog.dispose());
        
        buttonPanel.add(btnClearCart);
        buttonPanel.add(btnClose);
        bottomPanel.add(buttonPanel, BorderLayout.EAST);
        
        cartDialog.add(bottomPanel, BorderLayout.SOUTH);
        cartDialog.setVisible(true);
    }
    
    private void handlePlaceOrder() {
        String buyerIdStr = txtBuyerId.getText().trim();
        if (buyerIdStr.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Please enter a Buyer ID.", "Missing Info", JOptionPane.WARNING_MESSAGE);
            return;
        }

        int buyerId;
        try {
            buyerId = Integer.parseInt(buyerIdStr);
        } catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(this, "Buyer ID must be a number.", "Invalid Format", JOptionPane.ERROR_MESSAGE);
            return;
        }
        if (shoppingCart.isEmpty()) {
            JOptionPane.showMessageDialog(this,
                "Your cart is empty! Please add items before placing an order.",
                "Empty Cart",
                JOptionPane.WARNING_MESSAGE);
            return;
        }
        
        double subtotal = shoppingCart.values().stream()
            .mapToDouble(item -> item.price * item.quantity)
            .sum();
        
        double tax = subtotal * 0.08;
        double totalWithTax = subtotal + tax;
        
        int totalItems = shoppingCart.values().stream()
            .mapToInt(item -> item.quantity)
            .sum();
        
        StringBuilder orderSummary = new StringBuilder();
        orderSummary.append("Order Summary:\n");
        orderSummary.append("Buyer ID: ").append(buyerId).append("\n\n");
        
        for (CartItem item : shoppingCart.values()) {
            orderSummary.append(String.format("%dx %s - $%.2f\n", 
                item.quantity, item.name, item.price * item.quantity));
        }
        
        orderSummary.append(String.format("\nTotal Items: %d\n", totalItems));
        orderSummary.append(String.format("Subtotal: $%.2f\n", subtotal));
        orderSummary.append(String.format("Tax (8%%): $%.2f\n", tax));
        orderSummary.append(String.format("Total (with tax): $%.2f\n\n", totalWithTax));
        orderSummary.append("Confirm order?");
        
        int confirm = JOptionPane.showConfirmDialog(this,
            orderSummary.toString(),
            "Place Order",
            JOptionPane.YES_NO_OPTION);
        
        if (confirm == JOptionPane.YES_OPTION) {
            Order newOrder = new Order();
            newOrder.setBuyerId(buyerId);
            newOrder.setOrderPrice(java.math.BigDecimal.valueOf(subtotal)); 
            newOrder.setPaymentId(null);
            try {
                orderDAO.insertOrder(newOrder);
                int orderId = newOrder.getOrderId();
                boolean allItemsAdded = true;
                StringBuilder errorMessages = new StringBuilder();
                
                for (CartItem item : shoppingCart.values()) {
                    try {
                        orderDAO.addOrderItem(orderId, item.variantId, item.productId, item.quantity);
                    } catch (java.sql.SQLException e) {
                        allItemsAdded = false;
                        errorMessages.append("- ").append(item.name).append(": ").append(e.getMessage()).append("\n");
                    }
                }
                
                if (!allItemsAdded) {
                    JOptionPane.showMessageDialog(this,
                        "Order created but some items could not be added:\n" + errorMessages.toString(),
                        "Partial Success",
                        JOptionPane.WARNING_MESSAGE);
                } else {
                    JOptionPane.showMessageDialog(this,
                        "Order placed successfully for Buyer " + buyerId + "!\nOrder ID: " + orderId + "\nSubtotal: $" + String.format("%.2f", subtotal) + "\nStatus: Draft",
                        "Success",
                        JOptionPane.INFORMATION_MESSAGE);
                }
                
                shoppingCart.clear();
                updateCartButton();
                
            } catch (java.sql.SQLException e) {
                String errorMessage = e.getMessage();
                JOptionPane.showMessageDialog(this,
                    errorMessage,
                    "Order Validation Error",
                    JOptionPane.ERROR_MESSAGE);
            }
        }
    }
    
    private static class CartItem {
        int variantId;
        int productId;
        String name;
        double price;
        int quantity;
        
        CartItem(int variantId, int productId, String name, double price, int quantity) {
            this.variantId = variantId;
            this.productId = productId;
            this.name = name;
            this.price = price;
            this.quantity = quantity;
        }
    }
    
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            new BuyerView().setVisible(true);
        });
    }
}