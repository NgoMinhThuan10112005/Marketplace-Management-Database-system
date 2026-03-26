package com.marketplace.ui.components;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSeparator;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.ListSelectionModel;
import javax.swing.SwingUtilities;
import javax.swing.table.DefaultTableCellRenderer;

import com.marketplace.dao.OrderSummaryDAO;
import com.marketplace.model.OrderSummaryByBuyer;
import com.marketplace.model.OrderSummaryTableModel;

/**
 * Dashboard hiển thị thống kê đơn hàng theo buyer
 * Sử dụng stored procedure sp_GetOrderSummaryByBuyer
 */
public class OrderSummaryDashboard extends JFrame {
    
    private OrderSummaryDAO summaryDAO;
    
    // Table components
    private JTable summaryTable;
    private OrderSummaryTableModel tableModel;
    private JScrollPane scrollPane;
    
    // Filter components - theo stored procedure parameters
    private JComboBox<String> statusComboBox;      // p_Status
    private JTextField fromDateField;               // p_StartDate
    private JTextField toDateField;                 // p_EndDate
    private JTextField minOrderCountField;          // p_MinOrderCount
    private JTextField minTotalSpentField;          // p_MinTotalSpent
    
    // Buttons
    private JButton btnSearch;
    private JButton btnClearFilters;
    private JButton btnExport;
    private JButton btnClose;
    
    private JLabel statusLabel;
    
