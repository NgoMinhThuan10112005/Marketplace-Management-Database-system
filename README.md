# Marketplace DB Task 3 - Setup & Run Guide

## 1) Prerequisites

Install:
- **Java 11**
- **Maven 3.8+**
- **MySQL 8.x**
- (Recommended) **MySQL Workbench**

Check versions:

```powershell
java -version
mvn -version
mysql --version
```

---

## 2) Clone/Open Project

Open this folder in VS Code:

```text
db_task3/
```

---

## 3) Configure Database Connection

Edit:

- `src/main/java/com/marketplace/config/DatabaseConnection.java`

Update these constants to match your local MySQL:

- `DEFAULT_URL` (default: `jdbc:mysql://localhost:3306/marketplace`)
- `DEFAULT_USER`
- `DEFAULT_PASSWORD`

Example:

```java
private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/marketplace";
private static final String DEFAULT_USER = "root";
private static final String DEFAULT_PASSWORD = "your_password";
```

---

## 4) Initialize Database (IMPORTANT ORDER)

Run SQL files in this exact order:

1. `Data/CREATE_TABLE.sql`
2. `Data/INSERT_DATA.sql`
3. `Data/2.1.sql`
4. `Data/OrderItem_procedures.sql`
5. `Data/2.2.sql`
6. `Data/2.3.sql`
7. `Data/2.4.sql`

### MySQL Workbench (recommended)
- Open each file in order above.
- Set default schema to `marketplace` (or run `USE marketplace;`) before running files from `2.1.sql` onward.
- Execute entire script each time.
- For `2.3.sql` and `2.4.sql`, execute as a full script (they use `DELIMITER`).


Note: `CREATE_TABLE.sql` already creates schema `marketplace`.

---

## 5) Verify DB Objects

Run these quick checks in MySQL:

```sql
USE marketplace;
SHOW TABLES;
SHOW PROCEDURE STATUS WHERE Db = 'marketplace';
SHOW FUNCTION STATUS WHERE Db = 'marketplace';
SELECT COUNT(*) AS total_orders FROM `Order`;
```

If setup is correct, you should see tables, procedures/functions, and seeded data.

---

## 6) Build and Run Application

From project root:

```powershell
mvn clean compile
mvn org.codehaus.mojo:exec-maven-plugin:3.1.0:java -Dexec.mainClass=com.marketplace.main.MainApp
```

Alternative in VS Code:
- Open `src/main/java/com/marketplace/main/MainApp.java`
- Click **Run** (or run Java main from IDE)

---

## 7) Common Errors & Fixes

### 1) Access denied for MySQL user
- Recheck username/password in `DatabaseConnection.java`.
- Ensure MySQL server is running.

### 2) Procedure/function not found
- You likely skipped SQL files or executed them out of order.
- Re-run section **4** in exact order.

### 3) SQL error in `OrderItem_procedures.sql`
If you get a syntax error near the beginning, check this line and remove trailing `c` if present:

```sql
DROP PROCEDURE IF EXISTS sp_RemoveOrderItem;
```

Then run the script again.

### 4) Port or connection issue
- Ensure MySQL is on port `3306` (or update JDBC URL accordingly).

---

## 8) What the App Uses

Main class:
- `com.marketplace.main.MainApp`

Main screens:
- Order Dashboard
- Buyer summary/report views

Main DB procedures used by Java DAO:
- `sp_CreateOrder`
- `sp_UpdateOrder`
- `sp_DeleteOrder`
- `sp_AddOrderItem`
- `sp_GetOrdersList`
- `sp_GetOrderSummaryByBuyer`

---

## 9) Quick Start (TL;DR)

1. Set DB credentials in `DatabaseConnection.java`.
2. Run SQL files in order (`CREATE_TABLE` → `INSERT_DATA` → `2.1` → `OrderItem_procedures` → `2.2` → `2.3` → `2.4`).
3. Run:

```powershell
mvn clean compile
mvn org.codehaus.mojo:exec-maven-plugin:3.1.0:java -Dexec.mainClass=com.marketplace.main.MainApp
```

You should see the desktop dashboard window.
