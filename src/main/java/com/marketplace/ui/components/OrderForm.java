package com.marketplace.ui.components;
import java.awt.Color;
import java.awt.Cursor;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.SwingConstants;
import javax.swing.UIManager;

import com.marketplace.dao.OrderDAO;
import com.marketplace.model.Order;

public class OrderForm extends JDialog implements ActionListener {
    // Enum để quản lý chế độ
    public enum Mode {
        UPDATE, DELETE
    }

    private Mode currentMode = Mode.UPDATE;

    private JLabel titleLabel;
    private JLabel orderIdLabel, statusLabel;
    private JTextField orderIdField;
    private JComboBox<String> statusComboBox;
    private JButton updateButton, deleteButton;
    private JButton switchToUpdateButton, switchToDeleteButton;

    private final Color PRIMARY_COLOR = new Color(70, 130, 180);

    public OrderForm(Mode mode) {
        this.currentMode = mode;
        try {
            for (UIManager.LookAndFeelInfo info : UIManager.getInstalledLookAndFeels()) {
                if ("Nimbus".equals(info.getName())) {
                    UIManager.setLookAndFeel(info.getClassName());
                    break;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        setTitle("Order Management");
        setSize(750, 700); 
        setLocationRelativeTo(null);
        setLayout(null);

        JPanel headerPanel = new JPanel();
        headerPanel.setBounds(0, 0, 750, 120); 
        headerPanel.setBackground(PRIMARY_COLOR);
        headerPanel.setLayout(null);
        add(headerPanel);

        titleLabel = new JLabel("ORDER MANAGEMENT", SwingConstants.CENTER);
        titleLabel.setBounds(0, 10, 750, 40);
        titleLabel.setFont(new Font("Segoe UI", Font.BOLD, 28));
        titleLabel.setForeground(Color.WHITE);
        headerPanel.add(titleLabel);        
        switchToUpdateButton = createSwitchButton("UPDATE MODE", 200, 65, new Color(52, 152, 219)); // Xanh dương
        headerPanel.add(switchToUpdateButton);
        switchToDeleteButton = createSwitchButton("DELETE MODE", 400, 65, new Color(231, 76, 60)); // Đỏ
        headerPanel.add(switchToDeleteButton);

        int labelX = 50;
        int fieldX = 220;
        int width = 450;
        int yStart = 150; 
        int yGap = 60;
        orderIdLabel = createAndAddLabel("Order ID:", labelX, yStart);
        add(orderIdLabel);
        orderIdField = createStyledTextField(fieldX, yStart, width, true);
        add(orderIdField);
        statusLabel = createAndAddLabel("Status:", labelX, yStart + yGap);
        String[] statusOptions = {"Placed", "Preparing to Ship", "In Transit", "Out for Delivery", 
            "Delivered", "Completed", "Disputed", "Return Processing", 
            "Return Completed", "Refunded", "Cancelled", "Pending"};
        statusComboBox = new JComboBox<>(statusOptions);
        statusComboBox.setBounds(fieldX, yStart + yGap, width, 40); 
        statusComboBox.setFont(new Font("Segoe UI", Font.PLAIN, 16)); 
        add(statusComboBox);
        int buttonY = yStart + yGap * 2 + 20;
        updateButton = createStyledButton("Update Order", new Color(52, 152, 219), 250, buttonY);
        updateButton.addActionListener(this);
        add(updateButton);
        deleteButton = createStyledButton("Delete Order", new Color(231, 76, 60), 250, buttonY);
        deleteButton.addActionListener(this);
        deleteButton.setVisible(false);
        add(deleteButton);
        switchMode(currentMode);
    }

    private void switchMode(Mode mode) {
        currentMode = mode;

        if (mode == Mode.UPDATE) {
            orderIdLabel.setVisible(true);
            orderIdField.setVisible(true);
            statusLabel.setVisible(true);
            statusComboBox.setVisible(true);
            deleteButton.setVisible(false);
            updateButton.setVisible(true);
            switchToUpdateButton.setBackground(new Color(52, 152, 219)); // Xanh dương đậm
            switchToDeleteButton.setBackground(new Color(200, 100, 100)); // Đỏ nhạt
            statusComboBox.setSelectedIndex(0);
        }
        else if (mode == Mode.DELETE) {
            orderIdLabel.setVisible(true);
            orderIdField.setVisible(true);
            statusLabel.setVisible(false);
            statusComboBox.setVisible(false);
            deleteButton.setVisible(true);
            updateButton.setVisible(false);
            switchToUpdateButton.setBackground(new Color(100, 180, 220));
            switchToDeleteButton.setBackground(new Color(231, 76, 60));
            statusComboBox.setSelectedIndex(0);
        }
    }


    private JLabel createAndAddLabel(String text, int x, int y) { 
    JLabel lbl = new JLabel(text);
    lbl.setBounds(x, y, 160, 40);
    lbl.setFont(new Font("Segoe UI", Font.BOLD, 16));
    lbl.setForeground(new Color(50, 50, 50));
    add(lbl); 
    return lbl; 
}

    private JTextField createStyledTextField(int x, int y, int width, boolean editable) {
        JTextField tf = new JTextField();
        tf.setBounds(x, y, width, 40); 
        tf.setFont(new Font("Segoe UI", Font.PLAIN, 16)); 
        tf.setEditable(editable);
        tf.setBorder(BorderFactory.createCompoundBorder(
        tf.getBorder(),
        BorderFactory.createEmptyBorder(2, 10, 2, 10))); 
        return tf;
    }

    private JButton createStyledButton(String text, Color bgColor, int x, int y) {
        JButton btn = new JButton(text);
        btn.setBounds(x, y, 140, 40);
        btn.setFont(new Font("Segoe UI", Font.BOLD, 14));
        btn.setBackground(bgColor);
        btn.setForeground(Color.WHITE);
        btn.setFocusPainted(false);
        btn.setBorderPainted(false);
        btn.setCursor(new Cursor(Cursor.HAND_CURSOR));
        return btn;
    }

    private JButton createSwitchButton(String text, int x, int y, Color bgColor) {
        JButton btn = new JButton(text);
        btn.setBounds(x, y, 140, 40);
        btn.setFont(new Font("Segoe UI", Font.BOLD, 14));
        btn.setBackground(bgColor);
        btn.setForeground(Color.WHITE);
        btn.setFocusPainted(false);
        btn.setBorderPainted(false);
        btn.setCursor(new Cursor(Cursor.HAND_CURSOR));
        btn.addActionListener(this);
        return btn;
    }

    @Override
public void actionPerformed(ActionEvent e) {
    if (e.getSource() == switchToUpdateButton) {
        switchMode(Mode.UPDATE);
        return;
    }
    else if (e.getSource() == switchToDeleteButton) {
        switchMode(Mode.DELETE);
        return;
    }
    if (e.getSource() == updateButton) {
        handleUpdateOrder();
    }
    else if (e.getSource() == deleteButton) {
        handleDeleteOrder();
    }
}

    public static void main(String[] args) {
        new OrderForm(Mode.UPDATE).setVisible(true);
    }
    
    private void handleUpdateOrder(){
        try {
            if (orderIdField.getText().trim().isEmpty()) {
                JOptionPane.showMessageDialog(this, "Order ID cannot be empty!", "Validation Error", JOptionPane.WARNING_MESSAGE);
                return;
            }
            int orderId;
            try {
                orderId = Integer.parseInt(orderIdField.getText().trim());
            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(this, "Order ID must be a whole number!", "Error", JOptionPane.ERROR_MESSAGE);
                return;
            }
            String newStatus = (String) statusComboBox.getSelectedItem();
            Order order = new Order(
                orderId,               
                0,                   
                null,                 
                null,  
                newStatus,       
                null         
            );

            OrderDAO orderDAO = new OrderDAO();
            if (orderDAO.updateOrder(order)) {
                try {
                    Order updatedOrder = orderDAO.getOrderById(orderId);
                    String successMessage = "Order status updated successfully!\nOrder ID: " + orderId + "\nNew Status: " + newStatus;
                    if (updatedOrder != null && updatedOrder.getPaymentId() != null) {
                        successMessage += "\nPayment ID: " + updatedOrder.getPaymentId();
                    }
                    JOptionPane.showMessageDialog(this, successMessage, "Success", JOptionPane.INFORMATION_MESSAGE);
                } catch (Exception e) {
                    JOptionPane.showMessageDialog(this, "Order status updated successfully!", "Success", JOptionPane.INFORMATION_MESSAGE);
                }
            } else {
                JOptionPane.showMessageDialog(this, "Failed to update order. Check Order ID or Database!", "Database Error", JOptionPane.ERROR_MESSAGE);
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "An unexpected error occurred: " + ex.getMessage());
        }
    }
    private void handleDeleteOrder(){
        try {
            if (orderIdField.getText().trim().isEmpty()) {
                JOptionPane.showMessageDialog(this, "Order ID cannot be empty!", "Validation Error", JOptionPane.WARNING_MESSAGE);
                return;
            }
            int orderId;
            try {
                orderId = Integer.parseInt(orderIdField.getText().trim());
            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(this, "Order ID must be a whole number!", "Error", JOptionPane.ERROR_MESSAGE);
                return;
            }
            OrderDAO orderDAO = new OrderDAO();
            if (orderDAO.deleteOrder(orderId)) {
                JOptionPane.showMessageDialog(this, "Order deleted successfully!");
            } else {
                JOptionPane.showMessageDialog(this, "Failed to delete order. Check Order ID or Database!", "Database Error", JOptionPane.ERROR_MESSAGE);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "An unexpected error occurred: " + ex.getMessage());
        }
    }
}