    public OrderSummaryDashboard() {
        summaryDAO = new OrderSummaryDAO();
        initComponents();
        setupLayout();
        loadSummaries();
        setTitle("Order Summary by Buyer - Analytics Report");
        setSize(1400, 750);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);
    }
    
    private void initComponents() {
        tableModel = new OrderSummaryTableModel(new java.util.ArrayList<>());
        summaryTable = new JTable(tableModel);
        summaryTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        summaryTable.setRowHeight(30);
        summaryTable.getTableHeader().setReorderingAllowed(false);
        summaryTable.getTableHeader().setFont(new Font("Arial", Font.BOLD, 12));
        summaryTable.setFont(new Font("Arial", Font.PLAIN, 12));
        
        DefaultTableCellRenderer centerRenderer = new DefaultTableCellRenderer();
        centerRenderer.setHorizontalAlignment(JLabel.CENTER);
        
        DefaultTableCellRenderer rightRenderer = new DefaultTableCellRenderer();
        rightRenderer.setHorizontalAlignment(JLabel.RIGHT);
        
        summaryTable.getColumnModel().getColumn(0).setPreferredWidth(80);  
        summaryTable.getColumnModel().getColumn(0).setCellRenderer(centerRenderer);
        summaryTable.getColumnModel().getColumn(1).setPreferredWidth(150);  
        summaryTable.getColumnModel().getColumn(2).setPreferredWidth(200); 
        summaryTable.getColumnModel().getColumn(3).setPreferredWidth(100); 
        summaryTable.getColumnModel().getColumn(3).setCellRenderer(centerRenderer);
        summaryTable.getColumnModel().getColumn(4).setPreferredWidth(100); 
        summaryTable.getColumnModel().getColumn(4).setCellRenderer(centerRenderer);
        summaryTable.getColumnModel().getColumn(5).setPreferredWidth(120); 
        summaryTable.getColumnModel().getColumn(5).setCellRenderer(rightRenderer);
        summaryTable.getColumnModel().getColumn(6).setPreferredWidth(100);
        summaryTable.getColumnModel().getColumn(6).setCellRenderer(rightRenderer);
        summaryTable.getColumnModel().getColumn(7).setPreferredWidth(120);
        summaryTable.getColumnModel().getColumn(7).setCellRenderer(rightRenderer);
        summaryTable.getColumnModel().getColumn(8).setPreferredWidth(130);  
        summaryTable.getColumnModel().getColumn(8).setCellRenderer(rightRenderer);

        scrollPane = new JScrollPane(summaryTable);
        scrollPane.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
        
        String[] statuses = {"All", "Draft", "Pending", "Placed", "Shipped", "Complete", "Cancelled"};
        statusComboBox = new JComboBox<>(statuses);
        statusComboBox.setPreferredSize(new Dimension(130, 30));
        statusComboBox.setToolTipText("Filter by order status");
        
        fromDateField = new JTextField(10);
        fromDateField.setPreferredSize(new Dimension(120, 30));
        fromDateField.setToolTipText("Format: yyyy-MM-dd");
        
        toDateField = new JTextField(10);
        toDateField.setPreferredSize(new Dimension(120, 30));
        toDateField.setToolTipText("Format: yyyy-MM-dd");
        
        minOrderCountField = new JTextField(8);
        minOrderCountField.setPreferredSize(new Dimension(100, 30));
        minOrderCountField.setToolTipText("Minimum number of orders (e.g., 10)");
        
        minTotalSpentField = new JTextField(10);
        minTotalSpentField.setPreferredSize(new Dimension(120, 30));
        minTotalSpentField.setToolTipText("Minimum total spent (e.g., 1000.00)");
        
        btnSearch = new JButton("🔍 Search");
        btnClearFilters = new JButton("Clear Filters");
        btnExport = new JButton("📊 Export");
        btnClose = new JButton("Close");
        
        styleButton(btnSearch, new Color(66, 133, 244), Color.WHITE);
        styleButton(btnClearFilters, new Color(158, 158, 158), Color.WHITE);
        styleButton(btnExport, new Color(76, 175, 80), Color.WHITE);
        styleButton(btnClose, new Color(244, 67, 54), Color.WHITE);
        
        statusLabel = new JLabel("Showing 0 buyers");
        statusLabel.setFont(new Font("Arial", Font.PLAIN, 12));
        
        btnSearch.addActionListener(e -> applyFilters());
        btnClearFilters.addActionListener(e -> clearFilters());
        btnExport.addActionListener(e -> exportData());
        btnClose.addActionListener(e -> dispose());
        
        fromDateField.addActionListener(e -> applyFilters());
        toDateField.addActionListener(e -> applyFilters());
        minOrderCountField.addActionListener(e -> applyFilters());
        minTotalSpentField.addActionListener(e -> applyFilters());
    }
    
    private void styleButton(JButton button, Color bgColor, Color fgColor) {
        button.setBackground(bgColor);
        button.setForeground(fgColor);
        button.setFocusPainted(false);
        button.setFont(new Font("Arial", Font.BOLD, 12));
        button.setBorder(BorderFactory.createEmptyBorder(8, 15, 8, 15));
        button.setCursor(new Cursor(Cursor.HAND_CURSOR));
    }
    
    private void setupLayout() {
        setLayout(new BorderLayout(10, 10));
        
        JPanel northPanel = new JPanel(new BorderLayout(10, 10));
        northPanel.setBorder(BorderFactory.createEmptyBorder(15, 15, 15, 15));
        northPanel.setBackground(Color.WHITE);
        
        JLabel titleLabel = new JLabel("ORDER SUMMARY BY BUYER", JLabel.CENTER);
        titleLabel.setFont(new Font("Arial", Font.BOLD, 28));
        titleLabel.setForeground(new Color(33, 33, 33));
        titleLabel.setBorder(BorderFactory.createEmptyBorder(0, 0, 10, 0));
        
        JPanel titlePanel = new JPanel(new BorderLayout());
        titlePanel.setBackground(Color.WHITE);
        titlePanel.add(titleLabel, BorderLayout.NORTH);        
        JPanel filtersPanel = new JPanel();
        filtersPanel.setLayout(new BoxLayout(filtersPanel, BoxLayout.Y_AXIS));
        filtersPanel.setBackground(Color.WHITE);
        
        JPanel filterRow1 = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 5));
        filterRow1.setBackground(Color.WHITE);
        
        JLabel lblStatus = new JLabel("Status:");
        lblStatus.setFont(new Font("Arial", Font.BOLD, 12));
        filterRow1.add(lblStatus);
        filterRow1.add(statusComboBox);
        
        filterRow1.add(Box.createHorizontalStrut(15));
        
        JPanel datePanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 5, 0));
        datePanel.setBackground(Color.WHITE);
        JLabel lblFrom = new JLabel("From:");
        lblFrom.setFont(new Font("Arial", Font.BOLD, 12));
        datePanel.add(lblFrom);
        datePanel.add(fromDateField);
        
        JLabel lblTo = new JLabel("To:");
        lblTo.setFont(new Font("Arial", Font.BOLD, 12));
        datePanel.add(lblTo);
        datePanel.add(toDateField);
        filterRow1.add(datePanel);
        
        JPanel filterRow2 = new JPanel(new FlowLayout(FlowLayout.LEFT, 10, 5));
        filterRow2.setBackground(Color.WHITE);
        
        JLabel lblMinOrders = new JLabel("Min Orders:");
        lblMinOrders.setFont(new Font("Arial", Font.BOLD, 12));
        filterRow2.add(lblMinOrders);
        filterRow2.add(minOrderCountField);
        
        filterRow2.add(Box.createHorizontalStrut(15));
        
        JLabel lblMinSpent = new JLabel("Min Total Spent:");
        lblMinSpent.setFont(new Font("Arial", Font.BOLD, 12));
        filterRow2.add(lblMinSpent);
        filterRow2.add(minTotalSpentField);
        
        filterRow2.add(Box.createHorizontalStrut(15));
        filterRow2.add(btnSearch);
        filterRow2.add(btnClearFilters);
        
        filtersPanel.add(filterRow1);
        filtersPanel.add(filterRow2);
        
        JSeparator separator = new JSeparator();
        
        northPanel.add(titlePanel, BorderLayout.NORTH);
        northPanel.add(filtersPanel, BorderLayout.CENTER);
        northPanel.add(separator, BorderLayout.SOUTH);
        
        JPanel centerPanel = new JPanel(new BorderLayout());
        centerPanel.setBorder(BorderFactory.createEmptyBorder(0, 15, 0, 15));
        centerPanel.setBackground(Color.WHITE);
        centerPanel.add(scrollPane, BorderLayout.CENTER);
        
        JPanel statusPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        statusPanel.setBackground(Color.WHITE);
        statusPanel.add(statusLabel);
        centerPanel.add(statusPanel, BorderLayout.SOUTH);
        
        JPanel southPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 15, 15));
        southPanel.setBorder(BorderFactory.createEmptyBorder(10, 15, 15, 15));
        southPanel.setBackground(Color.WHITE);
        southPanel.add(btnExport);
        southPanel.add(btnClose);
        
        add(northPanel, BorderLayout.NORTH);
        add(centerPanel, BorderLayout.CENTER);
        add(southPanel, BorderLayout.SOUTH);
        
        getContentPane().setBackground(Color.WHITE);
    }
    
    private void loadSummaries() {
        try {
            String status = statusComboBox.getSelectedItem().toString();
            if (status.equals("All")) {
                status = null;
            }
            
            java.sql.Timestamp startDate = null;
            String startDateText = fromDateField.getText().trim();
            if (!startDateText.isEmpty()) {
                try {
                    LocalDate localDate = LocalDate.parse(startDateText, DateTimeFormatter.ISO_LOCAL_DATE);
                    startDate = java.sql.Timestamp.valueOf(localDate.atStartOfDay());
                } catch (Exception e) {
                    JOptionPane.showMessageDialog(this,
                        "Invalid Start Date format. Please use yyyy-MM-dd",
                        "Input Error",
                        JOptionPane.ERROR_MESSAGE);
                    return;
                }
            }
            
            java.sql.Timestamp endDate = null;
            String endDateText = toDateField.getText().trim();
            if (!endDateText.isEmpty()) {
                try {
                    LocalDate localDate = LocalDate.parse(endDateText, DateTimeFormatter.ISO_LOCAL_DATE);
                    endDate = java.sql.Timestamp.valueOf(localDate.atTime(23, 59, 59));
                } catch (Exception e) {
                    JOptionPane.showMessageDialog(this,
                        "Invalid End Date format. Please use yyyy-MM-dd",
                        "Input Error",
                        JOptionPane.ERROR_MESSAGE);
                    return;
                }
            }
            
            Integer minOrderCount = null;
            String minOrderText = minOrderCountField.getText().trim();
            if (!minOrderText.isEmpty()) {
                try {
                    minOrderCount = Integer.parseInt(minOrderText);
                } catch (NumberFormatException e) {
                    JOptionPane.showMessageDialog(this,
                        "Invalid Min Order Count. Please enter a valid number.",
                        "Input Error",
                        JOptionPane.ERROR_MESSAGE);
                    return;
                }
            }
            
            BigDecimal minTotalSpent = null;
            String minSpentText = minTotalSpentField.getText().trim();
            if (!minSpentText.isEmpty()) {
                try {
                    minTotalSpent = new BigDecimal(minSpentText);
                } catch (NumberFormatException e) {
                    JOptionPane.showMessageDialog(this,
                        "Invalid Min Total Spent. Please enter a valid amount (e.g., 1000.00).",
                        "Input Error",
                        JOptionPane.ERROR_MESSAGE);
                    return;
                }
            }
            
            List<OrderSummaryByBuyer> summaries = summaryDAO.getOrderSummaryByBuyer(
                status,
                startDate,
                endDate,
                minOrderCount,
                minTotalSpent
            );
            
            tableModel = new OrderSummaryTableModel(summaries);
            summaryTable.setModel(tableModel);
            applyColumnSettings();
            
            statusLabel.setText("Showing " + summaries.size() + " buyers");
            
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this,
                "Error loading summary: " + e.getMessage(),
                "Error",
                JOptionPane.ERROR_MESSAGE);
            e.printStackTrace();
        }
    }
    
    private void applyColumnSettings() {
        DefaultTableCellRenderer centerRenderer = new DefaultTableCellRenderer();
        centerRenderer.setHorizontalAlignment(JLabel.CENTER);
        
        DefaultTableCellRenderer rightRenderer = new DefaultTableCellRenderer();
        rightRenderer.setHorizontalAlignment(JLabel.RIGHT);
        
        summaryTable.getColumnModel().getColumn(0).setPreferredWidth(80);
        summaryTable.getColumnModel().getColumn(0).setCellRenderer(centerRenderer);
        
        summaryTable.getColumnModel().getColumn(1).setPreferredWidth(150);
        summaryTable.getColumnModel().getColumn(2).setPreferredWidth(200);
        
        summaryTable.getColumnModel().getColumn(3).setPreferredWidth(100);
        summaryTable.getColumnModel().getColumn(3).setCellRenderer(centerRenderer);
        
        summaryTable.getColumnModel().getColumn(4).setPreferredWidth(100);
        summaryTable.getColumnModel().getColumn(4).setCellRenderer(centerRenderer);
        
        summaryTable.getColumnModel().getColumn(5).setPreferredWidth(120);
        summaryTable.getColumnModel().getColumn(5).setCellRenderer(rightRenderer);
        
        summaryTable.getColumnModel().getColumn(6).setPreferredWidth(100);
        summaryTable.getColumnModel().getColumn(6).setCellRenderer(rightRenderer);
        
        summaryTable.getColumnModel().getColumn(7).setPreferredWidth(120);
        summaryTable.getColumnModel().getColumn(7).setCellRenderer(rightRenderer);
        
        summaryTable.getColumnModel().getColumn(8).setPreferredWidth(130);
        summaryTable.getColumnModel().getColumn(8).setCellRenderer(rightRenderer);
    }
    
    private void applyFilters() {
        loadSummaries();
    }
    
    private void clearFilters() {
        statusComboBox.setSelectedIndex(0);
        fromDateField.setText("");
        toDateField.setText("");
        minOrderCountField.setText("");
        minTotalSpentField.setText("");
        loadSummaries();
    }
    
    private void exportData() {
        JOptionPane.showMessageDialog(this,
            "Export functionality will be implemented.",
            "Info",
            JOptionPane.INFORMATION_MESSAGE);
    }
    
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            new OrderSummaryDashboard().setVisible(true);
        });
    }
}