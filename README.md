# SRI_Report

Optimised SP functionality:

# 🚀 Stored Procedure: Check_CLIENTNAME_Availability

This stored procedure is part of a CRM database system and is responsible for checking whether a given client name is already present in the system. It also provides detailed client information for administrative users.

---

## 🔍 Overview

- Validates the availability of a client name.
- Returns detailed client information to **Admin users (group_id = 0)**.
- Returns a simple availability flag to **non-admin users**.

---

## 📥 Inputs and 📤 Outputs

| Parameter        | Type           | Description                                                |
|------------------|----------------|------------------------------------------------------------|
| `@p_client_name` | `varchar(100)` | Name of the client to check for existence                 |
| `@p_user_id`     | `int`          | ID of the user making the request                         |
| `@p_result`      | `int OUTPUT`   | Returns `0` if name exists, `1` if available              |

---


## ⚙ Optimization Highlights

This procedure was optimized from its original version with the following improvements:

- ✅ Replaced multiple scalar subqueries with proper `JOIN`s.
- ✅ Reduced duplicated logic for maintainability.
- ✅ Used clean `CASE` expressions to simplify conditionals.
- ✅ Enhanced filtering with space-insensitive matching using `REPLACE`.
- ✅ Used table aliases and consistent formatting for readability.

---

## 🧪 How to Test

1. ✅ Use an **admin user (group_id = 0)** and pass a partial or full client name — should return full data.
2. ✅ Use a **non-admin user** to test if the procedure correctly returns only availability (`0` or `1`).
3. ✅ Use mock tables (`m_user`, `m_clients`, etc.) and a dummy `fn_ClientInitiationDate()` function for simulation.

---

## 📂 Related Files

| File Name                                  | Description                            |
|--------------------------------------------|----------------------------------------|
| `Check_CLIENTNAME_Availability.sql`        | The optimized stored procedure         |
| `SP_Check_CLIENTNAME_Availability_README`  | PDF-style reference guide (optional)   |

---

## 📌 Note

This procedure is used in a production CRM environment and is designed to respect user access control. Only privileged users can view client details, while others can only check for name conflicts.

---

## 📬 Contribution & Support

If you have suggestions for improving this logic, feel free to open an issue or contribute via a pull request.

---


