package com.marketplace.ui.components;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
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

import com.marketplace.dao.OrderListDAO;
import com.marketplace.model.OrderList;
import com.marketplace.model.OrderTableModel;
import com.marketplace.ui.components.OrderForm.Mode;

public class Dashboard extends JFrame {
    
    private OrderListDAO orderListDAO;
    
    private JTable orderTable;
    private OrderTableModel tableModel;
    
    private JComboBox<String> statusComboBox;
    private JTextField buyerIDField;
    private JTextField fromDateField;
    private JTextField toDateField;
    private JComboBox<String> sortColumnComboBox;
    private JComboBox<String> sortDirectionComboBox;
    
    private JButton btnSearch;
    private JButton btnClearFilters;
    private JButton btnNewOrder;
    private JButton btnViewSummary;
    private JButton btnEdit;
    private JButton btnDelete;
    
    private JScrollPane scrollPane;
    private JLabel statusLabel;
    
    public Dashboard() {
        orderListDAO = new OrderListDAO();
        initComponents();
        setupLayout();
        loadOrders();
        
        setTitle("Orders Management");
        setSize(1400, 750);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);
    }
    
    private void initComponents() {
        tableModel = new OrderTableModel(new java.util.ArrayList<>());
        orderTable = new JTable(tableModel);
        
        orderTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        orderTable.setRowHeight(30);
        orderTable.getTableHeader().setReorderingAllowed(false);
        orderTable.getTableHeader().setFont(new Font("Arial", Font.BOLD, 12));
        orderTable.setFont(new Font("Arial", Font.PLAIN, 12));
        
        DefaultTableCellRenderer centerRenderer = new DefaultTableCellRenderer();
        centerRenderer.setHorizontalAlignment(JLabel.CENTER);
        
        orderTable.getColumnModel().getColumn(0).setPreferredWidth(80);
        orderTable.getColumnModel().getColumn(0).setCellRenderer(centerRenderer);
        
        orderTable.getColumnModel().getColumn(1).setPreferredWidth(150);
        orderTable.getColumnModel().getColumn(1).setCellRenderer(centerRenderer);
        
        orderTable.getColumnModel().getColumn(2).setPreferredWidth(100);
        orderTable.getColumnModel().getColumn(2).setCellRenderer(centerRenderer);
        
        orderTable.getColumnModel().getColumn(3).setPreferredWidth(100);
        orderTable.getColumnModel().getColumn(3).setCellRenderer(centerRenderer);
        orderTable.getColumnModel().getColumn(4).setPreferredWidth(100);
        orderTable.getColumnModel().getColumn(4).setCellRenderer(centerRenderer);
        orderTable.getColumnModel().getColumn(5).setPreferredWidth(80);
        orderTable.getColumnModel().getColumn(5).setCellRenderer(centerRenderer);
        orderTable.getColumnModel().getColumn(6).setPreferredWidth(150);
        orderTable.getColumnModel().getColumn(7).setPreferredWidth(200);
        orderTable.getColumnModel().getColumn(8).setPreferredWidth(120);
        orderTable.getColumnModel().getColumn(8).setCellRenderer(centerRenderer);
        scrollPane = new JScrollPane(orderTable);
        scrollPane.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);        
        String[] statuses = {"All", "Draft", "Pending", "Placed", "Cancelled", "Delivered"
                            , "Preparing to Ship", "In Transit", "Out for Delivery", "Completed"
                            , "Disputed", "Return Processing", "Return Completed", "Refunded"};
        statusComboBox = new JComboBox<>(statuses);
        statusComboBox.setPreferredSize(new Dimension(130, 30));
        statusComboBox.setToolTipText("Filter by order status (p_Status parameter)");
        
        buyerIDField = new JTextField(8);
        buyerIDField.setPreferredSize(new Dimension(100, 30));
        buyerIDField.setToolTipText("Enter Buyer ID to filter (p_BuyerID parameter)");
        fromDateField = new JTextField(10);
        fromDateField.setPreferredSize(new Dimension(120, 30));
        fromDateField.setToolTipText("Format: yyyy-MM-dd (p_StartDate parameter)");
        toDateField = new JTextField(10);
        toDateField.setPreferredSize(new Dimension(120, 30));
        toDateField.setToolTipText("Format: yyyy-MM-dd (p_EndDate parameter)");
        String[] sortColumns = {"OrderID", "OrderAt", "OrderPrice", "Status", "BuyerName"};
        sortColumnComboBox = new JComboBox<>(sortColumns);
        sortColumnComboBox.setSelectedItem("OrderAt"); 
        sortColumnComboBox.setPreferredSize(new Dimension(130, 30));
        sortColumnComboBox.setToolTipText("Select column to sort by (p_SortColumn parameter)");
        String[] sortDirections = {"ASC", "DESC"};
        sortDirectionComboBox = new JComboBox<>(sortDirections);
        sortDirectionComboBox.setSelectedItem("DESC"); 
        sortDirectionComboBox.setPreferredSize(new Dimension(80, 30));
        sortDirectionComboBox.setToolTipText("Sort direction (p_SortDirection parameter)");
        btnSearch = new JButton("🔍 Search");
        btnClearFilters = new JButton("Clear Filters");
        btnNewOrder = new JButton("+ New Order");
        btnViewSummary = new JButton("👁 View Summary Report");
        btnEdit = new JButton("✏ Edit");
        btnDelete = new JButton("🗑 Delete");
        
        styleButton(btnSearch, new Color(66, 133, 244), Color.WHITE);
        styleButton(btnClearFilters, new Color(158, 158, 158), Color.WHITE);
        styleButton(btnNewOrder, new Color(76, 175, 80), Color.WHITE);
        styleButton(btnViewSummary, new Color(156, 39, 176), Color.WHITE);
        styleButton(btnEdit, new Color(255, 152, 0), Color.WHITE);
        styleButton(btnDelete, new Color(244, 67, 54), Color.WHITE);
        
        statusLabel = new JLabel("Showing 0 orders");
        statusLabel.setFont(new Font("Arial", Font.PLAIN, 12));
        
        btnSearch.addActionListener(e -> applyFilters());
        btnClearFilters.addActionListener(e -> clearFilters());
        btnNewOrder.addActionListener(e -> addOrder());
         btnViewSummary.addActionListener(e -> openSummaryReport());
        btnEdit.addActionListener(e -> editOrder());
        btnDelete.addActionListener(e -> deleteOrder());
        
        buyerIDField.addActionListener(e -> applyFilters());
        fromDateField.addActionListener(e -> applyFilters());
        toDateField.addActionListener(e -> applyFilters());
        
        sortColumnComboBox.addActionListener(e -> applyFilters());
        sortDirectionComboBox.addActionListener(e -> applyFilters());
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
        
        JLabel titleLabel = new JLabel("ORDERS MANAGEMENT", JLabel.CENTER);
        titleLabel.setFont(new Font("Arial", Font.BOLD, 28));
        titleLabel.setForeground(new Color(33, 33, 33));
        titleLabel.setBorder(BorderFactory.createEmptyBorder(0, 0, 15, 0));
        
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
        JLabel lblBuyerID = new JLabel("Buyer ID:");
        lblBuyerID.setFont(new Font("Arial", Font.BOLD, 12));
        filterRow1.add(lblBuyerID);
        filterRow1.add(buyerIDField);
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
        
        JLabel lblSort = new JLabel("Sort By:");
        lblSort.setFont(new Font("Arial", Font.BOLD, 12));
        filterRow2.add(lblSort);
        filterRow2.add(sortColumnComboBox);
        filterRow2.add(sortDirectionComboBox);
        
        filterRow2.add(Box.createHorizontalStrut(15));
        
        filterRow2.add(btnSearch);
        filterRow2.add(btnClearFilters);
        
        filtersPanel.add(filterRow1);
        filtersPanel.add(filterRow2);
        
        JSeparator separator = new JSeparator();
        separator.setPreferredSize(new Dimension(1, 1));
        
        northPanel.add(titleLabel, BorderLayout.NORTH);
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
        southPanel.add(btnNewOrder);
        southPanel.add(btnViewSummary);
        southPanel.add(btnEdit);
        southPanel.add(btnDelete);
        
        add(northPanel, BorderLayout.NORTH);
        add(centerPanel, BorderLayout.CENTER);
        add(southPanel, BorderLayout.SOUTH);
        
        getContentPane().setBackground(Color.WHITE);
    }

    private void loadOrders() {
        try {
            String status = statusComboBox.getSelectedItem().toString();
            if (status.equals("All")) {
                status = null; 
            }
            
            Integer buyerID = null;
            String buyerIDText = buyerIDField.getText().trim();
            if (!buyerIDText.isEmpty()) {
                try {
                    buyerID = Integer.parseInt(buyerIDText);
                } catch (NumberFormatException e) {
                    JOptionPane.showMessageDialog(this,
                        "Invalid Buyer ID. Please enter a valid number.",
                        "Input Error",
                        JOptionPane.ERROR_MESSAGE);
                    return;
                }
            }
            
            java.sql.Timestamp startDate = null;
            String startDateText = fromDateField.getText().trim();
            if (!startDateText.isEmpty()) {
                try {
                    LocalDate localDate = LocalDate.parse(startDateText, DateTimeFormatter.ISO_LOCAL_DATE);
                    startDate = java.sql.Timestamp.valueOf(localDate.atStartOfDay());
                } catch (Exception e) {
                    JOptionPane.showMessageDialog(this,
                        "Invalid Start Date format. Please use yyyy-MM-dd (e.g., 2024-12-01)",
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
                        "Invalid End Date format. Please use yyyy-MM-dd (e.g., 2024-12-31)",
                        "Input Error",
                        JOptionPane.ERROR_MESSAGE);
                    return;
                }
            }
            
            String sortColumn = sortColumnComboBox.getSelectedItem().toString();
            String sortDirection = sortDirectionComboBox.getSelectedItem().toString();
            
            List<OrderList> orderList = orderListDAO.getOrderList(
                status,        
                buyerID,       
                startDate,     
                endDate,        
                sortColumn,   
                sortDirection 
            );
            
            tableModel = new OrderTableModel(orderList);
            orderTable.setModel(tableModel);
            applyColumnSettings();
            statusLabel.setText("Showing 1-" + orderList.size() + " of " + orderList.size() + " orders");
                
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, 
                "Error loading orders: " + e.getMessage(), 
                "Error", 
                JOptionPane.ERROR_MESSAGE);
            e.printStackTrace();
        }
    }
    
    private void applyColumnSettings() {
        DefaultTableCellRenderer centerRenderer = new DefaultTableCellRenderer();
        centerRenderer.setHorizontalAlignment(JLabel.CENTER);
        orderTable.getColumnModel().getColumn(0).setPreferredWidth(80);
        orderTable.getColumnModel().getColumn(0).setCellRenderer(centerRenderer);
        orderTable.getColumnModel().getColumn(1).setPreferredWidth(150);
        orderTable.getColumnModel().getColumn(1).setCellRenderer(centerRenderer);
        orderTable.getColumnModel().getColumn(2).setPreferredWidth(100);
        orderTable.getColumnModel().getColumn(2).setCellRenderer(centerRenderer);
        orderTable.getColumnModel().getColumn(3).setPreferredWidth(100);
        orderTable.getColumnModel().getColumn(3).setCellRenderer(centerRenderer);
        orderTable.getColumnModel().getColumn(4).setPreferredWidth(100);
        orderTable.getColumnModel().getColumn(4).setCellRenderer(centerRenderer);
        orderTable.getColumnModel().getColumn(5).setPreferredWidth(80);
        orderTable.getColumnModel().getColumn(5).setCellRenderer(centerRenderer);
        orderTable.getColumnModel().getColumn(6).setPreferredWidth(150);
        orderTable.getColumnModel().getColumn(7).setPreferredWidth(200);
        orderTable.getColumnModel().getColumn(8).setPreferredWidth(120);
        orderTable.getColumnModel().getColumn(8).setCellRenderer(centerRenderer);
    }
    
    private void applyFilters() {
        loadOrders();
    }
    
    private void clearFilters() {
        statusComboBox.setSelectedIndex(0);
        buyerIDField.setText("");
        fromDateField.setText("");
        toDateField.setText("");
        sortColumnComboBox.setSelectedItem("OrderAt");
        sortDirectionComboBox.setSelectedItem("DESC");
        loadOrders();
    }
    
    private void viewOrderDetail() {
        int selectedRow = orderTable.getSelectedRow();
        if (selectedRow == -1) {
            JOptionPane.showMessageDialog(this,
                "Please select an order to view details.",
                "No Selection",
                JOptionPane.WARNING_MESSAGE);
            return;
        }
        
        JOptionPane.showMessageDialog(this,
            "Order detail view will be implemented.",
            "Info",
            JOptionPane.INFORMATION_MESSAGE);
    }
    

    private void addOrder() {
        BuyerView.getInstance().setVisible(true);
    }
    
    private void editOrder() {
        int selectedRow = orderTable.getSelectedRow();
        if (selectedRow == -1) {
            new OrderForm(Mode.UPDATE).setVisible(true);
            return;
        }
        new OrderForm(Mode.UPDATE).setVisible(true);
    }
    
    private void deleteOrder() {
        int selectedRow = orderTable.getSelectedRow();
        if (selectedRow == -1) {
            new OrderForm(Mode.DELETE).setVisible(true);
            return;
        }
        
        int confirm = JOptionPane.showConfirmDialog(this,
            "Are you sure you want to delete this order?",
            "Confirm Delete",
            JOptionPane.YES_NO_OPTION,
            JOptionPane.WARNING_MESSAGE);
            
        if (confirm == JOptionPane.YES_OPTION) {
            new OrderForm(Mode.DELETE).setVisible(true);
        }
    }

    private void openSummaryReport() {
        new OrderSummaryDashboard().setVisible(true);
    }
    

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
           new Dashboard().setVisible(true);
        });
    }
}